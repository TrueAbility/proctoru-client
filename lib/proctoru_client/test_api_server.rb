require "sinatra/base"

class ProctoruClient::TestApiServer < Sinatra::Base
  # timezone
  get "/api/getTimeZoneList" do
    {
      response_code: 1,
      message: "Successful request",
      timeStamp: Time.now,
      timezoneInfo: [
        
      ]
    }.to_json + "\n"
  end

  # schedule
  post "/api/addAdHocProcess" do
    user_id = params[:user_id].to_i
    { 
      response_code: 1,
      message: "",
      data: { 
          balance: 0.0, 
          reservation_id: user_id, 
          reservation_no: 911349392,
          url: "https://demo.proctoru.com/students/reservations?login_token=BAhpBEnoMDc%3D--1a7408244b3c06e719702c6afc7742a5b95cc4f9&reservation_no=911349392&return_to=https%3A%2F%2Fdemo.proctoru.com%2Fstudents%2Freservations"
        }
    }.to_json + "\n"
  end

  # reschedule
  post "/api/moveReservation" do
    transaction_id = params[:transaction_id].to_i
    {
      response_code: 1,
      message: "",
      data: { 
        balance: "0.0", 
        reservation_id: transaction_id, 
        reservation_no: 911349392
      }
    }.to_json + "\n"
  end

  # cancel
  post "/api/removeReservation" do
    transaction_id = params[:transaction_id].to_i
    {
      response_code: 1,
      message: "Successful Result",
      data: {
        balance: "0.0"
      }
    }.to_json + "\n"
  end

  get "/api/getStudentProfile/" do
    {
      response_code: 1,
      message: "",
      data: {
        student_id: "135",
        user_id: "5fb102af",
        first_name: "First",
        last_name: "Last",
        address1: nil,
        address2: nil,
        city: nil,
        state: nil,
        zipcode: nil,
        country: "JP",
        phone1: "512-867-5309",
        phone2: nil,
        phone3: nil,
        email: "first.last@email.com",
        time_zone_id: "UTC",
        computertype: nil,
        campus: nil,
        termsaccepted: true,
        profilecomplete: false,
        hasimage: false,
        active: true,
        on_account_balance: 0.0
      }
    }.to_json + "\n"
  end
end
