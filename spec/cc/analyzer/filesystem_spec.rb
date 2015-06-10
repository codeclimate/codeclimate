require "spec_helper"

module CC::Analyzer
  describe Filesystem do
    describe "#exists?" do
      it "returns true for files that exist" do
        root = Dir.mktmpdir
        File.write(File.join(root, "foo.rb"), "")

        filesystem = Filesystem.new(root)

        filesystem.exist?("foo.rb").must_equal(true)
        filesystem.exist?("bar.rb").must_equal(false)
      end
    end

    describe "#files_matching" do
      it "returns files that match the globs" do
        root = Dir.mktmpdir
        File.write("#{root}/foo.js", "Foo")
        File.write("#{root}/foo.rb", "Foo")

        filesystem = Filesystem.new(root)

        filesystem.files_matching(["*.js"]).must_equal(["foo.js"])
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

    describe "#file_paths" do
      it "returns all regular files in the root" do
        root = Dir.mktmpdir
        Dir.mkdir(File.join(root, "foo"))
        Dir.mkdir(File.join(root, "bar"))
        File.write(File.join(root, "foo.rb"), "")
        File.write(File.join(root, "foo", "foo.rb"), "")
        File.write(File.join(root, "foo", "bar.rb"), "")
        File.write(File.join(root, "bar", "foo.rb"), "")
        File.write(File.join(root, "bar", "bar.rb"), "")

        filesystem = Filesystem.new(root)

        filesystem.file_paths.sort.must_equal([
          "foo.rb",
          "foo/foo.rb",
          "foo/bar.rb",
          "bar/foo.rb",
          "bar/bar.rb",
        ].sort)
      end
    end
  end
end
