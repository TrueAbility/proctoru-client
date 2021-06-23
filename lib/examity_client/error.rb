class ExamityClient::Error < StandardError

  def initialize(msg="", status_code=nil)
    super(msg)
    @status_code = status_code
    self
  end
end
