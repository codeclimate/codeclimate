module CC
  module Config
    class Prepare
      class NoPrepareNeeded
        def fetch
          []
        end
      end

      attr_reader :fetch

      def self.from_yaml(data)
        if data.present?
          fetch = Fetch.from_yaml(data.fetch("fetch", []))

          new(fetch: fetch)
        else
          NoPrepareNeeded.new
        end
      end

      def initialize(fetch:)
        @fetch = fetch
      end

      class Fetch < SimpleDelegator
        def self.from_yaml(data)
          new(data.map { |d| Entry.from_yaml(d) })
        end

        def initialize(entries)
          @entries = entries
        end

        def each(&block)
          entries.each(&block)
        end

        private

        attr_reader :entries

        class Entry
          attr_reader :url, :path

          def self.from_yaml(data)
            case data
            when String then new(data)
            when Hash then new(data.fetch("url"), data["path"])
            end
          end

          def initialize(url, path = nil)
            @url = url
            @path = path || url.split("/").last
          end

          # Useful in specs
          def ==(other)
            other.is_a?(self.class) &&
              other.url == url &&
              other.path == path
          end
        end
      end
    end
  end
end
