require "minitest/spec"
require "minitest/autorun"
require "minitest/reporters"
require "mocha/mini_test"
require "support/factory"
require "cc/cli"
require "cc/yaml"

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

ENV['FILESYSTEM_DIR'] = '.'
