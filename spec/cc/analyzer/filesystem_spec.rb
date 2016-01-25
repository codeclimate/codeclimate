require "spec_helper"

module CC::Analyzer
  describe Filesystem do
    describe "#exist?" do
      it "returns true for files that exist" do
        root = Dir.mktmpdir
        File.write(File.join(root, "foo.rb"), "")

        filesystem = Filesystem.new(root)

        filesystem.exist?("foo.rb").must_equal(true)
        filesystem.exist?("bar.rb").must_equal(false)
      end
    end

    describe "#read_path" do
      it "returns the content for the given file" do
        root = Dir.mktmpdir
        File.write(File.join(root, "foo.rb"), "Foo")
        File.write(File.join(root, "bar.rb"), "Bar")

        filesystem = Filesystem.new(root)

        filesystem.read_path("foo.rb").must_equal("Foo")
        filesystem.read_path("bar.rb").must_equal("Bar")
      end
    end

    describe "#write_path" do
      it "writes to the filesystem, given a path to a file and content" do
        filesystem = Filesystem.new(Dir.mktmpdir)

        filesystem.write_path("foo.js", "Hello world")

        filesystem.exist?("foo.js").must_equal(true)
        filesystem.read_path("foo.js").must_equal("Hello world")
      end
    end
  end
end
