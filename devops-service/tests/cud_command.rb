module CudCommand

  HEADERS = {
    "Accept" => "application/json",
    "Content-Type" => "application/json"
  }

  def test_headers path, method="post", accept=true
    m = method.downcase
    if accept
      h = HEADERS.clone
      h["Accept"] = "application/xml"
      self.send("send_#{m}", path, {}, h, 406)
    end

    h = HEADERS.clone
    h.delete("Content-Type")
    self.send("send_#{m}", path, {}, h, 415)
  end

  def test_request path, obj, method="post", exclude=nil
    m = method.downcase
    [{}, [], ""].each do |o|
      next if o.class == exclude
      self.send("send_#{m}", path, o, HEADERS, 400) unless exclude.is_a?(Hash)
    end
    self.send("send_#{m}", path, nil, HEADERS, 400)
    return if exclude == obj.class
    obj.keys.each do |key|
      buf = obj.clone
      buf.delete(key)
      self.send("send_#{m}", path, buf, HEADERS, 400)
      buf[key] = ""
      self.send("send_#{m}", path, buf, HEADERS, 400)
      buf[key] = {}
      self.send("send_#{m}", path, buf, HEADERS, 400)
      buf[key] = []
      self.send("send_#{m}", path, buf, HEADERS, 400)
    end
  end

  def test_auth path, obj, empty_obj_code=400, method="post"
    m = method.downcase
    read_only_privileges
    self.send("send_#{m}", path, {}, HEADERS, 401)
    self.send("send_#{m}", path, obj, HEADERS, 401)

    empty_privileges
    self.send("send_#{m}", path, {}, HEADERS, 401)
    self.send("send_#{m}", path, obj, HEADERS, 401)

    write_only_privileges
    self.send("send_#{m}", path, {}, HEADERS, empty_obj_code)

    self.username = ROOTUSER
    self.send("send_#{m}", path, {}, HEADERS, empty_obj_code)

    all_privileges
  end

end
