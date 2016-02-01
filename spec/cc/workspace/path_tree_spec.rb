require "spec_helper"

class CC::Workspace
  describe PathTree do
    include FileSystemHelpers

    it "doesn't needlessly descend if nothing excluded" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.new(".")
        tree.all_paths.must_equal ["./"]
      end
    end

    it "excludes files, descending as needed" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.new(".")
        tree.exclude_paths([".git/refs", "code/a/bar.rb"])
        tree.all_paths.sort.must_equal [".git/FETCH_HEAD", "code/a/baz.rb", "code/foo.rb", "foo.txt", "lib/"]
      end
    end

    it "includes files, descending as needed" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.new(".")
        tree.include_paths([".git/refs/", "code/"])
        tree.all_paths.sort.must_equal [".git/refs/", "code/"]
      end
    end

    it "excludes files after explicit includes" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.new(".")
        tree.include_paths([".git/refs/", "code/"])
        tree.exclude_paths([".git/refs/heads/master", "code/a/bar.rb"])
        tree.all_paths.sort.must_equal ["code/a/baz.rb", "code/foo.rb"]
      end
    end

    it "handles including nonexistent files" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.new(".")
        tree.include_paths(["does-not-exist"])
        tree.all_paths.sort.must_equal ["./"]
      end
    end

    it "handles excluding nonexistent files" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.new(".")
        tree.exclude_paths(["code/does-not-exist"])
        tree.all_paths.sort.must_equal [".git/", "code/a/", "code/foo.rb", "foo.txt", "lib/"]
      end
    end

    def make_fixture_tree
      make_tree <<-EOM
        .git/FETCH_HEAD
        .git/refs/heads/master
        code/a/bar.rb
        code/a/baz.rb
        code/foo.rb
        foo.txt
        lib/thing.rb
      EOM
    end
  end
end
