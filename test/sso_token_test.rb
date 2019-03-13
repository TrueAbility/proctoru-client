require_relative "./test_helper"
require "examity_client"

class ExamityClient::SsoTokenTest < Minitest::Test
  attr_accessor :client
  def setup
    config = ExamityClient::Configuration.new(
      encryption_key: 'testtesttest',
      client_id: "my client id",
      secret_key: "my secret",
    )
    @client = ExamityClient::Client.new(config)
  end

  def test_can_generate_sso_token
    token = client.sso_token('user@example.com')
    puts "Token: #{token}"
    assert_equal "sKKHQtpZX9sqv5wuN88t74f5a+XTn+gg3TQ00BLU2c4=\n", token
  end

end
