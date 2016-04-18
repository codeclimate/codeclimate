require "spec_helper"

module CC::Analyzer
  describe IssueLocationExistenceValidation do
    describe "#valid?" do
      it "returns true if the lines exist" do
        within_temp_dir do
          contents = [
            "class Foo",
            "  def valid?",
            "    return true",
            "  end",
            "end",
          ].join("\n")
          make_file("foo.rb", contents)

          expect(IssueLocationExistenceValidation.new("location" => {
            "path" => "foo.rb",
            "lines" => {
              "begin" => 1,
              "end" => 2
            }
          })).to be_valid
        end
      end

      it "returns true if the position exists" do
        within_temp_dir do
          contents = [
            "class Foo",
            "  def valid?",
            "    return true",
            "  end",
            "end",
          ].join("\n")
          make_file("foo.rb", contents)

          expect(IssueLocationExistenceValidation.new("location" => {
            "path" => "foo.rb",
            "positions" => {
              "begin" => {
                "line" => 1,
                "column" => 1,
              },
              "end" => {
                "line" => 1,
                "column" => 9,
              }
            }
          })).to be_valid
        end
      end

      it "returns true if the offset exists" do
        within_temp_dir do
          contents = [
            "class Foo",
            "  def valid?",
            "    return true",
            "  end",
            "end",
          ].join("\n")
          make_file("foo.rb", contents)

          expect(IssueLocationExistenceValidation.new("location" => {
            "path" => "foo.rb",
            "positions" => {
              "begin" => {
                "offset" => 0,
              },
              "end" => {
                "offset" => 8,
              }
            }
          })).to be_valid
        end
      end

      it "returns false if the lines don't exist" do
        within_temp_dir do
          contents = [
            "class Foo",
            "  def valid?",
            "    return true",
            "  end",
            "end",
          ].join("\n")
          make_file("foo.rb", contents)

          expect(IssueLocationExistenceValidation.new("location" => {
            "path" => "foo.rb",
            "lines" => {
              "begin" => 101,
              "end" => 102
            }
          })).not_to be_valid
        end
      end

      it "returns false if the position doesn't exist" do
        within_temp_dir do
          contents = [
            "class Foo",
            "  def valid?",
            "    return true",
            "  end",
            "end",
          ].join("\n")
          make_file("foo.rb", contents)

          expect(IssueLocationExistenceValidation.new("location" => {
            "path" => "foo.rb",
            "positions" => {
              "begin" => {
                "line" => 1,
                "column" => 100000,
              },
              "end" => {
                "line" => 1000,
                "column" => 9,
              }
            }
          })).not_to be_valid
        end
      end

      it "returns false if the position is badly formed" do
        within_temp_dir do
          contents = [
            "class Foo",
            "  def valid?",
            "    return true",
            "  end",
            "end",
          ].join("\n")
          make_file("foo.rb", contents)

          expect(IssueLocationExistenceValidation.new("location" => {
            "path" => "foo.rb",
            "positions" => "everywhere",
          })).not_to be_valid
        end
      end

      it "returns false if the offset doesn't exist" do
        within_temp_dir do
          contents = [
            "class Foo",
            "  def valid?",
            "    return true",
            "  end",
            "end",
          ].join("\n")
          make_file("foo.rb", contents)

          expect(IssueLocationExistenceValidation.new("location" => {
            "path" => "foo.rb",
            "positions" => {
              "begin" => {
                "offset" => 1000,
              },
              "end" => {
                "offset" => 2000,
              }
            }
          })).not_to be_valid
        end
      end
    end
  end
end
