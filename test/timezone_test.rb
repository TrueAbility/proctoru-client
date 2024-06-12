require_relative "./test_helper"
require "proctoru_client"
require "capybara_discoball"

class ProctoruClient::TimezoneTest < Minitest::Test
  attr_accessor :client

  def setup
    Capybara::Discoball.spin(ProctoruClient::TestApiServer) do |server|
      config = ProctoruClient::Configuration.new(
        base_url: server.url,
        token: "secret_token",
        client_id: "my client id",
        secret_key: "my secret")

      @client = ProctoruClient::Client.new(config)
    end
  end

  def test_timezones
    client.get_token
    tz = client.timezones
    assert_equal tz[1]["id"], 2
    assert_equal  tz[1]["timezone"], "Coordinated Universal Time (UTC+00:00) " # yes they have an extra space
  end
end
