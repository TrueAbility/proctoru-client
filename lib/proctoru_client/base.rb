class ProctoruClient::Base
  STATUS_CODES = {
    1 => {statusCode: 200, message: "OK"},
    2	=> {statusCode: 500, message: "Internal server error.", error: true },
    3	=> {statusCode: 400, message: "Bad Request.", error: true }
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
