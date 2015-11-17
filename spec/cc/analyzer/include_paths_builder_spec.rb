require "spec_helper"

module CC::Analyzer
  describe IncludePathsBuilder do
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    let(:builder) { CC::Analyzer::IncludePathsBuilder.new(cc_excludes, cc_includes) }
    let(:cc_excludes) { [] }
    let(:cc_includes) { [] }
    let(:result) { builder.build }

    before do
      system("git init > /dev/null")
      FileUtils.stubs(:readable_by_all?).at_least_once.returns(true)
    end

    describe "when the source directory contains only files that are tracked or trackable in Git" do
      before do
        make_file("root_file.rb")
        make_file("subdir/subdir_file.rb")
      end

      it "returns a single entry for the root" do
        result.sort.must_equal(["./"])
      end
    end

    describe "when the source directory contains a file that is not tracked or trackable in Git" do
      before do
        make_file("untrackable.rb")
        make_file(".gitignore", "untrackable.rb\n")
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that file from include_paths" do
        result.include?("untrackable.rb").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end

    describe "when the source directory contains a directory that is ignored in Git" do
      before do
        make_file("ignored/secret.rb")
        make_file(".gitignore", "ignored\n")
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that directory from include_paths" do
        result.include?("ignored/secret.rb").must_equal(false)
        result.include?("ignored").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end

    describe "when the source directory contains a file that is excluded by exclude_paths" do
      let(:cc_excludes) { ["untrackable.rb"] }

      before do
        make_file("untrackable.rb")
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that file from include_paths" do
        result.include?("untrackable.rb").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end

    describe "when there is a subdirectory that isn't readable by all but is excluded in .codeclimate.yml" do
      let(:cc_excludes) { ["unreadable_subdir/*"] }

      before do
        make_file("unreadable_subdir/secret.rb")
        FileUtils.expects(:readable_by_all?).with("unreadable_subdir").at_least_once.returns(false)
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that directory from include_paths" do
        result.include?("unreadable_subdir/").must_equal(false)
        result.include?("unreadable_subdir/secret.rb").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end

    describe "when there is a subdirectory that isn't readable by all but is excluded in .gitignore" do
      before do
        make_file("unreadable_subdir/secret.rb")
        FileUtils.stubs(:readable_by_all?).with("unreadable_subdir").at_least_once.returns(false)
        make_file(".gitignore", "unreadable_subdir\n")
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that directory from include_paths" do
        result.include?("unreadable_subdir/").must_equal(false)
        result.include?("unreadable_subdir/secret.rb").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end

    describe "when there is a subdirectory that isn't readable by all and isn't excluded in either .codeclimate.yml or .gitignore" do
      before do
        make_file("unreadable_subdir/secret.rb")
        FileUtils.expects(:readable_by_all?).with("unreadable_subdir").at_least_once.returns(false)
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that directory from include_paths" do
        result.include?("./").must_equal(false)
        result.include?("unreadable_subdir/").must_equal(false)
        result.include?("unreadable_subdir/secret.rb").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end

    describe "when there is a file that isn't readable by all but is excluded by .codeclimate.yml" do
      let(:cc_excludes) { ["unreadable.rb"] }

      before do
        make_file("unreadable.rb")
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that file from include_paths" do
        result.include?("./").must_equal(false)
        result.include?("unreadable.rb").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end

    describe "when there is a file that isn't readable by all but is excluded by .gitignore" do
      before do
        make_file("unreadable.rb")
        make_file(".gitignore", "unreadable.rb\n")
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that file from include_paths" do
        result.include?("./").must_equal(false)
        result.include?("unreadable.rb").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end

    describe "when there is a file that isn't readable by all and is not excluded by either .codeclimate.yml or .gitignore" do
      before do
        make_file("subdir/unreadable.rb")
        FileUtils.readable_by_all?(".")
        FileUtils.stubs(:readable_by_all?).with("subdir/unreadable.rb").at_least_once.returns(false)
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "raises an informative error" do
        lambda { builder.build }.must_raise(CC::Analyzer::UnreadableFileError)
      end
    end

    describe "when a symlink points to an ancestor directory" do
      before do
        FileUtils.mkdir("subdir")
        FileUtils.ln_s("../subdir", "subdir/subdir")
      end

      it "doesn't follow the symlink" do
        result.include?("./").must_equal(true)
        result.include?("subdir/subdir/").must_equal(false)
      end
    end

    describe "when cc_include_paths are passed in addition to excludes" do
      let(:cc_excludes) { ["untrackable.rb"] }
      let(:cc_includes) { ["untrackable.rb", "subdir"] }

      before do
        make_file("untrackable.rb")
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
        make_file("subdir/foo.rb")
        make_file("subdir/baz.rb")
      end

      it "includes requested paths" do
        result.include?("subdir/").must_equal(true)
      end

      it "omits requested paths that are excluded by .codeclimate.yml" do
        result.include?("untrackable.rb").must_equal(false)
      end
    end

    describe "when .gitignore is a directory" do
      before do
        FileUtils.mkdir(".gitignore")
      end

      it "skips it entirely" do
        FileUtils.readable_by_all?(".")
        result.include?("./").must_equal(true)
      end
    end

    describe "when analyzing a single file" do
      let(:cc_includes) { ["subdir/subdir_file.rb"] }

      it "returns the file" do
        make_file("root_file.rb")
        make_file("subdir/subdir_file.rb")

        builder.build.must_equal(["subdir/subdir_file.rb"])
      end
    end
  end
end
