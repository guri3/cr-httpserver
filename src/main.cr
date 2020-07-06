require "socket"
require "./http_request"
require "./http_response"

server = TCPServer.new("localhost", 1234)
loop do
  server.accept do |client|
    http_request = HttpRequest.new client
    puts http_request.getHeader
    puts http_request.getBody

    http_response = uninitialized HttpResponse
    if http_request.is_get_method
      if File.exists?("html/" + http_request.get_path)
        http_response = HttpResponse.new "200 OK"
        http_response.add_header("Content-Type", "text/html")
        http_response.set_body(File.read_lines("html/" + http_request.get_path).join("\n"))
      else
        http_response = HttpResponse.new "404 Not Found"
        http_response.add_header("Content-Type", "text/html")
        http_response.set_body(File.read_lines("html/404.html").join("\n"))
      end
    end

    client << http_response.write_to
  end
end
