require "redcarpet"
require "active_support/number_helper"

module CC
  module Analyzer
    module Formatters
      class HTMLFormatter < Formatter
        class ReportTemplate
          include ERB::Util
          attr_accessor :template, :issues, :issues_by_path

          TEMPLATE_PATH = File.expand_path(File.join(File.dirname(__FILE__), "templates/html.erb"))

          def initialize(issue_count, issues_by_path)
            @template = File.read(TEMPLATE_PATH)
            @issues_by_path = issues_by_path
            @issue_count = issue_count
          end

          def render
            ERB.new(@template).result(binding)
          end

          def pluralize(number, noun)
            "#{ActiveSupport::NumberHelper.number_to_delimited(number)} #{noun.pluralize(number)}"
          end
        end

        def write(data)
          json = JSON.parse(data)
          json["engine_name"] = current_engine.name

          case json["type"].downcase
          when "issue"
            issues << json
          when "warning"
            warnings << json
          else
            raise "Invalid type found: #{json["type"]}"
          end
        end

        def finished
          template = ReportTemplate.new(issues.length, issues_by_path)
          puts template.render
        end

        def failed(_)
          exit 1
        end

        private

        def issues
          @issues ||= []
        end

        def issues_by_path
          issues.group_by { |i| i["location"]["path"] }.sort.each do |_, file_issues|
            IssueSorter.new(file_issues).by_location.map do |issue|
              source_buffer = @filesystem.source_buffer_for(issue["location"]["path"])
              issue["location"] = LocationDescription.new(source_buffer, issue["location"], "")
              issue["description"] = render_readup_markdown(issue["description"])
              if issue["content"]
                issue["content"]["body"] = render_readup_markdown(issue["content"]["body"])
              end
            end
          end
        end

        def warnings
          @warnings ||= []
        end

        def render_readup_markdown(body)
          html = Redcarpet::Render::HTML.new(escape_html: false, link_attributes: { target: "_blank" })
          Redcarpet::Markdown.new(html, autolink: true, fenced_code_blocks: true, tables: true).render(body)
        end
      end
    end
  end
end
