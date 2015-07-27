require "minitest/spec"
require "minitest/autorun"
require "minitest/reporters"
require "mocha/mini_test"
require "cc/cli"
require "cc/yaml"

Dir.glob("spec/support/**/*.rb").each(&method(:load))

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

ENV['FILESYSTEM_DIR'] = '.'
