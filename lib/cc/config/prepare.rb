module CC
  class Config
    class Prepare
      attr_reader :fetch

      def self.from_data(data)
        if data.present?
          fetch = Fetch.from_data(data.fetch("fetch", []))

          new(fetch: fetch)
        else
          new
        end
      end

      def initialize(fetch: Fetch.new)
        @fetch = fetch
      end

      def merge(other)
        Prepare.new(fetch: fetch.merge(other.fetch))
      end

      class Fetch
        def self.from_data(data)
          new(data.map { |d| Entry.from_data(d) })
        end

        def initialize(entries = [])
          @entries = Set.new(entries)
        end

        def each(&block)
          entries.each(&block)
        end

        def paths
          entries.map(&:path)
        end

        def merge(other)
          Fetch.new(each.to_a | other.each.to_a)
        end

        private

        attr_reader :entries

        class Entry
          attr_reader :url, :path

          def self.from_data(data)
            case data
            when String then new(data)
            when Hash then new(data.fetch("url"), data["path"])
            end
          end

          def initialize(url, path = nil)
            @url = url
            @path = path || url.split("/").last

            validate_path!
          end

          # Useful in specs
          def ==(other)
            other.is_a?(self.class) &&
              other.url == url &&
              other.path == path
          end

          private

          # Duplicate a validation which has security implication. This should
          # always be caught upstream, so raising loudly is fine.
          def validate_path!
            if path.blank?
              raise ArgumentError, "path cannot be be blank"
            end

            pathname = Pathname.new(path)

            if pathname.absolute?
              raise ArgumentError, "path cannot be absolute: #{path}"
            end

            if pathname.cleanpath.to_s != pathname.to_s || path.include?("..")
              raise ArgumentError, "path cannot point outside the current directory: #{path}"
            end
          end
        end
      end
    end
  end
end
