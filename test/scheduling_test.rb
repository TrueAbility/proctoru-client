require_relative "./test_helper"
require "examity_client"
require "capybara_discoball"

class ExamityClient::SchedulingTest < Minitest::Test
  attr_accessor :client, :user, :course, :exam

  def setup
    Capybara::Discoball.spin(ExamityClient::TestApiServer) do |server|
      config = ExamityClient::Configuration.new(
        base_url: server.url,
        client_id: "my client id",
        secret_key: "my secret")

      @client = ExamityClient::Client.new(config)
    end
    @user = ExamityClient::User.new(id: 1, first: "First", last: "Last", email: "first.last@email.com")
    @course = ExamityClient::Course.new(id: 1001, name: "One thousand and one")
    @exam = ExamityClient::Exam.new(id: 2002, name: "Two thousand and two", url: "http://2002.dev",
                                    duration_in_minutes: 60, time_zone: 1, date: Time.now)
  end

  def test_scheduling_exam
    client.get_token
    appointment = client.schedule(user, course, exam)
    assert_equal "scheduled",  appointment.status
  end

  def test_rescheduling_exam
    client.get_token
    appointment = client.reschedule(1, course, exam)
    assert_equal "rescheduled",  appointment.status
  end

  def test_canceling_exam
    client.get_token
    appointment = client.cancel(1)
    assert_equal "canceled",  appointment.status
  end
end
