require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "cc/cli"
require "cc/yaml"

Dir.glob("spec/support/**/*.rb").each(&method(:load))

ENV.delete("CODECLIMATE_DOCKER")
ENV["CODECLIMATE_TMP"] = Dir.mktmpdir
