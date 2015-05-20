require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = Dir.glob('spec/**/*_spec.rb')
  t.libs = ["lib", "spec"]
end

task(default: :test)
