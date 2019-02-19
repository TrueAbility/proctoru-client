class ExamityClient::Configuration
  attr_accessor :client_id, :secret_key, :base_url

  def initialize(opts = {})
    opts.symbolize_keys!
    @client_id = opts[:client_id]
    @secret_key = opts[:secret_key]
    @base_url = opts[:base_url]
    self
  end
end
