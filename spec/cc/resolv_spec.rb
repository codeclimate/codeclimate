require "spec_helper"
require "cc/resolv"

module CC
  describe Resolv do
    describe ".with_fixed_dns" do
      it "replaces the default resolver for the duration of the block" do
        fallback = double

        expect(fallback).to receive(:each_address).
          with("google.com").and_yield("overridden")

        Resolv.with_fixed_dns(fallback) do
          expect(::Resolv.getaddress("google.com")).to eq "overridden"
          expect(::Resolv.getaddress("google.com")).to eq "overridden"
        end

        expect(::Resolv.getaddress("google.com")).not_to eq "overridden"
      end
    end

    describe Resolv::Fixed do
      describe "#each_address" do
        it "delegates to the fallback resolver and caches the first address" do
          fallback = double
          fixed = Resolv::Fixed.new(fallback)

          allow(fallback).to receive(:each_address).
            with("host").once.
            and_yield("address-1").
            and_yield("address-2")

          yielded_1 = []
          yielded_2 = []
          fixed.each_address("host") { |a| yielded_1 << a }
          fixed.each_address("host") { |a| yielded_2 << a }

          expect(yielded_1).to eq ["address-1", "address-2"]
          expect(yielded_2).to eq ["address-1"]
        end
      end
    end
  end
end
