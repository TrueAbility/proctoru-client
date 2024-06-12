require_relative "./test_helper"
require "proctoru_client"
require "capybara_discoball"
require 'active_support/core_ext/hash/keys'

class ProctoruClient::SchedulingTest < Minitest::Test
  attr_accessor :client, :user, :course, :exam

  def setup
    Capybara::Discoball.spin(ProctoruClient::TestApiServer) do |server|
      config = ProctoruClient::Configuration.new(
        base_url: server.url,
        token: "my_token",
        client_id: "my client id",
        secret_key: "my secret")

      @client = ProctoruClient::Client.new(config)
    end
    @user = ProctoruClient::User.new(id: 1, first: "First", last: "Last", email: "first.last@email.com")
    @course = ProctoruClient::Course.new(id: 1001, name: "One thousand and one")
    @exam = ProctoruClient::Exam.new(id: 2002, name: "Two thousand and two", url: "http://2002.dev",
                                    duration_in_minutes: 60, time_zone: 1, date: "2024-06-26")
  end

  def test_scheduling_exam
    appointment = @client.schedule(user, course, exam)
    assert_equal "scheduled",  appointment.status
  end

  def test_rescheduling_exam
    appointment = @client.reschedule(1, @course, @exam)
    assert_equal "rescheduled",  appointment.status
  end

  def test_canceling_exam
    appointment = @client.cancel(1, user)
    assert_equal "canceled",  appointment.status
  end
end
