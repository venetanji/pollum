module ApplicationHelper
  def title arguments, options = {}
    case arguments
    when String
      @title = arguments
      content_for :title, @title
    when Hash
      sitename = arguments[:site_name]
      if @title
        return "#{strip_tags(@title)} - #{sitename}"
      else
        return "#{sitename}"
      end
    end
  end
  
  def twitterized_type(type)
    case type
      when :alert
        "warning"
      when :error
        "error"
      when :notice
        "info"
      when :success
        "success"
      else
        type.to_s
    end
  end
  
  def active_if(bool)
    bool ? "active" :  nil
  end
end
