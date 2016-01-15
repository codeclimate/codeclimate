require "spec_helper"

module CC
  describe Workspace do
    include FileSystemHelpers

    it "responds with arguments given or \"./\", if unfiltered" do
      workspace = Workspace.new(paths: %w[foo bar/baz.rb])
      workspace.paths.must_equal %w[foo bar/baz.rb]

      workspace = Workspace.new
      workspace.paths.must_equal ["./"]
    end

    it "doesn't filter if given nil or empty exclude_paths" do
      workspace = Workspace.new
      workspace.filter(nil)
      workspace.filter([])
      workspace.paths.must_equal ["./"]
    end

    it "filters to a minimized set of paths in the current directory" do
      within_temp_dir do
        make_tree <<-EOM
          .bundle/vendor/dependency.rb
          .bundle/vendor/dependency/inner.rb
          .git/FETCH_HEAD
          .git/refs/heads/master
          .gitignore
          .node_modules/crazy/stuff
          .node_modules/other/crazy/stuff
          Gemfile
          Gemfile.lock
          app/assets/vendor/javascripts/ouch.js
          app/assets/vendor/stylesheets/ouch.css
          lib/foo.rb
          lib/foo/bar.rb
          lib/foo/baz.rb
          lib/quix/a.rb
          lib/quix/b.rb
          spec/foo/bar_spec.rb
          spec/foo/baz_spec.rb
          spec/foo_spec.rb
          vendor/assets/jquery.js
          vendor/assets/underscore.js
        EOM

        workspace = Workspace.new
        workspace.filter(%w[
          .bundle
          .git
          .gitignore
          .node_modules/**/*
          app/assets/vendor
          spec/foo/baz_spec.rb
          vendor/**
        ])

        workspace.paths.sort.must_equal %w[
          Gemfile
          Gemfile.lock
          lib/
          spec/foo/bar_spec.rb
          spec/foo_spec.rb
        ]
      end
    end

    it "can be filtered again, e.g. per engine" do
      within_temp_dir do
        make_tree <<-EOM
          .node_modules/crazy/stuff
          .node_modules/other/crazy/stuff
          Gemfile
          Gemfile.lock
          lib/foo.rb
          lib/foo/bar.rb
          lib/foo/baz.rb
          lib/quix/a.rb
          lib/quix/b.rb
          spec/foo/bar_spec.rb
          spec/foo/baz_spec.rb
          spec/foo_spec.rb
          vendor/assets/jquery.js
          vendor/assets/underscore.js
        EOM

        workspace = Workspace.new
        workspace.filter(%w[.node_modules])
        workspace.filter(%w[vendor])

        workspace.paths.sort.must_equal %w[
          Gemfile
          Gemfile.lock
          lib/
          spec/
        ]
      end
    end

    it "warns on unsupported patterns" do
      within_temp_dir do
        make_tree <<-EOM
          lib/foo.py
          lib/foo.pyc
        EOM

        workspace = Workspace.new
        _, stderr = capture_io { workspace.filter(%w[*.pyc]) }

        stderr.must_include("WARNING: invalid exclude path: \"*.pyc\"")
        workspace.paths.sort.must_equal %w[lib/]
      end
    end

    it "can be given an explicit set of initial paths" do
      within_temp_dir do
        make_tree <<-EOM
          .bundle/vendored/bar.rb
          .bundle/vendored/foo.rb
          Gemfile
          Gemfile.lock
          lib/foo.rb
          lib/foo/bar.rb
          lib/foo/baz.rb
          spec/foo/bar_spec.rb
          spec/foo/baz_spec.rb
          spec/foo_spec.rb
          vendor/foo.js
          vendor/foo/bar.css
        EOM

        workspace = Workspace.new(paths: %w[lib/foo spec/foo/bar_spec.rb])
        workspace.filter(%w[lib/foo/bar.rb])

        workspace.paths.sort.must_equal %w[
          lib/foo/baz.rb
          spec/foo/bar_spec.rb
        ]
      end
    end

    it "validates paths arguments" do
      action = ->() { Workspace.new(paths: %w[./]) }
      action.must_raise(ArgumentError)
    end
  end
end
