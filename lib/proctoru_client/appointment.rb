class ProctoruClient::Appointment
  attr_accessor :course_id,
                :course_name,
                :date,
                :duration_in_minutes,
                :exam_id,
                :exam_name,
                :flags,
                :id,
                :instructions,
                :level,
                :password,
                :status,
                :time_zone,
                :url,
                :username,
                :reservation_no

  def self.from_proctoru_api(json)
    self.new( 
              id: json["reservation_id"],
              url: json["url"],
              course_id: json["courseno"],
              course_name: json["course_name"],
              exam_id: json["exam_id"],
              exam_name: json["exam_name"] || json["test"],
              duration_in_minutes: json["duration_in_minutes"],
              password: json["exam_password"],
              username: json["exam_userName"],
              time_zone: json["time_zone"],
              date: json["exam_date"] || json["start_date"], 
              instructions: json["exam_instruction"] || json["instruction"],
              status: json["exam_status"] || json["status"],
              level: json["exam_level"],
              flags: json["flaginfo"],
              reservation_no: json["reservation_no"]
            )
  end

  def initialize(opts = {})
    opts.deep_symbolize_keys!
    @course_id = opts[:course_id]
    @course_name = opts[:course_name]
    @date = opts[:date]
    @duration_in_minutes = opts[:duration_in_minutes]
    @exam_id = opts[:exam_id]
    @exam_name = opts[:exam_name]
    @id = opts[:id]
    @instructions = opts[:instructions]
    @level = opts[:level]
    @password = opts[:password]
    @status = opts[:status]
    @time_zone = opts[:time_zone]
    @url = opts[:url]
    @username = opts[:username]
    @reservation_no = opts[:reservation_no]
    @flags = []

    if opts.dig(:flags) && opts[:flags].present?
      @flags =
        opts[:flags].collect do |flag|
          flag_options = flag
          flag_options[:type] ||= flag[:flagtype]
          flag_options[:description] ||= flag[:flagdescription]
          flag_options[:timestamp] ||= flag[:flagtimestamp]
          ProctoruClient::Flag.new(flag_options)
        end
    end

    self
  end

  def to_s
    "#{id} #{date} #{status}"
  end
end
