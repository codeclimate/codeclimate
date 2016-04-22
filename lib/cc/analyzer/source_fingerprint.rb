require "digest/md5"

module CC
  module Analyzer
    class SourceFingerprint
      def initialize(issue)
        @issue = issue
      end

      def compute
        md5 = Digest::MD5.new
        md5 << issue.path
        md5 << issue.check_name.to_s
        md5 << relevant_source.gsub(/\s+/, "") if relevant_source
        md5.hexdigest
      end

      private

      attr_reader :issue

      def relevant_source
        source = SourceExtractor.new(raw_source).extract(issue.location)
        source if source && !source.empty?
      end

      def raw_source
        @raw_source ||= File.read(issue.path)
      end
    end
  end
end
