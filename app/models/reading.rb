class Reading
  include Mongoid::Document
  
  field :station
  field :metric
  field :value, type: Float, default: 0
  field :time, type: Time
  
  index [[:station, Mongo::DESCENDING ],[:time, Mongo::ASCENDING],[:metric, Mongo::ASCENDING]]
  
  identity :type => String
  
  STATIONS = [:Central, :Central_Western, :Eastern, :Kwai_Chung,
              :Kwun_Tong, :Sha_Tin, :Sham_Shui_Po, :Tai_Po, :Tap_Mun,
              :Tsuen_Wan, :Tung_Chung, :Yuen_Long, :Mong_Kok,
              :Causeway_Bay]
  METRICS  = [:no2, :o3, :so3, :co, :rsp, :fsp]
  
  after_initialize :set_id
  
  def set_id
    self.id = "#{station}-#{metric}-#{time.to_i}" if new_record?
  end

  class << self
    def fetch_data
      Time.zone = "Hong Kong"
      agent = Mechanize.new
      readings = {}
      STATIONS.each do |station|
        page = agent.get(station_url(station))
        page.root.css("tr[bgcolor='#E1E8E0']").each do |row|
          cells = row.xpath('td')
          time = Time.zone.parse(cells.first.text)
          cells[1..6].each_with_index do |value, i|
            next if value.text =~ /--/
            reading = new(station: station, time: time, metric: METRICS[i], value: value.text) 
            readings[reading.id] = reading
          end
          find(readings.keys).each do |existing_reading|
            readings.delete(existing_reading.id)
          end
          collection.insert(readings.values.collect(&:as_document))
        end
      end
    end

    def to_series(aggregator = :metric)
      series_hash = Hash.new do |hash, key| hash[key] = Hash.new end
      records = all.asc(:time)
      records.each do |i|   
        series_hash[i.send(aggregator)][i.time] = i.value
      end
      series_array = []
      series_hash.each_pair do |metric,values|
        name = aggregator == :metric ? I18n.t("reading.metrics.#{metric}") : metric.to_s.humanize.titleize
        series_array << {
          name: name,
          # pointInterval: 24 * 3600 * 1000,
          # pointStart: values.keys.min.utc.to_i * 1000,
          data: format_serie(values)
        }
      end
      series_array
    end
    
    private
    
    def format_serie(hash)
      data = []
      # min = hash.keys.min
      # max = hash.keys.max
      # i = 0
      # (min.to_date...max.to_date).times do |day|
      #   data << hash[hash.keys.min + i.days] || 0
      # end
      hash.each_pair do |k,v|
        data << [k.to_i * 1000, v]
      end
      data
    end
    
    def station_url(station)
      "http://www.epd-asg.gov.hk/english/24pollu_fsp/#{station}_fsp.html"
    end
    
  end
end