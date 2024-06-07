require "logger"
class ProctoruClient::Client < ProctoruClient::Base
  attr_accessor :config, :token

  def initialize(config = ProctoruClient.configuration)
    @config = config
    logger("Configured: #{config.to_json(except: ["encryption_key", "secret_key"])}")
  end

  def configure
    yield config
  end

  # sso token
  def sso_token(email)
    begin
      url = config.base_url + "/api/autoLogin"
      body = {
        email: email
      }
      json = JSON.parse(RestClient.post(url,
                                        body.to_json,
                                        {
                                          authorization_token: config.token,
                                          content_type: "application/x-www-form-urlencoded"
                                        }))
      check_response_code_for_error(json)
      json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # GET
  # ENDPOINT NOTFOUND inside ta-web
  def timezones
    begin
      url = config.base_url + "/api/getTimeZoneList"
      json = JSON.parse(RestClient.get(url,
                                       {
                                          authorization_token: config.token
                                       }))
      check_response_code_for_error(json)
      json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  def find_timezones
    begin
      url = config.base_url + "/api/getTimeZoneList"
      json = JSON.parse(RestClient.get(url,
                                       {
                                          authorization_token: config.token
                                       }))
      check_response_code_for_error(json)
      json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # POST 
  # ENDPOINT NOTFOUND inside ta-web
  def examtimes(user, time_zone_id, exam_date)
    begin
      url = config.base_url + "/api/getScheduleInfoAvailableTimesList"
      body = {
        time_zone_id: time_zone_id,
        start_date: exam_date,
        student_id: user.id,
        duration: 60,
        takeitnow: 'Y'
      }
      json = JSON.parse(RestClient.post(url,
                                        body.to_json,
                                        {
                                          authorization_token: config.token,
                                          content_type: "application/x-www-form-urlencoded"
                                        }))
      check_response_code_for_error(json)
      json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  def exam_preset_by_level(level)
    # Enter the Exam Level value as 1,2,3,4 or 5.
    # 1 for Live Authentication (LevelLA),
    # 2 for Automated Proctoring (Level1),
    # 3 Record and Review Proctoring (Level2),
    # 4 for Live Proctoring (L3),
    # 5 for Auto-Authentication(LevelAA)
    #
    # We want 4 until somebody requires something different
    level = level.to_i
    case level
    when 1..2
      "high"
    when 3
      "medium"
    else
      "low"
    end
  end
  
  ##################### Start AssessmentReservation ######################
  # POST
  
  def schedule(user, course, exam)
    begin
      url = config.base_url + "/api/addAdHocProcess/"
      body = {
        student_id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        address1: user.try(:address).try(:street_address),
        country: user.try(:address).try(:country_code),
        city: user.try(:address).try(:city),
        state: user.try(:address).try(:state),
        zipcode: user.try(:zipcode),
        phone1: user.try(:phone_number),
        email: user.email,
        time_zone_id: exam.time_zone,
        description: exam.name,
        duration: exam.duration_in_minutes,
        start_date: exam.date,
        reservation_id: exam.id, 
        exam_url: exam.url,
        exam_password: exam.password,
        notes: exam.instructions,
        takeitnow: 'N',
        notify: 'Y',
        preset: exam_preset_by_level(exam.level)
      }
      encoded_body = URI.encode_www_form(body)
      logger("Schedule Request: #{encoded_body}")
      json = JSON.parse(RestClient.post(url,
                                        encoded_body,
                                        {
                                          authorization_token: config.token,
                                          content_type: "application/x-www-form-urlencoded"
                                        }))

      check_response_code_for_error(json)
      appt_info = json["data"]
      appt_info["status"] = "scheduled"  

      ProctoruClient::Appointment.from_proctoru_api(appt_info)
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      puts json
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end

  # POST
  def reschedule(transaction_id, course, exam)
    begin
      url = config.base_url + "/api/moveReservation/"
      body = {
        reservation_no: transaction_id,
        reservation_id: exam.id,
        start_date: exam.date,
        url_return: "" #URL to redirect the test-taker to after scheduling
      }
      logger("Reschedule Request: #{body.to_json}")
      encoded_body = URI.encode_www_form(body)
      json = JSON.parse(RestClient.post(url,
                                        encoded_body,
                                       {
                                          authorization_token: config.token,
                                          content_type: "application/x-www-form-urlencoded"
                                       }))
      check_response_code_for_error(json)
      appt_info = json["data"]
      appt_info["status"] = "scheduled"  
      ProctoruClient::Appointment.from_proctoru_api(appt_info)
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end

  # POST
  def cancel(transaction_id, user_id)
    begin
      url = config.base_url + "/api/removeReservation"
      logger("Cancel Request: #{url.to_json}")
      body = {
        student_id: user_id, 
        reservation_no: transaction_id,      
        url_return: "" #URL to redirect the test-taker to after scheduling
      }
      logger("Cancel Request: #{body.to_json}")
      encoded_body = URI.encode_www_form(body)
      json = JSON.parse(RestClient.post(url,
                                        encoded_body,
                                        {
                                          authorization_token: config.token,
                                          content_type: "application/x-www-form-urlencoded"
                                        }))
      check_response_code_for_error(json)
      appt_info = json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end
  ##################### End AssessmentReservation ######################
  
  # POST
  # TODO ProctorU does not support pagination 
  def exams_for_user(course, user, page = 1)
    begin
      url = config.base_url + "/api/getStudentReservationList/?student_id=#{user.id}"
      json = JSON.parse(RestClient.get(url,
                                       {
                                        authorization_token: config.token,
                                       }))
      check_response_code_for_error(json)
      reservation_info = json["data"]
      exams_info = reservation_info
      @pagination = {
        current: 1,
        total: exams_info.count,
      }
      @user = user_profile(user)
      @exams = exams_info.collect do |j|
        ProctoruClient::Appointment.from_proctoru_api(j)
      end
      return {user: @user, exams: @exams, pagination: @pagination}
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # Get
  # ENDPOINT NOTFOUND inside ta-web
  def exams_for_course(course, page = 1)
    begin
      url = config.base_url + "/api/getInstitutionExamList?all=F"
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization_token: config.token
                                       }))
      check_response_code_for_error(json)
      exams_info = json["data"]
      if exams_info.present?
        exams_info_by_course = exams_info.find { |exam| exam["courseno"] == course.id }
        @pagination = {
          current: 1,
          total: exams_info_by_course.count,
        }
        @exams = exams_info_by_course.collect do |j|
        {
          exams: ProctoruClient::Appointment.from_proctoru_api(j)
        }
        end
      else
        @exams = exams_info
      end
      @exams
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # GET
  # TODO ProtorU do not support retrieve exam/reservation_info by resverstion_id
  # We can only get aviable timeslot in API currently
  def exam(transaction_id, user)
    begin
      reservations = reservations_for_user(user.id)
      appt_info = unless reservations.empty?
        reservations.find { |reservation| reservation.id == transaction_id }
      end
      user_info = user_profile(user)
      return {
        user: user_info,
        appointment: appt_info
      }
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # POST
  def get_token
    raise ArgumentError.new("Please provide base_url") unless config.base_url
    raise ArgumentError.new("Please provide api_key") unless config.api_key
    @token = config.token
  end

  # GET
  def user_profile(user)
    begin
      url = config.base_url + "/api/getStudentProfile/?student_id=#{user.id}"
      json = JSON.parse(RestClient.get(url,
                                       {
                                        authorization_token: config.token
                                       }))
      check_response_code_for_error(json)
      ProctoruClient::User.from_proctoru_api(json["data"])
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  def exams_for_institution(active = "Y")
    begin
      url = config.base_url + "/api/getInstitutionExamList?all=#{active}"
      json = JSON.parse(RestClient.get(url,
                                       {
                                        authorization_token: config.token
                                       }))
      check_response_code_for_error(json)
      json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  def reservations_for_user(student_id)
    begin
      url = config.base_url + "/api/getStudentReservationList?student_id=#{student_id}"
      json = JSON.parse(RestClient.get(url,
                                       {
                                        authorization_token: config.token
                                       }))
      check_response_code_for_error(json)
      reservations_info = json["data"]
      @reservations = reservations_info.collect do |j|
        ProctoruClient::Appointment.from_proctoru_api(j)
      end
      @reservations
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  private
  def logger(message)
    message = "PROCTORU CLIENT: #{message}"
    unless @logger
      begin
        @logger = ::Rails.logger
        RestClient.log = @logger
      rescue NoMethodError, NameError
        @logger = Logger.new(STDERR)
        RestClient.log = @logger
        @logger.warn "No rails logger, using standalone"
      end
    end
    
    @logger.warn("ProctoruClient: #{message}")
  end

  def check_response_code_for_error(response)
    code = response["response_code"].to_i
    error, msg = code_in_error?(code)
    raise ProctoruClient::Error.new(response["message"], code) if error
  end
end
