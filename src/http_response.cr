class HttpResponse
  def initialize(status : String)
    @status = status
    @headers = [] of String
    @body = ""
  end

  def add_header(header : String, value : String) : Nil
    @headers << header + ": " + value
  end

  def set_body(body : String) : Nil
    @body = body
  end

  def write_to : String
    output = "HTTP/1.1 " + @status + "\n"
    @headers.each do |header|
      output += header + "\n"
    end
    output += "\n"
    output += @body
  end
end
