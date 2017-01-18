require "redcarpet"

module CC
  module Analyzer
    module Formatters
      class HTMLFormatter < Formatter # rubocop: disable Metrics/ClassLength
        LANGUAGES = Hash.new { |_, ext| ext }.
                    merge(
                      # abap
                      # ada
                      "appraisals" => "ruby",
                      "as" => "actionscript",
                      "asm" => "nasm",
                      "bas" => "basic",
                      # c
                      "c++" => "cpp",
                      "capfile" => "ruby",
                      "cc" => "cpp",
                      "cfc" => "markup",
                      "cfm" => "markup",
                      "coffee" => "coffeescript",
                      "cp" => "cpp",
                      # cpp
                      "cr" => "crystal",
                      "cs" => "csharp",
                      "css" => %w[css css-extras],
                      "cu" => "cpp",
                      "cxx" => "cpp",
                      # d
                      # dart
                      # diff
                      "dockerfile" => "docker",
                      "dpr" => "pascal",
                      "erl" => "erlang",
                      "ex" => "elixir",
                      "f" => "fortran",
                      "f90" => "fortran",
                      "f95" => "fortran",
                      "feature" => "gherkin",
                      "for" => "fortran",
                      "fs" => "fsharp",
                      "fsi" => "fsharp",
                      "fsscript" => "fsharp",
                      "fsx" => "fsharp",
                      "gemfile" => "ruby",
                      "gemspec" => "ruby",
                      # glsl
                      # go
                      # groovy
                      "gvy" => "groovy",
                      "h" => "c",
                      "h++" => "cpp",
                      # haml
                      # handlebars
                      "hbr" => "handlebars",
                      "hh" => "cpp",
                      "hpp" => "cpp",
                      "hs" => "haskell",
                      "htm" => "markup",
                      "html" => "markup",
                      "hx" => "haxe",
                      "hxml" => "haxe",
                      "icn" => "icon",
                      "ijs" => "j",
                      # ini
                      "iol" => "jolie",
                      # java
                      "jl" => "julia",
                      "js" => "javascript",
                      # json
                      # jsx
                      "kt" => "kotlin",
                      "kts" => "kotlin",
                      # less
                      "lhs" => "haskell",
                      "lol" => "lolcode",
                      "lols" => "lolcode",
                      "ls" => "livescript",
                      # lua
                      "m" => "objective-c",
                      "mab" => "ruby",
                      # makefile
                      # markdown
                      "md" => "markdown",
                      # mel
                      "mkd" => "markdown",
                      "ml" => "ocaml",
                      "mli" => "ocaml",
                      "mm" => "objective-c",
                      # nim
                      # nix
                      "nsi" => "nsis",
                      "ol" => "jolie",
                      # oz
                      "pas" => "pascal",
                      "patch" => "diff",
                      "pde" => "processing",
                      "php" => %w[php php-extras],
                      "php3" => %w[php php-extras],
                      "php4" => %w[php php-extras],
                      "php5" => %w[php php-extras],
                      "phtml" => %w[php php-extras],
                      "pl" => "perl",
                      "pp" => "puppet",
                      "prawn" => "ruby",
                      "pro" => "prolog",
                      # properties
                      # pure
                      "py" => "python",
                      "py3" => "python",
                      "pyw" => "python",
                      "q" => "qore",
                      "qm" => "qore",
                      "qtest" => "qore",
                      # r
                      "rake" => "ruby",
                      "rakefile" => "ruby",
                      "rantfile" => "ruby",
                      "rb" => "ruby",
                      "rbw" => "ruby",
                      "rjs" => "ruby",
                      "rpdf" => "ruby",
                      "rs" => "rust",
                      "rst" => "rest",
                      "ru" => "ruby",
                      "rxml" => "ruby",
                      # sass
                      "sc" => "scala",
                      # scala
                      "scs" => "scheme",
                      # scss
                      "shader" => "glsl",
                      # sql
                      "ss" => "scheme",
                      "st" => "smalltalk",
                      "styl" => "stylus",
                      # swift
                      # tcl
                      "template" => "json",
                      "tex" => "latex",
                      # textile
                      "tmproj" => "markup",
                      "tpl" => "smarty",
                      "ts" => "typescript",
                      "v" => "verilog",
                      "vagrantfile" => "ruby",
                      "vhd" => "vhdl",
                      # vim
                      "xaml" => "markup",
                      "xhtml" => "markup",
                      "xml" => "markup",
                      # yaml
                      "yaws" => "erlang",
                      "yml" => "yaml",
                    ).freeze

        class ReportTemplate
          include ERB::Util
          attr_reader :issues

          TEMPLATE_PATH = File.expand_path(File.join(File.dirname(__FILE__), "templates/html.erb"))

          MARKDOWN_CONFIG = { autolink: true, fenced_code_blocks: true, no_intra_emphasis: true, tables: true }.freeze

          def initialize(issues, filesystem)
            @issues = issues
            @filesystem = filesystem
          end

          def project_name
            File.basename(filesystem.root)
          end

          def render
            template = File.read(TEMPLATE_PATH)
            ERB.new(template, nil, "-").result(binding)
          end

          def lang(issue)
            ext = File.basename(issue["location"]["path"]).split(".").last.downcase
            Array(LANGUAGES[ext])
          end

          def body?(issue)
            issue["content"] && issue["content"]["body"] &&
              !issue["content"]["body"].strip.empty?
          end

          def body(issue)
            return "" unless body?(issue)

            content = issue["content"]["body"].strip
            markdown(content)
          end

          def code(path)
            h filesystem.read_path(path)
          end

          def location(issue)
            (lines(issue["location"]["lines"]) ||
             positions(issue)).uniq.sort.join("-")
          end

          def other_locations(issue)
            locations = issue.fetch("other_locations", [])
            Hash[
              locations.map do |loc|
                [loc["path"], lines(loc["lines"]).uniq.sort.join("-")]
              end
            ]
          end

          def languages
            issues.flat_map do |issue|
              lang issue
            end.uniq.sort
          end

          def categories
            issues.flat_map do |issue|
              issue["categories"]
            end.uniq.sort
          end

          def engines
            issues.map do |issue|
              issue["engine_name"]
            end.uniq.sort
          end

          def param(str)
            str.downcase.gsub(/\s+/, "-")
          end

          def params(values)
            values.map { |c| param c }.join(" ")
          end

          private

          attr_reader :filesystem

          def redcarpet
            @redcarpet ||=
              begin
                html = Redcarpet::Render::HTML.new(
                  escape_html: false,
                  link_attributes: { target: "_blank" },
                )
                Redcarpet::Markdown.new(html, MARKDOWN_CONFIG)
              end
          end

          def markdown(text)
            redcarpet.render(text)
          end

          def positions(issue)
            positions = issue["location"]["positions"]
            if positions
              [
                positions["begin"]["line"],
                positions["end"]["line"],
              ].uniq.sort.join("-")
            end
          end

          def lines(lines)
            if lines
              [lines["begin"], lines["end"]]
            end
          end
        end

        def finished
          puts ReportTemplate.new(issues, @filesystem).render
        end

        def failed(_)
          exit 1
        end

        private

        def issues
          @issues ||= []
        end

        def warnings
          @warnings ||= []
        end
      end
    end
  end
end
