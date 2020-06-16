class ExamityClient::Flag
  attr_accessor :type, :description, :timestamp

  def self.from_examity_api(json)
    self.new(type: json["flagtype"],
             description: json["flagdescription"],
             timestamp: json["flagtimestamp"])
  end

  def initialize(opts = {})
    opts.symbolize_keys!

    @type = opts[:type]
    @description = opts[:description]
    @timestamp = opts[:timestamp]
    self
  end

  def color
    case type.downcase.squish
    when "violation"
      :red
    when "possible violation"
      :yellow
    when "alert"
      :blue
    when "no violation"
      :green
    else
      :black
    end
  end

  def to_s
    "#{timestamp} #{type} #{description}"
  end
end
