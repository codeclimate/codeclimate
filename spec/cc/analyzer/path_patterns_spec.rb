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
