require "cc/yaml"

module CC
  module CLI
    class Test < Command
      Marker = Struct.new(:line, :line_text, :issue)

      def run
        @engine_name = @args.first

        if @engine_name.blank?
          fatal "Usage: codeclimate test #{rainbow.wrap("engine_name").underline}"
        end

        tmpdir = create_tmpdir

        Dir.chdir(tmpdir) do
          prepare_working_dir

          test_paths.each do |test_path|
            unpack(test_path)
          end

          Dir["**/*"].each do |test_file|
            next unless File.file?(test_file)
            process_file(test_file, tmpdir)
          end
        end
      ensure
        remove_null_container
      end

      def process_file(test_file, tmpdir)
        markers = markers_in(test_file)

        actual_issues = issues_in(test_file)
        compare_issues(actual_issues, markers)
      end

      def compare_issues(actual_issues, markers)
        markers.each do |marker|
          validate_issue(marker, actual_issues)
        end

        validate_unexpected_issues(actual_issues)
      end

      def validate_issue(marker, actual_issues)
        found_index = nil

        actual_issues.each_with_index do |actual, index|
          if fuzzy_match(marker.issue, actual)
            found_index = index
            break
          end
        end

        if found_index
          say "PASS %3d: %s" % [marker.line, marker.line_text]
          actual_issues.delete_at(found_index)
        else
          say colorize("MISS %3d: %s" % [marker.line, marker.line_text], :red)
          say colorize("Searched:", :yellow)
          say colorize(JSON.pretty_generate(marker.issue), :yellow)
          say "\n"
          say colorize("Actual:", :yellow)
          say colorize(JSON.pretty_generate(actual_issues), :yellow)
          fatal "Expected issue not found."
        end
      end

      def validate_unexpected_issues(actual_issues)
        if actual_issues.any?
          say colorize("Actuals not empty after matching.", :red)
          say
          say colorize("#{actual_issues.size } remaining:", :yellow)
          say colorize(JSON.pretty_generate(actual_issues), :yellow)
          fatal "Unexpected issue found."
        end
      end

      def fuzzy_match(expected, actual)
        expected.all? do |key, value|
          actual[key] == value
        end
      end

      def issues_in(test_file)
        issue_docs = capture(:stdout) do
          codeclimate_analyze(test_file)
        end

        JSON.parse(issue_docs)
      end

      def codeclimate_analyze(relative_path)
        codeclimate_path = File.expand_path(File.join(File.dirname(__FILE__), "../../../bin/codeclimate"))

        system([
          "unset CODE_PATH &&",
          "unset FILESYSTEM_DIR &&",
          codeclimate_path,
          "analyze",
          "--engine", @engine_name,
          "-f", "json",
          relative_path
        ].join(" "))
      end

      def prepare_working_dir
        `git init`

        File.open(".codeclimate.yml", "w") do |config|
          config.write("engines:\n  #{@engine_name}:\n    enabled: true")
        end
      end

      def markers_in(test_file)
        lines = File.readlines(test_file)

        Array.new.tap do |markers|
          lines.each_with_index do |line, index|
            if line =~ /\[issue\].*/
              markers << build_marker(test_file, index + 1, line)
            end
          end
        end
      end

      def build_marker(test_file, line_number, text)
        marker = Marker.new(line_number, text)

        text = text.sub(/^.*\[issue\] ?/, "")

        if text.blank?
          attrs = {}
        else
          matches = text.scan(/([a-z\._-]+)=(?:(")((?:\\.|[^"])*)"|([^\s]*))/).map(&:compact)

          key_values = matches.map do |match|
            # puts match.inspect

            if match.size == 3 # Quoted
              key, _, value = match
              value = '"' + value + '"'
            else
              key, value = match
            end

            [key, munge(value)]
          end

          attrs = Hash[key_values]
        end

        issue_line = line_number + 1

        marker.issue = attrs.merge(
          "engine_name" => @engine_name,
          "location" => {
            "path" => test_file,
            "lines" => {
              "begin" => issue_line,
              "end" => issue_line
            }
          }
        )

        if marker.issue["category"]
          marker.issue["categories"] = Array.wrap(marker.issue["category"])
          marker.issue.delete("category")
        end

        marker
      end

      def munge(value)
        JSON.load(value)
      rescue JSON::ParserError
        value
      end

      def create_tmpdir
        tmpdir = File.join("/tmp/cc", SecureRandom.uuid)
        FileUtils.mkdir_p(tmpdir)
        tmpdir
      end

      def unpack(path)
        system("docker cp #{null_container_id}:#{path} .")
      end

      def null_container_id
        # docker cp only works with containers, not images so
        # hack it by creating a throwaway container
        @null_container_id = `docker run -d #{engine_image} false`.chomp
      end

      def remove_null_container
        `docker rm -f #{null_container_id}` if null_container_id
      end

      def test_paths
        Array.wrap(engine_spec["test_paths"])
      end

      def engine_spec
        @engine_spec ||= JSON.parse(`docker run --rm #{engine_image} cat /engine.json`)
      end

      def engine_image
        engine_registry[@engine_name]["image"]
      end

    end
  end
end
