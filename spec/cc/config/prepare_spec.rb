require "spec_helper"

describe CC::Config::Prepare do
  describe ".from_data" do
    it "returns a null object for no data" do
      nil_prepare = described_class.from_data(nil)
      empty_prepare = described_class.from_data({})

      expect(nil_prepare.fetch.each.to_a).to eq([])
      expect(empty_prepare.fetch.each.to_a).to eq([])
    end

    it "supports fetches declared as strings" do
      prepare = described_class.from_data(
        "fetch" => [
          "https://example-1.com/foo.rb",
          "https://example-2.com/foo/bar.rb",
        ],
      )

      expect(prepare.fetch.each.to_a).to match_array(
        [
          described_class::Fetch::Entry.new(
            "https://example-1.com/foo.rb", "foo.rb",
          ),
          described_class::Fetch::Entry.new(
            "https://example-2.com/foo/bar.rb", "bar.rb",
          ),
        ],
      )
    end

    it "supports fetches declared as objects" do
      prepare = described_class.from_data(
        "fetch" => [
          {
            "url" => "https://example-1.com/baz.rb",
            "path" => "bat.rb",
          },
          {
            "url" => "https://example-2.com/foo/quix.rb",
            # no "path"
          },
        ],
      )

      expect(prepare.fetch.each.to_a).to match_array(
        [
          described_class::Fetch::Entry.new(
            "https://example-1.com/baz.rb", "bat.rb",
          ),
          described_class::Fetch::Entry.new(
            "https://example-2.com/foo/quix.rb", "quix.rb",
          ),
        ],
      )
    end
  end

  describe CC::Config::Prepare::Fetch::Entry do
    it "prevents unsafe paths" do
      expect { described_class.new("", nil) }.to raise_error(
        ArgumentError, /blank/,
      )

      expect { described_class.new("", "") }.to raise_error(
        ArgumentError, /blank/,
      )

      expect { described_class.new("", "/etc/password") }.to raise_error(
        ArgumentError, /absolute/,
      )

      expect { described_class.new("", "./../etc/password") }.to raise_error(
        ArgumentError, /outside/,
      )

      expect { described_class.new("http://google.com/.%2F..%2Fetc%2Fpassword") }.to raise_error(
        ArgumentError, /outside/,
      )
    end
  end
end
