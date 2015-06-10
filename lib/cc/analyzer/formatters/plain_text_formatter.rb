require "rainbow"

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
            case json["type"]
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
          puts

          issues_by_path.each do |path, file_issues|
            puts colorize("== #{path} (#{pluralize(file_issues.size, "issue")}) ==", :yellow)

            file_issues.sort_by { |i| i["location"]["begin"]["line"] }.each do |issue|
              if issue["location"]["begin"]
                print("#{colorize(issue["location"]["begin"]["line"], :cyan)}: ")
              end
              print(issue["description"])
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

        private

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
          "#{number} #{noun.pluralize(number)}"
        end
      end
    end
  end
end
