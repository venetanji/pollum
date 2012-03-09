class Reading
  include Mongoid::Document
  
  field :station
  field :metric
  field :value, type: Float, default: 0
  field :time, type: Time
  
  identity :type => String
  
  STATIONS = [:Central, :Causeway_Bay]
  METRICS  = [:no2, :o3, :so3, :co, :rsp, :fsp]
  
  after_initialize :set_id
  
  def set_id
    self.id = "#{station}-#{metric}-#{time.to_i}" if new_record?
  end
  
  class << self
    def fetch_data
      agent = Mechanize.new
      readings = {}
      STATIONS.each do |station|
        page = agent.get(station_url(station))
        page.root.css("tr[bgcolor='#E1E8E0']").each do |row|
          cells = row.xpath('td')
          time = Time.parse(cells.first.text)
          cells[1..6].each_with_index do |value, i|
            next if value.text == "--"
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
  
    def station_url(station)
      "http://www.epd-asg.gov.hk/english/24pollu_fsp/#{station}_fsp.html"
    end
  end
end