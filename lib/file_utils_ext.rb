require 'fileutils'

module FileUtils
  def self.readable_by_all?(path)
    (File.stat(path).mode & 004) != 0
  end
end
