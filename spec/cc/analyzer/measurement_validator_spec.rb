require "spec_helper"

module CC::Analyzer
  describe MeasurementValidator do
    describe "#valid?" do
      it "returns true when everything is valid" do
        doc = {
          "name" => "foo",
          "type" => "measurement",
          "value" => 42,
        }

        validator = described_class.new(doc)

        expect(validator).to be_valid
      end

      it "stores an error for invalid issues" do
        validator = described_class.new({})
        expect(validator).not_to be_valid
        expect(validator.error).to eq(
          message: "Name must be present and contain only letters, numbers, periods, hyphens, and underscores; Type must be 'measurement' but was ''; Value must be present and numeric: `{}`.",
          document: {},
        )
      end
    end
  end
end
