require 'spec_helper'

module CC::Analyzer
  describe Issue::Adapter do
    include Factory

    describe "#run" do
      it "returns falsy if the location is bad" do
        location = { "location" => { "path" => "fun.rb" } }
        issue = sample_issue(location)
        translator = Issue::Adapter.new(issue)
        (!translator.run).must_equal(true)
      end

      it "sets the right end line" do
        Dir.chdir(Dir.mktmpdir) do
          File.write("cool.go", sample_source_code)

          location = { "location"=> {
              "path"=>"cool.go",
              "positions" => {
                "begin"=>{
                  "column"=>62,
                  "line"=>1,
                }
              }
            }
          }

          issue = sample_issue(location)
          translator = Issue::Adapter.new(issue)
          result = translator.run

          result[:location][:end_line].must_equal(1)
        end
      end

      it "returns the content" do
        Dir.chdir(Dir.mktmpdir) do
          File.write("cool.go", sample_source_code)
          content = { "body" => "# Title\n\nSome\n\nmarkdown **text**" }

          issue = sample_issue("content" => content)
          translator = Issue::Adapter.new(issue)
          result = translator.run

          result[:content].must_equal(content)
        end
      end

      it "handles other_locations" do
        Dir.chdir(Dir.mktmpdir) do
          File.write("cool.go", sample_source_code)

          other_locations = {
            "other_locations" => [
              {
                "path" => "terrific.go",
                "positions" => {
                  "begin" => { "column" => 62, "line" => 1 },
                  "end" => { "column" => 14, "line" => 2 },
                }
              },
              {
                "path" => "spectacular.go",
                "lines" => {
                  "begin" => 4,
                  "end" => 5,
                }
              }
            ]
          }

          issue = sample_issue(other_locations)
          translator = Issue::Adapter.new(issue)
          result = translator.run

          result[:other_locations].count.must_equal(2)
          result[:other_locations][0].must_equal({
            path: "terrific.go",
            end_line: 2,
            start_line: 1,
          })
          result[:other_locations][1].must_equal({
            path: "spectacular.go",
            end_line: 5,
            start_line: 4,
          })
        end
      end

      it "returns the right attributes" do
        Dir.chdir(Dir.mktmpdir) do
          File.write("cool.go", sample_source_code)

          location_formats = [
            { "location" => {
                "path" => "cool.go",
                "positions" => {
                  "begin" => { "column"=>62, "line"=>1, },
                  "end" => { "column"=>62, "line"=>3, },
                },
              },
            },
            { "location" => {
                "path" => "cool.go",
                "positions" => {
                  "begin" => { "offset" => 2 },
                  "end" => { "offset" => 20 },
                },
              },
            },
            { "location" => {
                "path" => "cool.go",
                "lines" => {
                  "begin" => 1,
                  "end" => 3,
                },
              },
            },
          ]

          location_formats.each do |location|
            issue = sample_issue(location.merge("remediation_points" => nil))
            translator = Issue::Adapter.new(issue)
            result = translator.run

            result[:remediation_points].must_equal(0)
            result[:attrs].must_equal({"reason" => "Unexpected use of '<<'."})
            result[:location].must_equal({
              path: "cool.go",
              start_line: 1,
              end_line: 3
            })
            result[:check_name].must_equal("GoVet/BugRisk/GoVet")
            result[:categories].must_equal(["clarity", "style"])
            result[:description].must_equal("unreachable code")
          end
        end
      end
    end

    def sample_source_code
      <<-CODE
      package main

      import (
        "encoding/json"
        "fmt"
        "math/rand"
        "net/http"
        "os"
        "strconv"
        "time"
      )
      CODE
    end

    def sample_issue(overrides = {})
      {
        "type"=>"issue",
        "check_name"=>"GoVet/BugRisk/GoVet",
        "description"=>"unreachable code",
        "categories"=>["clarity", "style"],
        "remediation_points"=>500,
        "remediation_cost"=>0.0005,
        "location"=>{
          "path"=>"cool.go",
          "positions" => {
            "begin"=>{
              "column"=>62,
              "line"=>1,
            },
            "end"=>{
              "column"=>62,
              "line"=>3,
            }
          },
        },
        "content" => { "body" => "# Title\n\nSome\n\nmarkdown **text**" },
        "attrs" => {"reason" => "Unexpected use of '<<'."}
      }.merge!(overrides)
    end
  end
end

