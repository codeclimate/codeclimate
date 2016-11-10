require "resolv-replace"

module CC
  class Resolv
    def self.with_fixed_dns(dns = ::Resolv::DNS.new)
      ::Resolv::DefaultResolver.replace_resolvers([Fixed.new(dns)])

      yield if block_given?
    ensure
      # There's no way to ask what the current values are before we override
      # them; hopefully going by the source is good enough.
      # https://docs.ruby-lang.org/en/2.0.0/Resolv.html#method-c-new
      default_resolvers = [::Resolv::Hosts.new, ::Resolv::DNS.new]
      ::Resolv::DefaultResolver.replace_resolvers(default_resolvers)
    end

    class Fixed
      def initialize(fallback)
        @addresses = {}
        @fallback = fallback
      end

      def each_address(name)
        if addresses.key?(name)
          yield addresses.fetch(name)
        else
          fallback.each_address(name) do |address|
            addresses[name] ||= address
            yield address
          end
        end
      end

      private

      attr_reader :addresses, :fallback
    end
  end
end
