require_relative "./test_helper"
require "examity_client"
require "capybara_discoball"

class ExamityClient::UserTest < Minitest::Test

  def test_initialization
    u = ExamityClient::User.new(first_name: "Dusty", email: "dusty@example.com")
    assert_equal u.first_name, "Dusty"
    assert_equal u.email, "dusty@example.com"
  end

  def test_user_profile
    Capybara::Discoball.spin(ExamityClient::TestApiServer) do |server|
      config = ExamityClient::Configuration.new(
        base_url: server.url,
        client_id: "my client id",
        secret_key: "my secret")

      client = ExamityClient::Client.new(config)
      token = client.get_token
      assert_equal "secret_token", token
      user = client.user_profile(ExamityClient::User.new(id: 1))
      assert_equal "First", user.first_name
      refute user.profile_completed?
    end
  end
end
