require "spec_helper"

class CC::Workspace
  describe PathTree do
    include FileSystemHelpers

    it "doesn't needlessly descend if nothing excluded" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.for_path(".")
        expect(tree.all_paths).to eq ["./"]
      end
    end

    it "excludes files, descending as needed" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.for_path(".")
        tree.exclude_paths([".git/refs", "code/a/bar.rb"])
        expect(tree.all_paths.sort).to eq [".git/FETCH_HEAD", "code/a/baz.rb", "code/foo.rb", "foo.txt", "lib/"]
      end
    end

    it "includes files, descending as needed" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.for_path(".")
        tree.include_paths([".git/refs/", "code/foo.rb", "code/a/bar.rb"])
        expect(tree.all_paths.sort).to eq [".git/refs/", "code/a/bar.rb", "code/foo.rb"]
      end
    end

    it "excludes files after explicit includes" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.for_path(".")
        tree.include_paths([".git/refs/", "code/"])
        tree.exclude_paths([".git/refs/heads/master", "code/a/bar.rb"])
        expect(tree.all_paths.sort).to eq ["code/a/baz.rb", "code/foo.rb"]
      end
    end

    it "excludes directory after excluding only part of it" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.for_path(".")
        tree.exclude_paths(["code/a/bar.rb"])
        tree.exclude_paths(["code/"])
        expect(tree.all_paths.sort).to eq [".git/", "foo.txt", "lib/"]
      end
    end

    it "excludes directory after excluding all children" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.for_path(".")
        tree.exclude_paths(["code/a/bar.rb"])
        tree.exclude_paths(["code/a/baz.rb"])
        expect(tree.all_paths.sort).to eq [".git/", "code/foo.rb", "foo.txt", "lib/"]
      end
    end

    it "handles including nonexistent files" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.for_path(".")
        tree.include_paths(["does-not-exist"])
        expect(tree.all_paths.sort).to eq ["./"]
      end
    end

    it "handles excluding nonexistent files" do
      within_temp_dir do
        make_fixture_tree

        tree = PathTree.for_path(".")
        tree.exclude_paths(["code/does-not-exist"])
        expect(tree.all_paths.sort).to eq [".git/", "code/a/", "code/foo.rb", "foo.txt", "lib/"]
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
