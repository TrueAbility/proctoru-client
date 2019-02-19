class ExamityClient::Course
  attr_accessor :id, :name

  def initialize(opts = {})
    opts.symbolize_keys!

    @id = opts[:id]
    @name = opts[:name]
  end

  def to_s
    "#{id} #{name}"
  end
end
