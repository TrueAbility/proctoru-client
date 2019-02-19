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

  # timezone
  get "/examity/api/timezone" do
    protected!
    {
      statusCode: 200,
      message: "Successful request",
      timeStamp: Time.now,
      timezoneInfo: [
        {"id"=>1, "timezone"=>"Casablanca (UTC+00:00)"},
        {"id"=>2, "timezone"=>"Coordinated Universal Time (UTC+00:00) "},
        {"id"=>3, "timezone"=>"Dublin, Edinburgh, Lisbon, London (UTC+00:00)"},
        {"id"=>4, "timezone"=>"Monrovia, Reykjavik (UTC+00:00)"},
        {"id"=>5, "timezone"=>"Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna (UTC+01:00)"},
        {"id"=>6, "timezone"=>"Belgrade, Bratislava, Budapest, Ljubljana, Prague (UTC+01:00)"},
        {"id"=>7, "timezone"=>"Brussels, Copenhagen, Madrid, Paris (UTC+01:00) "},
        {"id"=>8, "timezone"=>"Sarajevo, Skopje, Warsaw, Zagreb (UTC+01:00)"},
        {"id"=>9, "timezone"=>"West Central Africa (UTC+01:00)"},
        {"id"=>10, "timezone"=>"Amman (UTC+02:00)"},
        {"id"=>11, "timezone"=>"Athens, Bucharest, Istanbul (UTC+02:00)"},
        {"id"=>12, "timezone"=>"Beirut (UTC+02:00)"},
        {"id"=>13, "timezone"=>"Cairo (UTC+02:00)"},
        {"id"=>14, "timezone"=>"Harare, Pretoria (UTC+02:00)"},
        {"id"=>15, "timezone"=>"Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius (UTC+02:00)"},
        {"id"=>16, "timezone"=>"Jerusalem (UTC+02:00)"},
        {"id"=>17, "timezone"=>"Minsk (UTC+03:00)"},
        {"id"=>18, "timezone"=>"Windhoek (UTC+02:00)"},
        {"id"=>19, "timezone"=>"Baghdad (UTC+03:00)"},
        {"id"=>20, "timezone"=>"Kuwait, Riyadh (UTC+03:00)"},
        {"id"=>21, "timezone"=>"Moscow(UTC+03:00)"},
        {"id"=>22, "timezone"=>"Nairobi (UTC+03:00)"},
        {"id"=>23, "timezone"=>"Tehran (UTC+03:30)"},
        {"id"=>24, "timezone"=>"Abu Dhabi, Muscat (UTC+04:00)"},
        {"id"=>25, "timezone"=>"Baku (UTC+04:00)"},
        {"id"=>26, "timezone"=>"Port Louis (UTC+04:00)"},
        {"id"=>27, "timezone"=>"Tbilisi (UTC+04:00)"},
        {"id"=>28, "timezone"=>"Yerevan (UTC+04:00)"},
        {"id"=>29, "timezone"=>"Kabul (UTC+04:30)"},
        {"id"=>30, "timezone"=>"Ekaterinburg (UTC+06:00)"},
        {"id"=>31, "timezone"=>"Islamabad, Karachi (UTC+05:00)"},
        {"id"=>32, "timezone"=>"Tashkent (UTC+05:00)"},
        {"id"=>33, "timezone"=>"Chennai, Kolkata, Mumbai, New Delhi (UTC+05:30)"},
        {"id"=>34, "timezone"=>"Sri Jayawardenepura (UTC+05:30)"},
        {"id"=>35, "timezone"=>"Kathmandu (UTC+05:45)"},
        {"id"=>36, "timezone"=>"Astana, Dhaka (UTC+06:00)"},
        {"id"=>37, "timezone"=>"Novosibirsk (UTC+07:00)"},
        {"id"=>38, "timezone"=>"Yangon (Rangoon) (UTC+06:30)"},
        {"id"=>39, "timezone"=>"Bangkok, Hanoi, Jakarta (UTC+07:00)"},
        {"id"=>40, "timezone"=>"Krasnoyarsk (UTC+08:00)"},
        {"id"=>41, "timezone"=>"Beijing, Chongqing, Hong Kong, Urumqi (UTC+08:00)"},
        {"id"=>42, "timezone"=>"Irkutsk (UTC+09:00)"},
        {"id"=>43, "timezone"=>"Kuala Lumpur, Singapore (UTC+08:00)"},
        {"id"=>44, "timezone"=>"Perth (UTC+08:00)"},
        {"id"=>45, "timezone"=>"Taipei (UTC+08:00)"},
        {"id"=>46, "timezone"=>"Ulaanbaatar (UTC+08:00)"},
        {"id"=>47, "timezone"=>"Osaka, Sapporo, Tokyo (UTC+09:00)"},
        {"id"=>48, "timezone"=>"Seoul (UTC+09:00)"},
        {"id"=>49, "timezone"=>"Yakutsk (UTC+10:00)"},
        {"id"=>50, "timezone"=>"Adelaide (UTC+10:30)"},
        {"id"=>51, "timezone"=>"Darwin (UTC+09:30)"},
        {"id"=>52, "timezone"=>"Brisbane (UTC+10:00)"},
        {"id"=>53, "timezone"=>"Canberra, Melbourne, Sydney (UTC+11:00)"},
        {"id"=>54, "timezone"=>"Guam, Port Moresby (UTC+10:00)"},
        {"id"=>55, "timezone"=>"Hobart (UTC+11:00)"},
        {"id"=>56, "timezone"=>"Vladivostok (UTC+11:00)"},
        {"id"=>57, "timezone"=>"Magadan, Solomon Is., New Caledonia (UTC+12:00)"},
        {"id"=>58, "timezone"=>"Auckland, Wellington (UTC+13:00)"},
        {"id"=>59, "timezone"=>"Fiji, Marshall Is. (UTC+12:00) "},
        {"id"=>60, "timezone"=>"Petropavlovsk-Kamchatsky (UTC+12:00) "},
        {"id"=>61, "timezone"=>"Nuku'alofa (UTC+13:00)"},
        {"id"=>62, "timezone"=>"Azores (UTC-01:00)"},
        {"id"=>63, "timezone"=>"Cape Verde Is (UTC-01:00)"},
        {"id"=>64, "timezone"=>"Mid-Atlantic (UTC-02:00)"},
        {"id"=>65, "timezone"=>"Brasilia (UTC-03:00)"},
        {"id"=>66, "timezone"=>"Buenos Aires (UTC-03:00)"},
        {"id"=>67, "timezone"=>"Cayenne (UTC-03:00)"},
        {"id"=>68, "timezone"=>"Greenland (UTC-03:00)"},
        {"id"=>69, "timezone"=>"Montevideo (UTC-02:00)"},
        {"id"=>70, "timezone"=>"Newfoundland (UTC-03:30)"},
        {"id"=>71, "timezone"=>"Asuncion (UTC-03:00)"},
        {"id"=>72, "timezone"=>"Atlantic Time (UTC-04:00)"},
        {"id"=>73, "timezone"=>"Georgetown, La Paz, San Juan (UTC-04:00)"},
        {"id"=>74, "timezone"=>"Manaus (UTC-04:00)"},
        {"id"=>75, "timezone"=>"Santiago (UTC-03:00)"},
        {"id"=>76, "timezone"=>"Caracas (UTC-04:30)"},
        {"id"=>77, "timezone"=>"Bogota, Lima, Quito (UTC-05:00)"},
        {"id"=>78, "timezone"=>"Eastern Time (UTC-05:00:00)"},
        {"id"=>79, "timezone"=>"Indiana (East) (UTC-05:00)"},
        {"id"=>80, "timezone"=>"Central America (UTC-06:00)"},
        {"id"=>81, "timezone"=>"Central Time (US & Canada) (UTC-06:00)"},
        {"id"=>82, "timezone"=>"Guadalajara, Mexico City, Monterrey (UTC-06:00)"},
        {"id"=>83, "timezone"=>"Saskatchewan (UTC-06:00)"},
        {"id"=>84, "timezone"=>"Arizona (UTC-07:00)"},
        {"id"=>85, "timezone"=>"Chihuahua, La Paz, Mazatlan (UTC-07:00)"},
        {"id"=>86, "timezone"=>"Mountain Time (US & Canada) (UTC-07:00)"},
        {"id"=>87, "timezone"=>"Pacific Time (US & Canada) (UTC-08:00)"},
        {"id"=>88, "timezone"=>"Tijuana, Baja California (UTC-08:00)"},
        {"id"=>89, "timezone"=>"Alaska (UTC-09:00)"},
        {"id"=>90, "timezone"=>"Hawaii-Aleutian (UTC-10:00)"},
        {"id"=>91, "timezone"=>"Midway Island, Samoa (UTC-11:00)"},
        {"id"=>93, "timezone"=>"Baja California (UTC-08:00)"},
        {"id"=>95, "timezone"=>"AUS Eastern Standard Time (UTC+11:00:00)"},
        {"id"=>96, "timezone"=>"Cuba (UTC-05:00:00)"},
      ]
    }.to_json + "\n"
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
