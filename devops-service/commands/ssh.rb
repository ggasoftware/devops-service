module SshCommands

  def ssh_test server, params
    res, code = ssh_execute(server, "test #{params}")
    code == 0
  end

  def ssh_execute server, cmd
    key_path = File.join(DevopsCid.config[:keys_dir], server[:private_key])
    res = `ssh -i #{key_path} #{server[:remote_user]}@#{server[:host]} '#{cmd}'`
    return res, $?
  end

end
