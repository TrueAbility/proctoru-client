class ProctoruClient::Configuration
  attr_accessor :client_id, :encryption_key, :secret_key, :base_url, :login_url, :api_key

  def initialize(opts = {})
    opts.symbolize_keys!
    # @client_id = opts[:client_id]
    # @secret_key = opts[:secret_key]
    # @encryption_key = opts[:encryption_key]
    @base_url = opts[:base_url]
    @login_url = opts[:login_url]
    @token = opts[:api_key]
    self
  end
end
