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
      retries ||= 0
      url = config.base_url + "/api/autoLogin"
      body = {
        email: email
      }
      json = JSON.parse(RestClient.post(url,
                                        body.to_json,
                                        {
                                          authorization: token,
                                          content_type: "application/json"
                                        }))
      check_response_code_for_error(json["response_code"])
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
      retries ||= 0
      url = config.base_url + "/api/getTimeZoneList"
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))
      check_response_code_for_error(json["response_code"])
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
      retries ||= 0
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
                                          authorization: token,
                                          content_type: "application/json"
                                        }))
      check_response_code_for_error(json["response_code"])
      json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  ##################### Start AssessmentReservation ######################
  # POST
  def schedule(user, course, exam)
    begin
      retries ||= 0
      url = config.base_url + "/api/addAdHocProcess/"
      body = {
        first_name: user.first_name,
        last_name: user.last_name,
        address1: user.address.street_address,
        city: user.address.city,
        state: user.address.state,
        country: user.address.country_code,
        zipcode: user.zipcode,
        phone1: user.telephone_number,
        email: user.email,
        time_zone_id: exam.time_zone,
        description: exam.name,
        duration: exam.duration_in_minutes,
        start_date: exam.date,
        reservation_id: exam.id, #Institution's unique reservation ID
        url_return: "", #URL to redirect the test-taker to after scheduling
        exam_url: exam.url,
        exam_password: exam.password,
        notes: exam.instructions
      }
      logger("Schedule Request: #{body.to_json}")
      json = JSON.parse(RestClient.post(url,
                                        body.to_json,
                                        {
                                          authorization: token,
                                          content_type: "application/json"
                                        }))
      check_response_code_for_error(json["response_code"])
      appt_info = json["data"]
      ProctoruClient::Appointment.from_proctoru_api(appt_info)
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end

  # PUT
  def reschedule(transaction_id, course, exam)
    begin
      retries ||= 0
      url = config.base_url + "/api/moveReservation/"
      body = {
        reservation_no: transaction_id,
        start_date: exam.date,
        reservation_id: exam.id,
        url_return: "" #URL to redirect the test-taker to after scheduling
      }
      logger("Reschedule Request: #{body.to_json}")
      json = JSON.parse(RestClient.post(url,
                                       body.to_json,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))
      check_response_code_for_error(json["response_code"])
      appt_info = json["data"]
      ProctoruClient::Appointment.from_proctoru_api(appt_info)
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end

  # DELETE
  def cancel(user, transaction_id)
    begin
      retries ||= 0
      url = config.base_url + "/api/removeReservation"
      logger("Cancel Request: #{url.to_json}")
      body = {
        student_id: user.id, #Institution's unique test-taker ID
        reservation_no: transaction_id,      
        url_return: "" #URL to redirect the test-taker to after scheduling
      }
      json = JSON.parse(RestClient.post(url,
                                body.to_json,
                                {
                                  authorization: token,
                                  content_type: "application/json"
                                }))
      check_response_code_for_error(json["response_code"])
      appt_info = json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end
  ##################### End AssessmentReservation ######################
  def reservation(student_id)
    begin
      retries ||= 0
      url = config.base_url + "/api/getStudentReservationList?student_id=#{student_id}"
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))
      check_response_code_for_error(json["response_code"])
      reservation_info = json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # POST
  # TODO this doesn't handle paging automatically
  # Comments for Su
  # Check whether protoru support paging automatically
  def exams_for_user(course, user, page = 1)
    begin
      retries ||= 0
      url = config.base_url + "/api/getStudentReservationList"
      body = {
        student_id: user.id
      }
      json = JSON.parse(RestClient.get(url,
                                       body.to_json,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))
      check_response_code_for_error(json["response_code"])
      reservation_info = json["data"]
      exams_info = reservation_info.find { |reservation| reservation["courseno"] == course.id }
      @pagination = {
        current: 1,
        total: exams_info.size,
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

  # Note: Proctor U have terms > exam > course
  def terms_for_institution(active = "Y")
    begin
      retries ||= 0
      url = config.base_url + "/api/getInstitutionTermList"
      body = {
        all: active # Set to Y will only return active terms
      }
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))
      check_response_code_for_error(json["response_code"])
      json["data"]
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # GET
  # ENDPOINT NOTFOUND inside ta-web
  def exams_for_course(course, page = 1)
    begin
      retries ||= 0
      url = config.base_url + "/api/getInstitutionExamList"
      body = {
        all: 'Y'
      }
      json = JSON.parse(RestClient.get(url,
                                       body.to_json,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))
      check_response_code_for_error(json["response_code"])
      exams_info = json["data"]
      exams_info_by_course = exams_info.find { |exam| exam["courseno"] == course.id }
      @pagination = {
        current: 1,
        total: exams_info_by_course.size,
      }
      @exams = exams_info_by_course.collect do |j|
        {
          exams: ProctoruClient::Appointment.from_proctoru_api(j)
        }
      end
      @exams
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"])
    end
  end

  # GET
  # Getting exam info for specific reservation no will also required user_id
  def exam(transaction_id, user)
    begin
      retries ||= 0
      url = config.base_url + "/api/getScheduleInfoAvailableTimesList"
      body = {
        takeitnow: 'N',
        isadhoc: 'Y',
        reservation_no: transaction_id,
        student_id: user.id, #Required if we query with reservation_no
        start_date: Time.now
      }
      json = JSON.parse(RestClient.get(url,
                                       body.to_json,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))
      check_response_code_for_error(json["response_code"])
      appt_info = json["data"]

      # FIXME: we can omit this since we only need appointment info 
      user_info = user_profile(user)

      return {
        user: user_info,
        appointment: ProctoruClient::Appointment.from_proctoru_api(appt_info)
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
    @token = config.api_key
  end

  # GET
  def user_profile(user)
    begin
      retries ||= 0
      url = config.base_url + "/api/getStudentProfile/#{user.id}"
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json",
                                       }))
      check_response_code_for_error(json["response_code"])
      ProctoruClient::User.from_proctoru_api(json["data"])
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

  def check_response_code_for_error(code)
    code = code.to_i

    error, msg = code_in_error?(code)
    raise ProctoruClient::Error.new(msg, code) if error
  end
end
