module FileSystemHelpers
  def within_temp_dir(&block)
    Dir.chdir(Dir.mktmpdir, &block)
  end
end
