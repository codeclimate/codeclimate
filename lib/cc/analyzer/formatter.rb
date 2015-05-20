require "rainbow"

module CC
  module Analyzer
    class Formatter

      def initialize(output = $stdout)
        @output = output
        @issues_by_path = {}
        @definitions_by_path = {}
        @definition_issue_counts = Hash.new(0)
      end

      def started(engine_name, paths)
        file_phrase = paths.size == 1 ? 'file' : 'files'
        @output.puts "Inspecting #{paths.count} #{file_phrase} with #{engine_name}"
      end

      def file_analyzed(path, result)
        @issues_by_path[path] ||= []
        @issues_by_path[path] += result.issues

        @definitions_by_path[path] ||= []
        @definitions_by_path[path] += result.definitions
      end

      def finished
        @output.puts
        @output.puts

        @issues_by_path.each do |path, issues|
          if issues.any?
            @output.puts colorize("== #{path} ==", :yellow)

            locator = IssueLocator.new(@definitions_by_path[path])

            issues.sort_by { |i| i.location.line }.each do |issue|
              @output.printf("%s: %s\n",
                colorize(issue.location.line, :cyan),
                issue.message)

              if issue.attrs["other_locations"]
                issue.attrs["other_locations"].each do |location|
                  @output.print "        #{location["path"]}"
                  if location["begin"]
                    @output.print ":#{location["begin"]["pos"]}...#{location["end"]["pos"]}"
                  end
                  @output.puts
                end
              end

              if (definition = locator.definition_at(issue.begin_pos))
                @definition_issue_counts[definition.full_name] += 1
              end
            end

            @output.puts
          end
        end

        all_definitions = @definitions_by_path.values.flatten

        if all_definitions.any?
          @output.puts colorize("## Definitions Found ##", :magenta)

          unique_definitions = all_definitions.uniq(&:full_name).sort_by(&:full_name)
          unique_definitions.each do |definition|
            @output.printf("%s %s (%d issues)\n",
              colorize(definition.def_type, :cyan),
              colorize(definition.full_name, :yellow),
              @definition_issue_counts[definition.full_name])
          end

          @output.puts
        end
      end

    private

      def colored_severity_code(issue)
        colorize("W", :yellow)
      end

      def colorize(string, *args)
        rainbow.wrap(string).color(*args)
      end

      def rainbow
        @rainbow ||= Rainbow.new.tap do |rainbow|
          rainbow.enabled = false unless @output.tty?
        end
      end

    end
  end
end
