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
      url = sso_login(email)
      uri = URI.parse(url)
      query_params = URI.decode_www_form(uri.query || "")
      token_param = query_params.assoc("token")
      if token_param
        token = token_param.last
      else
        raise ProctoruClient::Error.new("Something went wrong")
      end
    rescue RestClient::Exception => e
      raise ProctoruClient::Error.new("Something went wrong")
    end
  end

  def sso_login(email, user_id)
    begin
      url = config.base_url + "/api/autoLogin"
      body = {
        student_id: user_id,
        email: email,
        update: 'N'
      }
      encoded_body = URI.encode_www_form(body)
      json = JSON.parse(RestClient.post(url,
                                        encoded_body,
                                        {
                                          authorization_token: config.token,
                                          content_type: "application/x-www-form-urlencoded"
                                        }))
      check_response_code_for_error(json)
      json["data"]["url"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # GET
  def timezones
    begin
      url = config.base_url + "/api/getTimeZoneList"
      json = JSON.parse(RestClient.get(url,
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

  def find_timezones(time_zone)
    begin
      url = config.base_url + "/api/getTimeZoneList"
      json = JSON.parse(RestClient.get(url,
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

  # POST 
  # Returns a list of the available times, as well as a list of times for a specific exam. 
  # 1. with an exam or test-taker (isadhoc: 'N', required: [exam_id, student_id])
  # 2. without an exam or test-taker. (isadhoc: 'Y')
  def examtimes(time_zone_id, exam_date, user = nil, duration = 60, transaction_id = nil)
    begin
      url = config.base_url + "/api/getScheduleInfoAvailableTimesList"
      params = {
        time_zone_id: time_zone_id || "UTC",
        start_date: exam_date,
        duration: duration,
        takeitnow: 'Y',
        isadhoc: user.nil? ? 'Y' : 'N'
      }
      if !user.nil?
        params[:student_id] = user.id
        params[:reservation_no] = transaction_id if transaction_id
      end
      json = JSON.parse(RestClient.get(url,
                                        { 
                                          params: params,
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

  def available_times(start_date:, time_zone_id:, duration: 60)
    begin
      url = config.base_url + "/api/getScheduleInfoAvailableTimesList"
      params = {
        time_zone_id: time_zone_id || "UTC",
        start_date: start_date,
        duration: duration,
        takeitnow: 'Y',
        isadhoc: 'Y'
      }
      json = JSON.parse(RestClient.get(url,
                                        { 
                                          params: params,
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
  
  # POST
  # Reserves a time for a test-taker to take an exam 
  def schedule(user, course, exam)
    begin
      url = config.base_url + "/api/addAdHocProcess"
      body = {
        student_id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        address1: user.address,
        country: user.country,
        city: user.city,
        state: user.state,
        zipcode: user.zipcode,
        phone1: user.phone_number,
        email: user.email,
        time_zone_id: exam.time_zone || "UTC",
        description: exam.name,
        duration: exam.duration_in_minutes,
        start_date: exam.date,
        reservation_id: exam.id, 
        exam_url: exam.url,
        exam_password: exam.password,
        notes: exam.instructions,
        takeitnow: 'N',
        notify: 'Y',
        preset: exam_preset_by_level(exam.level),
        courseno: course.name,
        course_id: course.id,
        update: 'Y',
        active: 'T',
        url_return: "" #URL to redirect the test-taker to after scheduling
      }
      logger("Schedule Request: #{body.to_json}")
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
      if json_data["message"].start_with?("reservation_id_EXIST_FOR_THIS_INSTITUTION")
        appt_info = get_user_reservation_info(user_id, reservation_id)
        if appt_info.present?
          return ProctoruClient::Appointment.from_proctoru_api(appt_info)
        end
      end
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end

  def get_user_reservation_info(user_id, reservation_no)
    @reservations = reservations_for_user(user_id)
    reservation_found = @reservations.find { |reservation| reservation["reservation_no"] == reservation_no }
    reservation_found
  end

  # POST
  # Moves an existing reservation from a past date to a future date if the reservation was not used
  def reschedule(transaction_id, course, exam)
    begin
      url = config.base_url + "/api/moveReservation"
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
      appt_info["status"] = "rescheduled"  
      ProctoruClient::Appointment.from_proctoru_api(appt_info)
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end

  # POST
  # Removes a reservation from the schedule
  def cancel(transaction_id, student_id)
    begin
      url = config.base_url + "/api/removeReservation"
      logger("Cancel Request: #{url.to_json}")
      body = {
        student_id: student_id, # Student id was set to email
        reservation_no: transaction_id,      
        url_return: "" #URL to redirect the test-taker to after scheduling
      }
      encoded_body = URI.encode_www_form(body)
      json = JSON.parse(RestClient.post(url,
                                        encoded_body,
                                        {
                                          authorization_token: config.token,
                                          content_type: "application/x-www-form-urlencoded"
                                        }))
      check_response_code_for_error(json)
      appt_info = json["data"]
      appt_info["status"] = "canceled"  
      ProctoruClient::Appointment.from_proctoru_api(appt_info)
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end
  
  # POST
  # TODO ProctorU does not support pagination 
  def exams_for_user(course, user, page = 1)
    begin
      @exams = reservations_for_user(user.id)
      @pagination = {
        current: 1,
        total: @exams.count,
      }
      @user = user_profile(user.id)
      return {user: @user, exams: @exams, pagination: @pagination}
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # Get
  # ENDPOINT NOTFOUND inside ta-web
  # Since we are creating exam via addAdHocProcess endpoint, we cannot specify course for each exam.
  # Proctoru does not support getting exams via course
  def exams_for_course(course, page = 1)
    begin
      # FIXME
      # Returns a list of exams, including multiple details about the exam, for an institution.
      # Note: this does not support exams (single person exam) created via addAdHocProcess flow 
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
  # TODO ProctorU does not support retrieving exam/reservation by resveration_id. 
  # We can only get avilable timeslots in API by reservation_id currently
  def exam(transaction_id, student_id)
    begin
      reservations = reservations_for_user(student_id)      
      appt_info = unless reservations.empty?
        reservations.find { |reservation| reservation.reservation_no == transaction_id }
      end
      user_info = user_profile(student_id)
      return {
        user: user_info,
        appointment: appt_info
      }
    rescue RestClient::Exception => e
      logger("Exception FROM PROCTORRU#{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # POST
  def get_token
    raise ArgumentError.new("Please provide base_url") unless config.base_url
    raise ArgumentError.new("Please provide token") unless config.token
    @token = config.token
  end

  # GET
  # Returns a test-taker's profile
  def user_profile(student_id)
    begin
      url = config.base_url + "/api/getStudentProfile/"
      params = {
        student_id: student_id
      }
      json = JSON.parse(RestClient.get(url,
                                       {
                                          params: params,
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

  # Get
  # Returns the list of active reservations for a single test-taker
  def reservations_for_user(student_id)
    begin
      url = config.base_url + "/api/getStudentReservationList"
      params = {
        student_id: student_id
      }
      json = JSON.parse(RestClient.get(url,
                                       {
                                        params: params,
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

  # GET
  # Returns the status of the authenticate flag for an individual reservation.
  # Note: this does not support reservation made via addAdhocProcess flow
  def reservation_status(transaction_id)
    begin
      url = config.base_url + "/api/getIsReservationAuthenticated"
      params = {
        reservation_no: transaction_id
      }
      json = JSON.parse(RestClient.get(url,
                                      {
                                        params: params,
                                        authorization_token: config.token
                                      }))
      check_response_code_for_error(json)
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
    # puts "#" * 80
    # puts "PROCTORU REPONSE :"
    # puts "#" * 80
    # p response
    # puts "#" * 80
    code = response["response_code"].to_i
    error, msg = code_in_error?(code)
    raise ProctoruClient::Error.new(response["message"], code) if error
  end
end
