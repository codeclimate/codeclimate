require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "minitest/spec"
require "minitest/autorun"
require "minitest/reporters"
require "minitest/around/spec"
require "mocha/mini_test"
require "safe_yaml"
require "cc/cli"
require "cc/yaml"

Dir.glob("spec/support/**/*.rb").each(&method(:load))

SafeYAML::OPTIONS[:default_mode] = :safe

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

ENV["FILESYSTEM_DIR"] = "."
