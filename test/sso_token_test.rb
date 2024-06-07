require 'minitest/autorun'
require 'webmock/minitest'
require_relative "./test_helper"
require "proctoru_client"

class ProctoruClient::SsoTokenTest < Minitest::Test
  attr_accessor :client
  def setup
    config = ProctoruClient::Configuration.new({
        token: "your_api_key",
        base_url: "https://demo.proctoru.com/api"
    })
    @client = ProctoruClient::Client.new(config)
  end

  def test_initialize
    assert_equal "https://demo.proctoru.com/api", @client.config.base_url
    assert_equal "your_api_key", @client.config.token
  end

  def test_sso_token_success
    stub_request(:post, 'https://demo.proctoru.com/api/api/autoLogin').with(body: { email: 'test@example.com' }.to_json,
                        headers: { 
                            'Authorization-Token' => 'your_api_key', 
                            'Content-Type' => 'application/x-www-form-urlencoded' 
                          }).to_return(status: 200, body: {
                          "time_sent": "2024-06-07T08:28:14Z",
                          "response_code": 1,
                          "message": "",
                          "data": "your_sso_token"
                        }.to_json)

    sso_token = @client.sso_token('test@example.com')  
    assert_equal 'your_sso_token', sso_token
  end
end