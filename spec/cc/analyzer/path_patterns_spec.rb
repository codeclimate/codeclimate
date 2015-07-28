require "spec_helper"

module CC::Analyzer
  describe PathPatterns do
    describe "expanded" do
      it "matches files for all patterns at any level" do
        root = Dir.mktmpdir
        make_tree(root, <<-EOM)
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
        patterns = PathPatterns.new(%w[ **/*.rb **/*.js ], root)
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
        root = Dir.mktmpdir
        make_tree(root, "foo.rb foo.js foo.php")
        config = CC::Yaml.parse(<<-EOYAML)
        engines:
          rubocop:
            enabled: true
        exclude_paths:
        - "*.rb"
        - "*.js"
        EOYAML

        patterns = PathPatterns.new(config.exclude_paths, root)

        patterns.expanded.sort.must_equal(%w[ foo.js foo.rb ])
      end

      it "works with cc-yaml normalized paths and Dir.glob" do
        root = Dir.mktmpdir
        make_tree(root, "foo/bar.rb")
        config = CC::Yaml.parse(<<-EOYAML)
        engines:
          rubocop:
            enabled: true
        ratings:
          paths:
          - "**.rb"
        EOYAML

        patterns = PathPatterns.new(config.ratings.paths, root)

        patterns.expanded.sort.must_equal(%w[ foo/bar.rb ])
      end

      def make_tree(root, spec)
        paths = spec.split(/\s+/).select(&:present?)
        paths.each do |path|
          file = File.join(root, path)
          directory = File.dirname(file)

          FileUtils.mkdir_p(directory)
          File.write(file, "")
        end
      end
    end
  end
end
