require "json"
class BaseTest

  COMMAND = "devops"
  SUCCESS = "\e[32msuccess\e[0m"
  FAILED = "\e[31mfailed\e[0m"
  CONFIGS = ["./devops-client-test.conf"]
  #, "-c ./test_conf1.conf"]

  TITLE_SEPARATOR = "-" * 80
  END_SEPARATOR = "*" * 80 + "\n"

  def title= title
    @title = title
  end

  def run_tests cmds, check=true
    puts
    puts @title
    puts TITLE_SEPARATOR
    cmds.each do |cmd|
      command = create_cmd(cmd)
      s = `#{command}`
      if check
        if $?.success?
          print SUCCESS
        else
          print FAILED
          puts_error s
          exit(1)
        end
      end
      puts
    end
    puts END_SEPARATOR
  end

  def run_test_with_block cmd
    puts
    puts @title
    puts TITLE_SEPARATOR
    command = create_cmd(cmd)
    s = `#{command}`
    if $?.success?
      puts SUCCESS
      if block_given?
        print "Validation block...\t"
        res = yield s
        if res
          puts SUCCESS
        else
          puts FAILED
          puts_error("Validation block returns 'false'")
          exit(-1)
        end
      end
    else
      puts FAILED
      puts_error s
      exit(1)
    end
    puts END_SEPARATOR
  end

  def run_tests_invalid cmds
    puts
    puts @title
    puts TITLE_SEPARATOR
    cmds.each do |cmd|
      command = create_cmd(cmd)
      s = `#{command}`
      if $?.success?
        puts FAILED
        exit(1)
      else
        puts SUCCESS
      end
    end
    puts END_SEPARATOR
  end

  def puts_error str
    puts "\e[31m#{str}\e[0m"
  end

  def puts_warn str
    puts "\e[33m#{str}\e[0m"
  end

  def config= conf
    @config = conf
  end

  def create_cmd cmd
    command = if @config.nil?
      "#{COMMAND} #{cmd}"
    else
      "#{COMMAND} -c #{@config} #{cmd}"
    end
    print "#{command}...\t"
    command
  end

end
