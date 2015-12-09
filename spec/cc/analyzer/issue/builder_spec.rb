require 'spec_helper'

module CC::Analyzer
  describe Issue::Builder do
    include Factory

    describe "#run" do
      it "constructs an appropriate error for invalid json" do
        builder = Issue::Builder.new("foo").tap(&:run)

        builder.error.must_be_instance_of CC::Analyzer::Engine::OutputInvalid
        builder.issue.must_be_nil
      end

      it "constructs an appropriate error for issue missing location" do
        builder = Issue::Builder.new(sample_issue_json("location" => {})).tap(&:run)

        builder.error.must_be_instance_of CC::Analyzer::Engine::IssueInvalid
        builder.issue.must_be_nil
      end

      it "constructs an appropriate error for issue with directory location" do
        Dir.chdir(Dir.mktmpdir) do
          Dir.mkdir("subdir")
          builder = Issue::Builder.new(
            sample_issue_json("location" => {"path" => "subdir", "lines" => {"begin" => 1, "end" => 1}}),
          ).tap(&:run)

          builder.error.must_be_instance_of CC::Analyzer::Engine::IssueInvalid
          builder.issue.must_be_nil
        end
      end

      it "constructs an appropriate error for invalide issue" do
        builder = Issue::Builder.new(sample_issue_json("check_name" => nil)).tap(&:run)

        builder.error.must_be_instance_of CC::Analyzer::Engine::IssueInvalid
        builder.issue.must_be_nil
      end

      it "constructs the adapted issue document" do
        builder = Issue::Builder.new(sample_issue_json).tap(&:run)

        builder.error.must_be_nil
        builder.issue.must_be_instance_of CC::Analyzer::Issue
      end
    end
  end
end
