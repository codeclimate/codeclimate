require "digest/md5"
require "json"

module CC
  module Analyzer
    class Issue
      class Adapter
        TYPE = "issue".freeze

        attr_reader :hash

        def initialize(issue)
          @issue = issue
        end

        def run
          if location
            @hash = {
              _type: TYPE,
              attrs: issue["attrs"],
              categories: issue["categories"],
              check_name: issue["check_name"],
              constant_name: path,
              content: content,
              description: issue["description"],
              fingerprint: (issue["fingerprint"].presence || default_fingerprint),
              location: location,
              other_locations: other_locations,
              remediation_points: remediation_points,
            }.reject { |_, value| value.nil? }
          end
        end

        private

        attr_reader :issue

        def default_fingerprint
          digest = Digest::MD5.new
          digest << path
          digest << "|"
          digest << issue["check_name"]
          digest.to_s
        end

        def content
          issue["content"] || {}
        end

        def remediation_points
          issue["remediation_points"] || 0
        end

        def path
          issue["location"]["path"]
        end

        def location
          adapt_location(issue.fetch("location"))
        end

        def other_locations
          if issue["other_locations"]
            issue["other_locations"].map { |location| adapt_location(location) }
          end
        end

        def adapt_location(location)
          result = { path: location["path"] }

          if location["lines"]
            result.merge!(
              end_line: location["lines"]["end"],
              start_line: location["lines"]["begin"],
            )
          elsif positions = location["positions"]
            start_line = positions["begin"]["line"] || source_buffer.decompose_position(positions["begin"]["offset"])[0]
            if positions["end"]
              end_line = positions["end"]["line"] || source_buffer.decompose_position(positions["end"]["offset"])[0]
            end
            result.merge!(
              end_line: end_line,
              start_line: start_line,
            )
          end

          # If it's only a one line issue, set the end
          # to the same as the start
          result[:end_line] ||= result[:start_line]

          return if result[:end_line].nil? || result[:start_line].nil?

          result[:start_line] = result[:start_line].to_i
          result[:end_line] = result[:end_line].to_i

          result
        end

        def source_buffer
          @source_buffer ||= SourceBuffer.from_path(path)
        end
      end
    end
  end
end
