require "rake/testtask"
require "bundler/gem_tasks"

Rake::TestTask.new do |t|
  t.test_files = Dir.glob("spec/**/*_spec.rb")
  t.libs = %w[lib spec]
end

Rake::TestTask.new("benchmarks") do |t|
  t.test_files = Dir.glob("benchmarks/**/*_benchmark.rb")
  t.libs = %w[lib spec benchmarks]
end

task(default: :test)
