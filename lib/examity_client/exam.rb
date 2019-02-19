class ExamityClient::Exam
  attr_accessor :id, :name, :url, :duration_in_minutes, :password, :username, :time_zone,
                :date, :instructions, :level, :transaction_id, :course_id, :course_name,
                :flags

  def initialize(opts = {})
    opts.symbolize_keys!

    @id = opts[:id]
    @name = opts[:name]
    @url = opts[:url]
    @duration_in_minutes = opts[:duration_in_minutes]
    @password = opts[:password]
    @username = opts[:username]
    @time_zone = opts[:time_zone]
    @date = opts[:date]
    @instructions = opts[:instructions]
    @level = opts[:level]
  end

  def to_s
    "#{id} #{name} duration #{duration_in_minutes}"
  end
end
