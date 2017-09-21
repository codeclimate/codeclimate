require "spec_helper"

module CC::CLI
  describe Command do
    describe ".all" do
      it "includes Command subclasses" do
        class Test1 < Command; end

        expect(Command.all).to include(Test1)
      end
    end

    describe "abstract comand classes" do
      it "does not include absctract Command subclasses" do
        class Test2 < Command
          abstract!
        end

        expect(Command.all).to_not include(Test2)
      end

      it "includes subclasses of absctract Command subclasses" do
        class Test3 < Command
          abstract!
        end
        class Test4 < Test3; end

        expect(Command.all).to include(Test4)
      end

      it "indicates whether Command subclasses is abstract" do
        class Test5 < Command
          abstract!
        end

        expect(Test5).to be_abstract
      end
    end

    describe "command lookup" do
      it "returns a command by its name" do
        class Test6 < Command; end

        expect(Command["test6"]).to eq Test6
      end

      it "returns a namespaced command by its name" do
        module Namespace
          class Test7 < Command; end
        end

        expect(Command["namespace:test7"]).to eq Namespace::Test7
      end

      it "returns `nil` when command is not found" do
        expect(Command["no-such-command"]).to be_nil
      end

      it "returns `nil` for abstract commands" do
        class Test8 < Command
          abstract!
        end

        expect(Command["test8"]).to be_nil
      end
    end

    describe ".synopsys" do
      it "returns just a command name when no argumes are defined" do
        class Test9 < Command; end

        expect(Test9.synopsis).to eq "test9"
      end

      it "includes argumens when defined" do
        class Test10 < Command
          ARGUMENT_LIST = "<argument list>"
        end

        expect(Test10.synopsis).to eq "test10 <argument list>"
      end
    end

    describe ".short_help" do
      it "returns short help when defined" do
        class Test11 < Command
          SHORT_HELP = "short help"
        end

        expect(Test11.short_help).to eq "short help"
      end

      it "returns empty string when no short help is defined" do
        class Test12 < Command; end

        expect(Test12.short_help).to eq ""
      end
    end

    describe ".help" do
      it "returns help when defined" do
        class Test13 < Command
          HELP = "help"
        end

        expect(Test13.help).to eq "help"
      end

      it "returns short help as a fallback" do
        class Test14 < Command
          SHORT_HELP = "short help"
        end

        expect(Test14.help).to eq "short help"
      end

      it "returns empty string when no help is defined" do
        class Test15 < Command; end

        expect(Test15.short_help).to eq ""
      end
    end
  end
end
