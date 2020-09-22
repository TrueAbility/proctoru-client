class ExamityClient::Appointment
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
                :username


  def self.from_examity_api(json)
    self.new(id: json["transactionId"],
             course_id: json["courseId"],
             course_name: json["courseName"],
             exam_id: json["examId"],
             exam_name: json["examName"],
             url: json["examURL"],
             duration_in_minutes: json["examDuration"],
             password: json["examPassword"],
             username: json["examUserName"],
             time_zone: json["timeZone"],
             date: json["examDate"] || json["appointmentDate"],
             instructions: json["examInstruction"],
             status: json["examStatus"] || json["status"],
             level: json["examLevel"],
             flags: json["flaginfo"],
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
    @flags = []

    if opts[:flags].present?
      @flags =
        opts[:flags].collect do |flag|
          flag_options = flag
          flag_options[:type] ||= flag[:flagtype]
          flag_options[:description] ||= flag[:flagdescription]
          flag_options[:timestamp] ||= flag[:flagtimestamp]
          ExamityClient::Flag.new(flag_options)
        end
    end

    self
  end

  def to_s
    "#{id} #{date} #{status}"
  end
end
