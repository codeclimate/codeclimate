require "rspec/core/rake_task"

desc "Run (quick) specs"
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = "--tag ~slow"
end

desc "Run all specs, including slow ones"
RSpec::Core::RakeTask.new("spec:all")

desc "Run benchmark specs"
RSpec::Core::RakeTask.new("spec:benchmark") do |task|
  task.pattern = "benchmarks/**/*_benchmark.rb"
end

task(default: :spec)
