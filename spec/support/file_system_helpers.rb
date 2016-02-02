module FileSystemHelpers
  def within_temp_dir(&block)
    Dir.chdir(Dir.mktmpdir, &block)
  end

  def make_filesystem
    CC::Analyzer::Filesystem.new(".")
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

  def write_fixture_source_files
    File.write("cool.rb", "class Cool; end")
    FileUtils.mkdir_p("js")
    File.write("js/foo.js", "function() {}")
    FileUtils.mkdir_p("stylesheets")
    File.write("stylesheets/main.css", ".main {}")
    FileUtils.mkdir_p("vendor/jquery")
    File.write("vendor/foo.css", ".main {}")
    File.write("vendor/jquery/jquery.css", ".main {}")
    FileUtils.mkdir_p("spec/models")
    File.write("spec/spec_helper.rb", ".main {}")
    File.write("spec/models/foo.rb", ".main {}")
    FileUtils.mkdir_p("config")
    File.write("config/foo.rb", ".main {}")
  end
end

RSpec.configure do |conf|
  conf.include(FileSystemHelpers)
end
