require "digest/md5"

module CC
  module Analyzer
    class IssueAdapter

      def initialize(source_buffer, issue_hash)
        @source_buffer = source_buffer
        @issue_hash = issue_hash
      end

      def to_issue
        begin_pos = @issue_hash["location"]["begin"]["pos"]

        if @issue_hash["location"]["end"]
          end_pos = @issue_hash["location"]["end"]["pos"]
        else
          end_pos = begin_pos
        end

        source_range = SourceRange.new(begin_pos, end_pos)
        location = SourceLocation.new(@source_buffer, source_range)

        check = @issue_hash["check"]
        description = @issue_hash["description"]
        categories = @issue_hash["categories"]

        Issue.new(
          check,
          description,
          location,
          fingerprint.to_s,
          categories,
          1_000,
          @issue_hash["attrs"] || {})
      end

    private

      def fingerprint
        @fingerprint ||= Digest::MD5.new.tap do |fingerprint|
          fingerprint << @source_buffer.name
          fingerprint << @issue_hash["check"]
        end
      end

    end
  end
end
