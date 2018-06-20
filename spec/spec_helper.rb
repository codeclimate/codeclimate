require "simplecov"
require "tempfile"
SimpleCov.start do
  add_filter "/spec/"
end

require "cc/cli"

Dir.glob("spec/support/**/*.rb").each(&method(:load))

ENV.delete("CODECLIMATE_DOCKER")
ENV["CODECLIMATE_TMP"] = Dir.mktmpdir

RSpec.configure do |config|
  config.before(:example, :focus) { raise "Should not commit focused specs" } if ENV["CI"]
  config.filter_run focus: true
  config.alias_example_to :fit, focus: true
  config.run_all_when_everything_filtered = true
end
