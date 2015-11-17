require "spec_helper"

module CC::Analyzer
  describe PathPatterns do
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "#entries" do
      it "filters out trailing slashes" do
        make_file("lib/foo.rb")

        paths = PathEntries.new("lib/").entries

        paths.sort.must_equal(["lib", "lib/foo.rb"])
      end

      it "filters works without trailing slashes" do
        make_file("lib/foo.rb")

        paths = PathEntries.new("lib").entries

        paths.sort.must_equal(["lib", "lib/foo.rb"])
      end
    end
  end
end
