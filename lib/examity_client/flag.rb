class ExamityClient::Flag
  attr_accessor :type, :description, :timestamp

  def self.from_examity_api(json)
    new(flagtype: json["flagtype"],
        flagdescription: json["flagdescription"],
        flagtimestamp: json["flagtimestamp"])
  end

  def initialize(opts = {})
    opts.symbolize_keys!

    @type = opts[:flagtype]
    @description = opts[:flagdescription]
    @timestamp = opts[:flagtimestamp]
    self
  end

  def color
    case type&.downcase&.squish
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
