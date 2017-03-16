$LOAD_PATH.unshift(File.join(__FILE__, "../lib"))
VERSION = File.read(File.expand_path("../VERSION", __FILE__))

Gem::Specification.new do |s|
  s.name = "codeclimate"
  s.version = VERSION
  s.summary = "Code Climate CLI"
  s.license = "MIT"
  s.authors = "Code Climate"
  s.email = "hello@codeclimate.com"
  s.homepage = "https://codeclimate.com"
  s.description = "Code Climate command line tool"

  s.files = Dir["lib/**/*.rb"] + Dir["bin/*"] + Dir.glob("config/**/*", File::FNM_DOTMATCH)
  s.require_paths = ["lib"]
  s.bindir = "bin"
  s.executables = %w(codeclimate-init)

  s.add_dependency "activesupport", ">= 4.2.1", "< 5.1"
  s.add_dependency "tty-spinner", "~> 0.1.0"
  s.add_dependency "codeclimate-yaml", "~> 0.12.0"
  s.add_dependency "highline", "~> 1.7", ">= 1.7.2"
  s.add_dependency "posix-spawn", "~> 0.3", ">= 0.3.11"
  s.add_dependency "pry", "~> 0.10.1"
  s.add_dependency "rainbow", "~> 2.0", ">= 2.0.0"
  s.add_dependency "redcarpet", "~> 3.2"
  s.add_dependency "uuid", "~> 2.3"
end
