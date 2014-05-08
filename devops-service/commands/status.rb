module StatusCommands

  def create_status status
    s = if status.empty?
      1
    else
      b = 0
      status.each{|s| b |= s}
      b
    end
    return "\n-- Status: #{s} --"
  end

  def time_diff_milli start, finish
    ((finish - start) * 1000.0).to_i
  end

  def time_diff_milli_s start, finish
    time_diff_milli(start, finish).to_s + "ms"
  end

  def time_diff start, finish
    (finish - start).to_i
  end

  def time_diff_s start, finish
    time_diff(start, finish).to_s + "s"
  end

end
