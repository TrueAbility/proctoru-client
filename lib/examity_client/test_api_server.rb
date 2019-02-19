require "sinatra/base"

class ExamityClient::TestApiServer < Sinatra::Base
  def authorized?
    header = request.env["HTTP_AUTHORIZATION"]
    header == 'secret_token'
  end

  def protected!
    unless authorized?
      throw(:halt, [401, {
                      "statusCode": 401,
                          "message": "Invalid access token.",
                          "timeStamp": Time.now,
                          "errorInfo": [
                                         "Invalid access token."
                                       ]
                    }.to_json + "\n"])
    end
  end

  # schedule
  post "/examity/api/schedule" do
    protected!
    payload = JSON.parse(request.body.read, symbolize_names: true)
    {
      statusCode: 200,
      message: "Successful Result",
      appointmentInfo: {
        transactionId: 101,
        appointmentDate: payload[:examInfo][:examDate],
        status: "scheduled"
      }
    }.to_json + "\n"
  end

  # reschedule
  put "/examity/api/reschedule" do
    protected!
    payload = JSON.parse(request.body.read, symbolize_names: true)
    {
      statusCode: 200,
      message: "Successful Result",
      appointmentInfo: {
        transactionId: payload[:examInfo][:transactionId],
        appointmentDate: payload[:examInfo][:examDate],
        status: "rescheduled"
      }
    }.to_json + "\n"
  end

  # cancel
  delete "/examity/api/cancel/:transaction_id" do
    protected!
    transaction_id = params[:transaction_id].to_i

    {
      statusCode: 200,
      message: "Successful Result",
      appointmentInfo: {
        transactionId: transaction_id,
        appointmentDate: Time.now,
        status: "canceled"
      }
    }.to_json + "\n"
  end

  # auth
  post "/examity/api/token" do
    payload = JSON.parse(request.body.read, symbolize_names: true)
    {
      statusCode: 200,
      message: "Successful result",
      timestamp: Time.now,
      authInfo: {
        clientId: payload[:clientId],
        secretKey: payload[:secretKey],
        access_token: "secret_token"
      }
    }.to_json + "\n"
  end

  # user profile
  get "/examity/api/user/:user_id/profile" do
    protected!
    user_id = params[:user_id].to_s

    {
      statusCode: 200,
      message: "Successful result",
      timestamp: Time.now,
      profileInfo: {
        userId: user_id,
        firstName: "First",
        lastName: "Last",
        emailAddress: "first.last@email.com",
        phoneNumber: "512-867-5309",
        profileCompleted: false
      }
    }.to_json + "\n"
  end

  get "/test" do
    "Hello\n"
  end
end
