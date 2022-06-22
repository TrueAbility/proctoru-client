require "logger"
class ExamityClient::Client < ExamityClient::Base
  attr_accessor :config, :token

  def initialize(config = ExamityClient.configuration)
    @config = config
    logger("Configured: #{config.to_json(except: ["encryption_key", "secret_key"])}")
  end

  def configure
    yield config
  end

  # pass through for sso token
  def sso_token(email)
    ExamityClient::SingleSignOn::token(config.encryption_key, email)
  end

  # GET
  def timezones
    begin
      retries ||= 0
      url = config.base_url + "/examity/api/timezone"
      retries ||= 0
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))

      check_response_code_for_error(json["statusCode"])

      json["timezoneInfo"]
    rescue RestClient::Unauthorized => e
      get_token
      retry if (retries += 1) < 2
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"])
    end
  end

  # POST
  def examtimes(user, time_zone_id, exam_date)
    begin
      retries ||= 0
      url = config.base_url + "/examity/api/examtimes"
      body = {
        userId: user.id,
        timeZone: time_zone_id,
        examDate: exam_date
      }

      json = JSON.parse(RestClient.post(url,
                                        body.to_json,
                                        {
                                          authorization: token,
                                          content_type: "application/json"
                                        }))

      check_response_code_for_error(json["statusCode"])

      json["timeInfo"]
    rescue RestClient::Unauthorized => e
      get_token
      retry if (retries += 1) < 2
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"])
    end
  end

  # POST
  def schedule(user, course, exam)
    begin
      retries ||= 0
      url = config.base_url + "/examity/api/schedule"
      body = {
        userInfo: {
          userId: user.id,
          firstName: user.first_name,
          lastName: user.last_name,
          emailAddress: user.email,
        },
        courseInfo: {
          courseId: course.id,
          courseName: course.name,
        },
        examInfo: {
          examId: exam.id,
          examName: exam.name,
          examURL: exam.url,
          examDuration: exam.duration_in_minutes,
          examPassword: exam.password,
          examUserName: exam.username,
          timeZone: exam.time_zone,
          examDate: exam.date,
          examInstruction: exam.instructions,
          examLevel: exam.level,
        }}

      logger("Schedule Request: #{body.to_json}")

      json = JSON.parse(RestClient.post(url,
                                        body.to_json,
                                        {
                                          authorization: token,
                                          content_type: "application/json"
                                        }))

      check_response_code_for_error(json["statusCode"])

      appt_info = json["appointmentInfo"]
      ExamityClient::Appointment.from_examity_api(appt_info)
    rescue RestClient::Unauthorized => e
      get_token
      retry if (retries += 1) < 2
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"], json["statusCode"])
    end
  end

  # PUT
  def reschedule(transaction_id, course, exam)
    begin
      retries ||= 0
      url = config.base_url + "/examity/api/reschedule"
      body = {
        transactionId: transaction_id,
        courseInfo: {
          courseId: course.id,
          courseName: course.name,
        },
        examInfo: {
          examId: exam.id,
          examName: exam.name,
          examURL: exam.url,
          examDuration: exam.duration_in_minutes,
          examPassword: exam.password,
          examUserName: exam.username,
          timeZone: exam.time_zone,
          examDate: exam.date,
          examInstruction: exam.instructions,
          examLevel: exam.level,
        }}

      logger("Reschedule Request: #{body.to_json}")

      json = JSON.parse(RestClient.put(url,
                                       body.to_json,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))

      check_response_code_for_error(json["statusCode"])

      appt_info = json["appointmentInfo"]
      ExamityClient::Appointment.from_examity_api(appt_info)
    rescue RestClient::Unauthorized => e
      get_token
      retry if (retries += 1) < 2
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"], json["statusCode"])
    end
  end

  # DELETE
  def cancel(transaction_id)
    begin
      retries ||= 0
      url = config.base_url + "/examity/api/cancel/#{transaction_id}"

      logger("Cancel Request: #{url.to_json}")

      json = JSON.parse(RestClient.delete(url,
                                          {
                                            authorization: token,
                                            content_type: "application/json"
                                          }))

      check_response_code_for_error(json["statusCode"])

      appt_info = json["appointmentInfo"]
      ExamityClient::Appointment.from_examity_api(appt_info)
    rescue RestClient::Unauthorized => e
      get_token
      retry if (retries += 1) < 2
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"], json["statusCode"])
    end
  end

  # POST
  # TODO this doesn't handle paging automatically
  def exams_for_user(course, user, page = 1)
    begin
      retries ||= 0
      url = config.base_url + "/examity/api/exams/#{page}"
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))

      check_response_code_for_error(json["statusCode"])

      page_info = json["appointmentStatusInfo"]
      user_info = json["appointmentStatusInfo"]["userInfo"]
      exams_info = json["examInfo"]
      @pagination = {
        current: page_info["currentpage"],
        total: page_info["pagecount"],
      }
      @user = User.from_examity_api(user_info)
      @exams = exams_info.collect do |j|
        ExamityClient::Appointment.from_examity_api(j)
      end

      return {user: @user, exams: @exams, pagination: @pagination}
    rescue RestClient::Unauthorized => e
      get_token
      retry if (retries += 1) < 2
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"])
    end
  end

  # GET
  def exams_for_course(course, page = 1)
    begin
      retries ||= 0
      url = config.base_url + "/examity/api/course/#{course.id}/page/#{page}"
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))

      check_response_code_for_error(json["statusCode"])

      page_info = json["appointmentStatusInfo"]
      exams_info = json["appointmentStatusInfo"]["appointmentStatus"]
      @pagination = {
        current: page_info["currentpage"],
        total: page_info["pagecount"],
      }


      @exams = exams_info.collect do |j|
        user_info = json["appointmentStatusInfo"]["appointmentStatus"]["userInfo"]
        appt_info = json["appointmentStatusInfo"]["appointmentStatus"]["appointmentInfo"]
        {
          user: ExamityClient::User.from_examity_api(user_info),
          exams: appt_info.collect do |j|
            ExamityClient::Appointment.from_examity_api(j)
          end
        }
      end

      @exams[:pagination] = @pagination
      @exams
    rescue RestClient::Unauthorized => e
      get_token
      retry if (retries += 1) < 2
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"])
    end
  end

  # GET
  def exam(transaction_id)
    begin
      retries ||= 0
      url = config.base_url + "/examity/api/exams/#{transaction_id}"
      # dummy_response = "{\"statusCode\":3006,\"message\":\"User Appointmentstaus.\",\"timeStamp\":\"2020-06-16T09:40:37Z\",\"appointmentStatusInfo\":{\"currentpage\":1,\"pagecount\":1,\"appointmentStatus\":[{\"userInfo\":{\"userId\":\"skatiyar@alteryx.com\",\"firstName\":\"Sachin\",\"lastName\":\"Katiyar\",\"emailAddress\":\"skatiyar@alteryx.com\"},\"appointmentInfo\":{\"transactionId\":\"12000020021\",\"courseId\":\"86387-3924\",\"courseName\":\"Alteryx-Integration Testing [SANDBOX]\",\"examId\":\"902d7565-0257-4933-8efc-b3a7b58f3449\",\"examName\":\"Integration Testing [SANDBOX]\",\"examURL\":\"https://staging.trueability.com/instances/902d7565-0257-4933-8efc-b3a7b58f3449?assessment_reservation_uuid=true\",\"examDuration\":10,\"examPassword\":\"none\",\"examUserName\":\"skatiyar@alteryx.com\",\"timeZone\":\"2\",\"examDate\":\"2020-06-15T15:00:00\",\"examInstruction\":\"TrueAbility Support Access Procedures for Examity\\n\\nContacting TrueAbility\\nIn order to provide rapid response to any issues during or prior to an exam session, Proctors should contact TrueAbility via the TrueAbility Support channels defined below.\\nTrueAbility support is available 24 x 7, 365.\\n\\nThe Proctor can contact TrueAbility Support through any of the following methods:\\n\\nEmail Support – support@trueability.com\\nPhone Support – 1-866-966-4133\\nProctor support request procedure\\nIf an issue occurs during or prior to the exam session, the Proctor or Examity staff should pause the exam and:\\nEmail or call TrueAbility Support with the following information:\\nCandidate name\\nExam being taken\\nIssue being reported\\nThe TrueAbility Support personnel will begin working on the issue and will:\\nRespond to ticket/call requesting additional information if needed.\\nProvide updates via the ticket/call as the issue is worked.\\nSend a message via ticket/call once the issue is resolved.\\n\",\"status\":\"Active\",\"examLevel\":\"4\",\"examStatus\":\"No-show\",\"flaginfo\":[{\"flagtype\":\"Violation\",\"flagdescription\":\"Candidate invited his friends for a party before the exam was over.\",\"flagtimestamp\":\"2020-06-16T09:40:37Z\"},{\"flagtype\":\"Alert\",\"flagdescription\":\"System was not running for an hour so I fell asleep while waiting for technical team to fix all the issues.\",\"flagtimestamp\":\"2020-06-16T09:40:37Z\"}]}}]}}"

      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json"
                                       }))

      check_response_code_for_error(json["statusCode"])

      current_page = json["appointmentStatusInfo"]["currentpage"]
      total_pages = json["appointmentStatusInfo"]["pagecount"]
      appt = json["appointmentStatusInfo"]["appointmentStatus"]
      user = appt[0]["userInfo"]
      appointment = appt[0]["appointmentInfo"]
      return {
        user: ExamityClient::User.from_examity_api(user),
        appointment: ExamityClient::Appointment.from_examity_api(appointment)
      }

    rescue RestClient::Unauthorized => e
      get_token
      retry if (retries += 1) < 2
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"])
    end
  end

  # POST
  def get_token
    raise ArgumentError.new("Please provide base_url") unless config.base_url
    raise ArgumentError.new("Please provide client_id") unless config.client_id
    raise ArgumentError.new("Please provide secret_key") unless config.secret_key

    begin
      url = config.base_url + "/examity/api/token"
      body = {
        clientID: config.client_id,
        secretKey: config.secret_key
      }

      json = JSON.parse(RestClient.post(url,
                                        body.to_json,
                                        {
                                          content_type: "application/json",
                                        }))

      check_response_code_for_error(json["statusCode"])

      @token = json["authInfo"]["access_token"]
      @token
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"])
    end
  end

  # GET
  def user_profile(user)
    begin
      retries ||= 0
      url = config.base_url + "/examity/api/user/#{user.id}/profile"
      json = JSON.parse(RestClient.get(url,
                                       {
                                         authorization: token,
                                         content_type: "application/json",
                                       }))

      check_response_code_for_error(json["statusCode"])

      ExamityClient::User.from_examity_api(json["profileInfo"])
    rescue RestClient::Unauthorized => e
      get_token
      retry if (retries += 1) < 2
    rescue RestClient::Exception => e
      logger("Exception #{e} -- #{e.response}")
      json = JSON.parse(e.http_body)
      raise ExamityClient::Error.new(json["errorInfo"])
    end
  end

  private
  def logger(message)
    message = "EXAMITY CLIENT: #{message}"
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

    @logger.warn("ExamityClient: #{message}")
  end

  # Examity sends a response code for every request, some codes represent error conditions
  # we through an error for the error conditions to allow the controller a chance to respond
  def check_response_code_for_error(code)
    code = code.to_i

    error, msg = code_in_error?(code)
    raise ExamityClient::Error.new(msg, code) if error
  end

end
