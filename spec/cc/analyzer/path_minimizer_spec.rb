require "spec_helper"

module CC::Analyzer
  describe PathMinimizer do
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "#minimize" do
      describe "when all files match" do
        it "returns ./" do
          make_file("lib/tasks/foo.rb")
          make_file("foo.rb")

          minimizer = PathMinimizer.new(["lib", "lib/tasks", "lib/tasks/foo.rb", "foo.rb"])
          minimizer.minimize.must_equal(["./"])
        end
      end

      it "breaks down lists of files into paths" do
        make_file("lib/tasks/foo.rb")
        make_file("foo.rb")

        minimizer = PathMinimizer.new(["lib", "lib/tasks", "lib/tasks/foo.rb"])
        minimizer.minimize.must_equal(["lib/"])
      end

      it "breaks down abitrarily nested lists of files into paths" do
        make_file("lib/tasks/foo.rb")
        make_file("lib/tasks/bar/foo.rb")
        make_file("lib/tasks/bar/baz/foo.rb")
        make_file("lib/tasks/foo.js")
        make_file("foo.rb")

        minimizer = PathMinimizer.new([
          "lib",
          "lib/tasks",
          "lib/tasks/foo.rb",
          "lib/tasks/bar",
          "lib/tasks/bar/foo.rb",
          "lib/tasks/bar/baz",
          "lib/tasks/bar/baz/foo.rb"
        ])

        minimizer.minimize.must_equal(["lib/tasks/foo.rb", "lib/tasks/bar/"])
      end
    end
  end
end
