require_relative "./test_helper"
require "examity_client"
require "capybara_discoball"

class ExamityClient::TimezoneTest < Minitest::Test
  attr_accessor :client

  def setup
    Capybara::Discoball.spin(ExamityClient::TestApiServer) do |server|
      config = ExamityClient::Configuration.new(
        base_url: server.url,
        client_id: "my client id",
        secret_key: "my secret")

      @client = ExamityClient::Client.new(config)
    end
  end

  def test_timezones
    client.get_token
    tz = client.timezones
    assert_equal tz[1]["id"], 2
    assert_equal  tz[1]["timezone"], "Coordinated Universal Time (UTC+00:00) " # yes they have an extra space
  end
end
