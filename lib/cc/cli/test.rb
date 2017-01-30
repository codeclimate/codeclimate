require "cc/yaml"
require "tmpdir"

module CC
  module CLI
    class Marker
      def self.from_text(engine_name, test_file, line_number, text)
        marker = Marker.new(line_number, text)
        attrs = attrs_from_marker(text.sub(/^.*\[issue\] ?/, ""))

        marker.issue = attrs.merge(
          "engine_name" => engine_name,
          "location" => {
            "path" => test_file,
            "lines" => {
              "begin" => line_number + 1,
              "end" => line_number + 1,
            },
          },
        )

        if marker.issue["category"]
          marker.issue["categories"] = Array.wrap(marker.issue["category"])
          marker.issue.delete("category")
        end

        marker
      end

      def self.attrs_from_marker(text)
        if text.blank?
          {}
        else
          matches = text.scan(/([a-z\._-]+)=(?:(")((?:\\.|[^"])*)"|([^\s]*))/).map(&:compact)

          key_values = matches.map do |match|
            munge_match(match)
          end

          Hash[key_values]
        end
      end

      def self.munge_match(match)
        if match.size == 3 # Quoted
          key, _, value = match
          value = '"' + value + '"'
        else
          key, value = match
        end

        [key, munge_value(value)]
      end

      def self.munge_value(value)
        JSON.load(value)
      rescue JSON::ParserError
        value
      end

      attr_reader :line, :line_text
      attr_accessor :issue

      def initialize(line, line_text)
        @line = line
        @line_text = line_text
        @issue = issue
      end
    end

    class Test < Command
      ARGUMENT_LIST = "<engine_name>".freeze
      SHORT_HELP = "Test an engine.".freeze
      HELP = "Validate that an engine is behaving correctly.\n" \
        "\n"\
        "    <engine_name>    Engine to test".freeze

      def run
        @engine_name = @args.first

        if @engine_name.blank?
          fatal "Usage: codeclimate test #{rainbow.wrap("engine_name").underline}"
        end

        test_engine
      end

      def test_engine
        within_tempdir do
          prepare_working_dir
          unpack_tests
          run_tests
        end
      ensure
        remove_null_container
      end

      def within_tempdir(&block)
        Dir.mktmpdir { |tmp| Dir.chdir(tmp, &block) }
      end

      def unpack_tests
        test_paths.each do |test_path|
          unpack(test_path)
        end
      end

      def run_tests
        Dir["*"].each do |file|
          next unless File.directory?(file)
          process_directory(file)
        end
      end

      def process_directory(test_directory)
        markers = markers_in(test_directory)

        actual_issues = issues_in(test_directory)
        compare_issues(actual_issues, markers)
      end

      def compare_issues(actual_issues, markers)
        markers.each do |marker|
          validate_issue(marker, actual_issues)
        end

        validate_unexpected_issues(actual_issues)
      end

      def validate_issue(marker, actual_issues)
        if (index = locate_match(actual_issues, marker))
          announce_pass(marker)
          actual_issues.delete_at(index)
        else
          announce_fail(marker, actual_issues)
          fatal "Expected issue not found."
        end
      end

      def locate_match(actual_issues, marker)
        actual_issues.each_with_index do |actual, index|
          if fuzzy_match(marker.issue, actual)
            return index
          end
        end

        nil
      end

      def announce_pass(marker)
        say format("PASS %3d: %s", marker.line, marker.line_text)
      end

      def announce_fail(marker, actual_issues)
        say colorize(format("FAIL %3d: %s", marker.line, marker.line_text), :red)
        say colorize("Expected:", :yellow)
        say colorize(JSON.pretty_generate(marker.issue), :yellow)
        say "\n"
        say colorize("Actual:", :yellow)
        say colorize(JSON.pretty_generate(actual_issues), :yellow)
      end

      def validate_unexpected_issues(actual_issues)
        if actual_issues.any?
          say colorize("Actuals not empty after matching.", :red)
          say "\n"
          say colorize("#{actual_issues.size} remaining:", :yellow)
          say colorize(JSON.pretty_generate(actual_issues), :yellow)
          fatal "Unexpected issue found."
        end
      end

      def fuzzy_match(expected, actual)
        expected.all? do |key, value|
          actual[key] == value
        end
      end

      def issues_in(test_directory)
        issue_docs = capture_stdout do
          codeclimate_analyze(test_directory)
        end

        JSON.parse(issue_docs)
      end

      def codeclimate_analyze(relative_path)
        codeclimate_path = File.expand_path(File.join(File.dirname(__FILE__), "../../../bin/codeclimate"))

        system(
          codeclimate_path, "analyze",
          "--engine", @engine_name,
          "-f", "json",
          relative_path
        )
      end

      def prepare_working_dir
        `git init`

        File.open(".codeclimate.yml", "w") do |config|
          config.write("engines:\n  #{@engine_name}:\n    enabled: true")
        end
      end

      def markers_in(test_directory)
        [].tap do |markers|
          Dir[File.join(test_directory, "**/*")].each do |file|
            next unless File.file?(file)
            lines = File.readlines(file)

            lines.each_with_index do |line, index|
              if line =~ /\[issue\].*/
                markers << Marker.from_text(@engine_name, file, index + 1, line)
              end
            end
          end
        end
      end

      def unpack(path)
        system("docker cp #{null_container_id}:#{path} .")
      end

      def null_container_id
        # docker cp only works with containers, not images so
        # workaround it by creating a throwaway container
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
        engine_registry[@engine_name]["channels"]["stable"]
      end

      # Stolen from ActiveSupport (where it was deprecated)
      def capture_stdout
        captured_stream = Tempfile.new("stdout")
        origin_stream = $stdout.dup
        $stdout.reopen(captured_stream)

        yield

        $stdout.rewind
        return captured_stream.read
      ensure
        captured_stream.close
        captured_stream.unlink
        $stdout.reopen(origin_stream)
      end
    end
  end
end
