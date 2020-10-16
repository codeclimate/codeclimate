# frozen_string_literal: true
require "digest/md5"

module CC
  module Analyzer
    class SourceFingerprint
      def initialize(issue)
        @issue = issue
      end

      def compute
        string = [
          issue.path,
          issue.check_name.to_s,
          relevant_source&.gsub(/\s+/, "")
        ].join

        Digest::MD5.hexdigest(string)
      end

      private

      attr_reader :issue

      def relevant_source
        source = SourceExtractor.new(raw_source).extract(issue.location)

        if source && !source.empty?
          source.encode(Encoding::UTF_8, "binary", invalid: :replace, undef: :replace, replace: "")
        end
      end

      def raw_source
        @raw_source ||=
          if File.file?(issue.path)
            File.read(issue.path)
          else
            ""
          end
      end
    end
  end
end
