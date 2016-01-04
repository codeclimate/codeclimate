require "tmpdir"
require "posix-spawn"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

module SpecHelpers
  def write_codeclimate_yaml(content)
    File.write(".codeclimate.yml", content)
  end

  def run_validate_config(*args)
    POSIX::Spawn::Child.new("#{ROOT}/bin/run #{args.join(" ")}")
  end
end

RSpec.configure do |conf|
  conf.include(SpecHelpers)
  conf.around(:each) do |spec|
    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        spec.run
      end
    end
  end
end
