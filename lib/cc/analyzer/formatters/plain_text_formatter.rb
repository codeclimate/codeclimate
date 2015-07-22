require "rainbow"
require "tty/spinner"
require "active_support/number_helper"

module CC
  module Analyzer
    module Formatters
      class PlainTextFormatter < Formatter

        def started
          puts colorize("Starting analysis", :green)
        end

        def write(data)
          if data.present?
            json = JSON.parse(data)
            if current_engine
              json["engine_name"] = current_engine.name
            end

            case json["type"].downcase
            when "issue"
              issues << json
            when "warning"
              warnings << json
            else
              raise "Invalid type found: #{json["type"]}"
            end
          end
        end

        def finished
          puts

          issues_by_path.each do |path, file_issues|
            puts colorize("== #{path} (#{pluralize(file_issues.size, "issue")}) ==", :yellow)

            IssueSorter.new(file_issues).by_location.each do |issue|
              if location = issue["location"]
                print(colorize(LocationDescription.new(location, ": "), :cyan))
              end

              print(issue["description"])
              print(colorize(" [#{issue["engine_name"]}]", "#333333"))
              puts
            end
            puts
          end

          print(colorize("Analysis complete! Found #{pluralize(issues.size, "issue")}", :green))
          if warnings.size > 0
            print(colorize(" and #{pluralize(warnings.size, "warning")}", :green))
          end
          puts(colorize(".", :green))
        end

        def engine_running(engine, &block)
          super(engine) do
            with_spinner("Running #{current_engine.name}: ", &block)
          end
        end

        def failed(output)
          spinner.stop("Failed")
          puts colorize("\nAnalysis failed with the following output:", :red)
          puts output
          exit 1
        end

        private

        def spinner(text = nil)
          @spinner ||= Spinner.new(text)
        end

        def with_spinner(text)
          spinner(text).start
          yield
        ensure
          spinner.stop
          @spinner = nil
        end

        def colorize(string, *args)
          rainbow.wrap(string).color(*args)
        end

        def rainbow
          @rainbow ||= Rainbow.new.tap do |rainbow|
            rainbow.enabled = false unless @output.tty?
          end
        end

        def issues
          @issues ||= []
        end

        def issues_by_path
          issues.group_by { |i| i['location']['path'] }.sort
        end

        def warnings
          @warnings ||= []
        end

        def pluralize(number, noun)
          "#{ActiveSupport::NumberHelper.number_to_delimited(number)} #{noun.pluralize(number)}"
        end
      end
    end
  end
end
