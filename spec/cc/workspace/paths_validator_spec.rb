require "spec_helper"

class CC::Workspace
  describe PathsValidator do
    include FileSystemHelpers

    describe "#run" do
      it "validates paths as simple and relative" do
        within_temp_dir do
          make_tree <<-EOM
            foo.rb
            foo/bar.rb
          EOM

          expect_invalid(".")
          expect_invalid("..")
          expect_invalid("./")
          expect_invalid("../")
          expect_invalid("./foo.rb")
          expect_invalid("./foo/bar.rb")

          expect_valid("foo.rb")
          expect_valid("foo/bar.rb")
        end
      end
    end

    def expect_valid(path)
      validator = PathsValidator.new([path])
      validator.run # nothing raised
    end

    def expect_invalid(path)
      action = ->() do
        validator = PathsValidator.new([path])
        validator.run
      end

      action.must_raise(ArgumentError)
    end
  end
end

