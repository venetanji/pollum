class Reading
  include Mongoid::Document
  
  field :station
  field :metric
  field :value
  field :day
  
  identity :type => String
  
  STATIONS = [:Central, :Causeway_Bay]
  METRICS  = [:no2, :o3, :so3, :co, :rsp, :fsp]
  
  after_initialize :set_id
  def set_id
    self.id = "#{station}-#{metric}-#{day.to_date}" if new_record?
  end
  
  def fetch_data
    agent = Mechanize.new
    STATIONS.each do ||
      page = agent.get(station_url)
      page.css("tr[bgcolor=#E1E8E0]")
      binding.pry
    end
  end
  
  def station_url
    "http://www.epd-asg.gov.hk/english/24pollu_fsp/#{station_fsp.html}"
  end
end