require_relative "./test_helper"
require "examity_client"

class ExamityClient::SsoTokenTest < Minitest::Test
  attr_accessor :client
  def setup
    config = ExamityClient::Configuration.new(
      encryption_key: 'testtesttesttest',
      client_id: "my client id",
      secret_key: "my secret",
    )
    @client = ExamityClient::Client.new(config)
  end

  def test_can_generate_sso_token
    token = client.sso_token('user@example.com')
    assert_equal "Xgc+7jn/WDAEfo4kzW8ON2CL/v2yRvyiaI+wjrnLOvc=", token
  end

end
