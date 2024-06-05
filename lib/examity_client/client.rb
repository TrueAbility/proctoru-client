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
        email: email,
        time_sent: Time.current
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
  # NOTFOUND in ta-web
  def timezones
    begin
      retries ||= 0
      url = config.base_url + "/api/getTimeZoneList"
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                         time_sent: Time.current
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
  # NOTFOUND in ta-web
  def examtimes(user, time_zone_id, exam_date)
    begin
      retries ||= 0
      url = config.base_url + "/api/getScheduleInfoAvailableTimesList"
      body = {
        time_sent: Time.now,
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
        time_sent: Time.now
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
      url = config.base_url + "/examity/api/removeReservation"
      logger("Cancel Request: #{url.to_json}")
      body = {
        student_id: user.id, #Institution's unique test-taker ID
        time_sent: Time.now,
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
      #ProctoruClient::Appointment.from_examity_api(appt_info)
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ProctoruClient::Error.new(json["message"], json["response_code"])
    end
  end
  ##################### End AssessmentReservation ######################

  # POST
  # TODO this doesn't handle paging automatically
  # Comments for Su
  # Check whether protoru support paging automatically
  def exams_for_user(course, user, page = 1)
    begin
      retries ||= 0
      url = config.base_url + "/api/getStudentReservationList"
      body = {
        student_id: user.id,
        time_sent: Time.current
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
        time_sent: Time.current,
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
  # NOTFOUND in ta-web
  def exams_for_course(course, page = 1)
    begin
      current_term = terms_for_institution

      retries ||= 0
      url = config.base_url + "/examity/getInstitutionExamList"
      body = {
        time_sent: Time.current,
        term_id: current_term["term_id"],
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
          #user: ProctoruClient::User.from_examity_api(user_info),
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
  def exam(transaction_id)
    begin
      retries ||= 0
      url = config.base_url + "/api/getScheduleInfoAvailableTimesList"
      # dummy_response = "{\"response_code\":3006,\"message\":\"User Appointmentstaus.\",\"timeStamp\":\"2020-06-16T09:40:37Z\",\"appointmentStatusInfo\":{\"currentpage\":1,\"pagecount\":1,\"appointmentStatus\":[{\"userInfo\":{\"userId\":\"skatiyar@alteryx.com\",\"firstName\":\"Sachin\",\"lastName\":\"Katiyar\",\"emailAddress\":\"skatiyar@alteryx.com\"},\"appointmentInfo\":{\"transactionId\":\"12000020021\",\"courseId\":\"86387-3924\",\"courseName\":\"Alteryx-Integration Testing [SANDBOX]\",\"examId\":\"902d7565-0257-4933-8efc-b3a7b58f3449\",\"examName\":\"Integration Testing [SANDBOX]\",\"examURL\":\"https://staging.trueability.com/instances/902d7565-0257-4933-8efc-b3a7b58f3449?assessment_reservation_uuid=true\",\"examDuration\":10,\"examPassword\":\"none\",\"examUserName\":\"skatiyar@alteryx.com\",\"timeZone\":\"2\",\"examDate\":\"2020-06-15T15:00:00\",\"examInstruction\":\"TrueAbility Support Access Procedures for Examity\\n\\nContacting TrueAbility\\nIn order to provide rapid response to any issues during or prior to an exam session, Proctors should contact TrueAbility via the TrueAbility Support channels defined below.\\nTrueAbility support is available 24 x 7, 365.\\n\\nThe Proctor can contact TrueAbility Support through any of the following methods:\\n\\nEmail Support – support@trueability.com\\nPhone Support – 1-866-966-4133\\nProctor support request procedure\\nIf an issue occurs during or prior to the exam session, the Proctor or Examity staff should pause the exam and:\\nEmail or call TrueAbility Support with the following information:\\nCandidate name\\nExam being taken\\nIssue being reported\\nThe TrueAbility Support personnel will begin working on the issue and will:\\nRespond to ticket/call requesting additional information if needed.\\nProvide updates via the ticket/call as the issue is worked.\\nSend a message via ticket/call once the issue is resolved.\\n\",\"status\":\"Active\",\"examLevel\":\"4\",\"examStatus\":\"No-show\",\"flaginfo\":[{\"flagtype\":\"Violation\",\"flagdescription\":\"Candidate invited his friends for a party before the exam was over.\",\"flagtimestamp\":\"2020-06-16T09:40:37Z\"},{\"flagtype\":\"Alert\",\"flagdescription\":\"System was not running for an hour so I fell asleep while waiting for technical team to fix all the issues.\",\"flagtimestamp\":\"2020-06-16T09:40:37Z\"}]}}]}}"

      body = {
        takeitnow: 'N',
        isadhoc: 'Y',
        reservation_no: transaction_id,
        start_date: Time.now
      }
      json = JSON.parse(RestClient.get(url,
                                      body,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))
      check_response_code_for_error(json["response_code"])
      current_page = json["appointmentStatusInfo"]["currentpage"]
      total_pages = json["appointmentStatusInfo"]["pagecount"]
      appt = json["appointmentStatusInfo"]["appointmentStatus"]
      user = appt[0]["userInfo"]
      appointment = appt[0]["appointmentInfo"]
      return {
        user: ProctoruClient::User.from_examity_api(user),
        appointment: ProctoruClient::Appointment.from_examity_api(appointment)
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
    raise ArgumentError.new("Please provide auth_token") unless config.auth_token
    @token = config.auth_token
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

  # Examity sends a response code for every request, some codes represent error conditions
  # we through an error for the error conditions to allow the controller a chance to respond
  def check_response_code_for_error(code)
    code = code.to_i

    error, msg = code_in_error?(code)
    raise ProctoruClient::Error.new(msg, code) if error
  end
end
