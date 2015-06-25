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

    describe "#any?" do
      it "returns true if any files match any extensions" do
        root = Dir.mktmpdir
        File.write(File.join(root, "foo.rb"), "")
        File.write(File.join(root, "foo.js"), "")
        Dir.mkdir(File.join(root, "foo"))
        File.write(File.join(root, "foo", "foo.sh"), "")
        File.write(File.join(root, "foo", "bar.php"), "")

        filesystem = Filesystem.new(root)

        filesystem.any? { |p| /\.sh$/ =~ p }.must_equal(true)
      end

      it "returns false if no files match any extensions" do
        root = Dir.mktmpdir
        File.write(File.join(root, "foo.rb"), "")
        File.write(File.join(root, "foo.js"), "")
        Dir.mkdir(File.join(root, "foo"))
        File.write(File.join(root, "foo", "foo.sh"), "")
        File.write(File.join(root, "foo", "bar.php"), "")

        filesystem = Filesystem.new(root)

        filesystem.any? { |p| /\.hs$/ =~ p }.must_equal(false)
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
