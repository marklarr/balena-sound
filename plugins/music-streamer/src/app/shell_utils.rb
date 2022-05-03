module ShellUtils
  def self.spawn(*args)
    Process.spawn(*args)
  end

  def self.wait(*args)
    Process.wait(*args)
  end

  def self.exec(cmd)
    `#{cmd}`
  end

  def self.popen3(*args)
    Open3.popen3(*args)
  end
end

