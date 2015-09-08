require "spec_helper"

module CC::Analyzer
  describe IncludePathsBuilder do
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    let(:cc_excludes) { [] }
    let(:result) {
      CC::Analyzer::IncludePathsBuilder.new(cc_excludes).build
    }

    before do
      system("git init > /dev/null")
    end

    context "when the source directory contains only files that are tracked or trackable in Git" do
      before do
        make_file("root_file.rb")
        make_file("subdir/subdir_file.rb")
      end

      it "returns a single entry for the root" do
        result.sort.must_equal(["./"])
      end
    end

    context "when the source directory contains a file that is not tracked or trackable in Git" do
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

    context "when the source directory contains a directory that is not tracked in Git" do
      before do
        make_file("untrackable_subdir/secret.rb")
        make_file(".gitignore", "untrackable_subdir\n")
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that directory from include_paths" do
        result.include?("untrackable_subdir/secret.rb").must_equal(false)
        result.include?("untrackable_subdir").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end

    context "when the source directory contains a file that is excluded by exclude_paths" do
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

    context "when the source directory contains an unreadable subdirectory" do
      before do
        FileUtils.mkdir("unreadable_subdir", mode: 0000)
        make_file("trackable.rb")
        make_file("subdir/subdir_trackable.rb")
      end

      it "excludes that directory from include_paths" do
        result.include?("unreadable_subdir").must_equal(false)
      end

      it "keeps sibling files and directories in include_paths" do
        %w[subdir/ trackable.rb].each do |trackable_file_or_directory|
          result.include?(trackable_file_or_directory).must_equal(true)
        end
      end
    end
  end
end
