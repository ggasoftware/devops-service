module ListCommand

  def list path, params=nil, status=200
    all_privileges
#    list_send(path, status, 406, params)

    cmd = ""
    path.split("/").each do |s|
      cmd += "/" + s
      if cmd == "/" + path
        list_send(cmd, status)
      else
        self.get cmd
        self.check_status 404
      end
    end

    read_only_privileges
    list_send(path, status, params)
    write_only_privileges
    list_send(path, 401, params)
    empty_privileges
    list_send(path, 401, params)
    self.username = ROOTUSER
    list_send(path, status, params)
  end

  def list_deny
    empty_privileges
    cnt = 0
    begin
      yield
      if cnt == 0
        write_only_privileges
        cnt = 1
        raise RangeError
      end
    rescue RangeError
      retry
    end

  end

  def list_providers cmd, as_ok=401, as_not_found=401
    all_privileges
    check_provider cmd

    read_only_privileges
    check_provider cmd

    write_only_privileges
    check_provider cmd, as_ok, as_not_found, 401

    empty_privileges
    check_provider cmd, as_ok, as_not_found, 401

    self.username = ROOTUSER
    check_provider cmd
  end

  def check_provider cmd, ok_status=200, not_found_status=404, auth_not_found=406
    #js = (ok_status == 200 ? 406 : ok_status)
    PROVIDERS.each do |p|
      list_send(cmd.gsub(":provider", p), ok_status)
    end
    path = ""
    st = not_found_status
    cmd.split("/").each do |s|
      path += "/" + s
      if path == "/" + cmd
        list_send(path, st)
      else
        self.get path
        self.check_status 404
      end
    end
  end

  def list_send path, status=200, params=nil
    self.get path, params, {"Accept" => "application/xml"}
    self.check_status 406
    self.get path, params, {"Accept" => "application/json"}
    self.check_status status
    self.check_type :json if status == 200
  end
end
