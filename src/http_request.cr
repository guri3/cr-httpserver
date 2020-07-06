class HttpRequest
  def initialize(client : IO)
    @header = [] of String | Nil
    @body = [] of String | Nil
    self.readHeader(client)
    self.readBody(client)
  end

  def getHeader
    @header.join
  end

  def getBody
    @body.join
  end

  def is_get_method : Bool
    @header.each do |h|
      return true if h.as(String).starts_with?("GET")
    end
    return false
  end

  def get_path : String
    path = @header.first.as(String).split(" ")[1]
    if path == "/"
      return "index.html"
    else
      return path.gsub("/") { "" }
    end
  end

  private def readHeader(client : IO) : Nil
    content_length = 0
    line = client.gets
    while line != nil && !line.as(String).empty?
      @header << line.as(String) + "\n"
      line = client.gets
    end
    @header << "\n"
  end

  private def readBody(client : IO) : Nil
    if (self.isChunkedTransfer)
      self.readBodyByChunkedTransfer(client)
    else
      self.readBodyByContentLength(client)
    end
  end

  private def isChunkedTransfer : Bool
    @header.each do |h|
      return true if h.as(String) == "Transfer-Encoding: chunked\n"
    end
    return false
  end

  private def readBodyByChunkedTransfer(client : IO) : Nil
    client.gets
    chunk_size = client.gets.as(String).chomp.to_i(16)
    while chunk_size != 0
      @body << client.gets(chunk_size).as(String)
      client.gets
      chunk_size = client.gets.as(String).chomp.to_i(16)
    end
  end

  private def readBodyByContentLength(client : IO) : Nil
      content_length = self.get_content_length
      if content_length.as(Int) > 0
        @body << client.gets(content_length + 1).as(String)
      end
  end

  private def get_content_length
    @header.each do |h|
      if h.as(String).starts_with?("Content-Length")
        return h.as(String).split(':')[1].lstrip.to_i
      end
    end
    return 0
  end
end
