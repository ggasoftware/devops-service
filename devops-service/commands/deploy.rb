module DeployCommands

  def deploy_server out, server, cert_path
    out << "\nRun chef-client on '#{server.chef_node_name}'"
    cmd = (server.remote_user == "root" ? "chef-client" : "sudo chef-client")
    ip = if server.public_ip.nil?
      server.private_ip
    else
      out << "Public IP detected\n"
      server.public_ip
    end
    cmd = "ssh -t -i #{cert_path} #{server.remote_user}@#{ip} \"#{cmd}\""
    out << "\nCommand: '#{cmd}'\n"
    status = nil
    IO.popen(cmd + " 2>&1") do |c|
      buf = ""
      while line = c.gets do
        out << line
        buf = line
      end
      c.close
      status = $?.to_i
      r = buf.scan(/exit\scode\s([0-9]{1,3})/)[0]
      unless r.nil?
        status = r[0].to_i
      end
    end
    return status
  end

end
