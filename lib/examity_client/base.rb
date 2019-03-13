class ExamityClient::Base

  # This API doesn't use HTTP Codes to properly indicate errors, we must rely
  # on the message and code id in the response
  STATUS_CODES = {
    200 => {statusCode: 200, message: "OK"},
    203	=> {statusCode: 203, message: "Invalid Credentials provided."},
    400	=> {statusCode: 400, message: "Invalid parameter(s) or parameter(s) is empty."},
    401	=> {statusCode: 401, message: "Invalid access token."},
    402	=> {statusCode: 402, message: "No header."},
    500	=> {statusCode: 500, message: "Internal server error, please contact developers@examity.com"},

    1000 => { statusCode: 1000, message: "User details.", error: false},
    1001 => { statusCode: 1001, message: "User added successfully.", error: false },
    1002 => { statusCode: 1002, message: "User already exists.", error: true },
    1003 => { statusCode: 1003, message: "User details updated successfully.", error: false },
    1004 => { statusCode: 1004, message: "User details not found.", error: true },
    1005 => { statusCode: 1005, message: "Error while updating user details.", error: true },
    1006 => { statusCode: 1006, message: "User removed successfully.", error: false },
    1007 => { statusCode: 1007, message: "Error while removing user details.", error: true },
    1008 => { statusCode: 1008, message: "User information not avaliable in current page.", error: true},

    2000 => {statusCode: 2000, message: "Exam details.", error: false},
    2001 => {statusCode: 2001, message: "Exam details added successfully.", error: false},
    2002 => {statusCode: 2002, message: "Exam details already exists.", error: true},
    2003 => {statusCode: 2003, message: "Exam details updated successfully.", error: false},
    2004 => {statusCode: 2004, message: "Error while updating exam details.", error: true},
    2005 => {statusCode: 2005, message: "Course details not avaliable in current page.", error: true},
    2006 => {statusCode: 2006, message: "Error while removing exam details.", error: true},
    2007 => {statusCode: 2007, message: "Exam removed successfully.", error: false},
    2008 => {statusCode: 2008, message: "Course details not found.", error: true},

    3000 => {statusCode: 3000, message: "Enrollment details.", error: false},
    3001 => {statusCode: 3001, message: "User enrolled successfully.", error: false},
    3002 => {statusCode: 3002, message: "User already enrolled for the exam.", error: true},
    3003 => {statusCode: 3003, message: "User enrollement removed successfully.", error: false},
    3004 => {statusCode: 3004, message: "Error while removing user enrollment from the exam.", error: true},
    3005 => {statusCode: 3005, message: "User has no enrollments for the course.", error: true},
    3006 => {statusCode: 3006, message: "User Appointmentstaus.", error: false},
    3007 => {statusCode: 3007, message: "Enrollments not avaliable for the course.", error: true},

    4000 => {statusCode: 4000, message: "Avaliable ExamTimes.", error: false},
    4001 => {statusCode: 4001, message: "ExamTime information not avaliable.", error: true},
    4002 => {statusCode: 4002, message: "Avaliable Timezones.", error: false},
    4003 => {statusCode: 4003, message: "Invalid timezone provided.", error: true},
    4004 => {statusCode: 4004, message: "Exam scheduled successfully.", error: false},
    4005 => {statusCode: 4005, message: "Exam can not be scheduled prior to today's date.", error: true},
    4006 => {statusCode: 4006, message: "Exam already scheduled in current time window.", error: true},
    4007 => {statusCode: 4007, message: "Exam is already scheduled on appointment date.", error: true},
    4008 => {statusCode: 4008, message: "Exam cancelled successfully.", error: false},
    4009 => {statusCode: 4009, message: "Exam can only cancel when it is in scheduled status.", error: true},
    4011 => {statusCode: 4011, message: "Unable to schedule /reschedule exam.", error: true},
    4012 => {statusCode: 4012, message: "Transaction details not found.", error: true},
    4013 => {statusCode: 4013, message: "Exam rescheduled successfully.", error: false},
    4014 => {statusCode: 4014, message: "Exam already scheduled in current time window. Rescheduling is not allowed.", error: true},
    4015 => {statusCode: 4015, message: "Exam can not be rescheduled prior to today's date.", error: true},
    4016 => {statusCode: 4016, message: "Exam is already in progress. Rescheduling is not allowed.", error: true},

    5000 => {statusCode: 5000, messasge: "Authentication."},
    5001 => {statusCode: 5001, message: "Invalid Content-Type."},
  }

  def code_in_error?(code)
    code = code.to_i
    details = STATUS_CODES[code]
    if details.nil?
      return [true, "Invalid response code"]
    else
      return [details[:error], details[:message]]
    end
  end
end
