require "spec_helper"

module CC::Analyzer
  describe Filesystem do
    describe "#exist?" do
      it "returns true for files that exist" do
        root = Dir.mktmpdir
        File.write(File.join(root, "foo.rb"), "")

        filesystem = Filesystem.new(root)

        expect(filesystem.exist?("foo.rb")).to eq(true)
        expect(filesystem.exist?("bar.rb")).to eq(false)
      end
    end

    describe "#read_path" do
      it "returns the content for the given file" do
        root = Dir.mktmpdir
        File.write(File.join(root, "foo.rb"), "Foo")
        File.write(File.join(root, "bar.rb"), "Bar")

        filesystem = Filesystem.new(root)

        expect(filesystem.read_path("foo.rb")).to eq("Foo")
        expect(filesystem.read_path("bar.rb")).to eq("Bar")
      end
    end

    describe "#write_path" do
      it "writes to the filesystem, given a path to a file and content" do
        filesystem = Filesystem.new(Dir.mktmpdir)

        filesystem.write_path("foo.js", "Hello world")

        expect(filesystem.exist?("foo.js")).to eq(true)
        expect(filesystem.read_path("foo.js")).to eq("Hello world")
      end
    end
  end
end
