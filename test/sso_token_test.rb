require_relative "./test_helper"
require "examity_client"

class ProctoruClient::SsoTokenTest < Minitest::Test
  attr_accessor :client
  def setup
    config = ProctoruClient::Configuration.new(
      auth_token: "cd8e357e-a608-4775-ac94-2db5e6b6f45e"
      base_url: "https://demo.proctoru.com/api"
    )
    @client = ProctoruClient::Client.new(config)
  end

  def test_can_generate_sso_token
    token = client.sso_token('user@example.com')
    assert_equal "Xgc+7jn/WDAEfo4kzW8ON2CL/v2yRvyiaI+wjrnLOvc=", token
  end
end
