module FileSystemHelpers
  def within_temp_dir(&block)
    Dir.chdir(Dir.mktmpdir, &block)
  end

  def make_tree(spec)
    paths = spec.split(/\s+/).select(&:present?)
    paths.each { |path| make_file(path, "") }
  end

  def make_file(path, content = "")
    directory = File.dirname(path)

    FileUtils.mkdir_p(directory)
    File.write(path, content)
  end
end
