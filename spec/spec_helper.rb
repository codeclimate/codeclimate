require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "cc/cli"
require "cc/yaml"

Dir.glob("spec/support/**/*.rb").each(&method(:load))

ENV.delete("CODECLIMATE_DOCKER")
ENV["CODECLIMATE_TMP"] = Dir.mktmpdir
