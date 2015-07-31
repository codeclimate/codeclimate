require "spec_helper"

module CC::Analyzer
  describe PathPatterns do
    include FileSystemHelpers

    around do |test|
      within_temp_dir { test.call }
    end

    describe "expanded" do
      it "matches files for all patterns at any level" do
        make_tree(<<-EOM)
          foo.rb
          foo.php
          foo.js
          foo/bar.rb
          foo/bar.php
          foo/bar.js
          foo/bar/baz.rb
          foo/bar/baz.php
          foo/bar/baz.js
        EOM
        patterns = PathPatterns.new(%w[ **/*.rb **/*.js ])
        expected = %w[
          foo.rb
          foo.js
          foo/bar.rb
          foo/bar.js
          foo/bar/baz.rb
          foo/bar/baz.js
        ]

        patterns.expanded.sort.must_equal(expected.sort)
      end

      it "works with patterns returned by cc-yaml" do
        make_tree("foo.rb foo.js foo.php")
        config = CC::Yaml.parse(<<-EOYAML)
        engines:
          rubocop:
            enabled: true
        exclude_paths:
        - "*.rb"
        - "*.js"
        EOYAML

        patterns = PathPatterns.new(config.exclude_paths)

        patterns.expanded.sort.must_equal(%w[ foo.js foo.rb ])
      end

      it "works with cc-yaml normalized paths and Dir.glob" do
        make_tree("foo/bar.rb")
        config = CC::Yaml.parse(<<-EOYAML)
        engines:
          rubocop:
            enabled: true
        ratings:
          paths:
          - "**.rb"
        EOYAML

        patterns = PathPatterns.new(config.ratings.paths)

        patterns.expanded.sort.must_equal(%w[ foo/bar.rb ])
      end
    end
  end
end
