require "redcarpet"

module CC
  module Analyzer
    module Formatters
      class HTMLFormatter < Formatter
        LANGUAGES = {
        }
        class ReportTemplate
          include ERB::Util
          attr_reader :issues

          TEMPLATE_PATH = File.expand_path(File.join(File.dirname(__FILE__), "templates/html.erb"))

          def initialize(issues, filesystem)
            @issues = issues
            @filesystem = filesystem
          end

          def project_name
            File.basename(filesystem.root)
          end

          def render
            template = File.read(TEMPLATE_PATH)
            ERB.new(template, nil, '-').result(binding)
          end

          def lang(issue)
            ext = File.basename(issue["location"]["path"]).split('.').last.downcase

            languages =
              case ext
              when 'abap' then 'abap'
              when 'as' then 'actionscript'
              when 'ada' then 'ada'
              when 'bas' then 'basic'
              when 'c', 'h' then 'c'
              when 'coffee' then 'coffeescript'
              when 'c++', 'cc', 'cp', 'cpp', 'cu', 'cxx', 'h++', 'hh', 'hpp' then 'cpp'
              when 'cr' then 'crystal'
              when 'cs' then 'csharp'
              when 'css' then %w[css css-extras]
              when 'd' then 'd'
              when 'diff', 'patch' then 'diff'
              when 'dart' then 'dart'
              when 'dockerfile' then 'docker'
              when 'ex' then 'elixir'
              when 'erl', 'yaws' then 'erlang'
              when 'fs', 'fsi', 'fsx', 'fsscript' then 'fsharp'
              when 'f', 'f90', 'f95', 'for' then 'fortran'
              when 'feature' then 'gherkin'
              when 'go' then 'go'
              when 'glsl', 'shader' then 'glsl'
              when 'groovy', 'gvy' then 'groovy'
              when 'haml' then 'haml'
              when 'handlebars','hbr' then 'handlebars'
              when 'hs', 'lhs' then 'haskell'
              when 'hx', 'hxml' then 'haxe'
              when 'icn' then 'icon'
              when 'ini' then 'ini'
              when 'ijs' then 'j'
              when 'java' then 'java'
              when 'js' then 'javascript'
              when 'ol', 'iol' then 'jolie'
              when 'json', 'template' then 'json'
              when 'jsx' then 'jsx'
              when 'jl' then 'julia'
              when 'kt', 'kts' then 'kotlin'
              when 'tex' then 'latex'
              when 'less' then 'less'
              when 'ls' then 'livescript'
              when 'lol', 'lols' then 'lolcode'
              when 'lua' then 'lua'
              when 'makefile' then 'makefile'
              when 'markdown', 'md', 'mkd' then 'markdown'
              when 'cfc', 'cfm', 'htm', 'html', 'tmproj', 'xaml', 'xhtml', 'xml' then 'markup'
              when 'mel' then 'mel'
              when 'asm' then 'nasm'
              when 'nim' then 'nim'
              when 'nix' then 'nix'
              when 'nsi' then 'nsis'
              when 'm', 'mm' then 'objective-c'
              when 'ml', 'mli' then 'ocaml'
              when 'oz' then 'oz'
              when 'dpr', 'pas' then 'pascal'
              when 'pl' then 'perl'
              when 'phtml', 'php', 'php3', 'php4', 'php5' then %w[php php-extras]
              when 'pde' then 'processing'
              when 'pro' then 'prolog'
              when 'properties' then 'properties'
              when 'pp' then 'puppet'
              when 'pure' then 'pure'
              when 'py', 'py3', 'pyw' then 'python'
              when 'q' then'q'
              when 'q', 'qm', 'qtest' then 'qore'
              when 'r' then 'r'
              when 'rst' then 'rest'
              when 'rs' then 'rust'
              when 'appraisals', 'capfile', 'gemfile', 'gemfile', 'gemspec', 'mab', 'prawn', 'rake', 'rakefile', 'rantfile', 'rb', 'rbw', 'rjs', 'rpdf', 'ru', 'rxml', 'vagrantfile' then 'ruby'
              when 'sass' then 'sass'
              when 'sc', 'scala' then 'scala'
              when 'scs', 'ss' then 'scheme'
              when 'scss' then 'scss'
              when 'sql' then 'sql'
              when 'st' then 'smalltalk'
              when 'tpl' then 'smarty'
              when 'styl' then 'stylus'
              when 'swift' then 'swift'
              when 'tcl' then 'tcl'
              when 'textile' then 'textile'
              when 'ts' then 'typescript'
              when 'v' then 'verilog'
              when 'vhd' then 'vhdl'
              when 'vim' then 'vim'
              when 'yaml', 'yml' then 'yaml'
              else
                ext
              end
            Array(languages)
          end

          def body?(issue)
            issue["content"] && issue["content"]["body"] &&
              !issue["content"]["body"].strip.empty?
          end

          def body(issue)
            return '' unless body?(issue)

            content = issue["content"]["body"].strip
            markdown(content)
          end

          def code(path)
            h filesystem.read_path(path)
          end

          def location(issue)
            lines = issue["location"]["lines"]
            if lines
              [lines["begin"], lines["end"]].uniq.sort.join('-')
            else
              positions = issue["location"]["positions"]
              if positions
                [
                  positions["begin"]["line"],
                  positions["end"]["line"],
                ].uniq.sort.join('-')
              end
            end
          end

          def other_locations(issue)
            locations = issue.fetch("other_locations", [])
            Hash[
              locations.map do |loc|
                [
                  loc["path"],
                  [loc["lines"]["begin"], loc["lines"]["end"]].uniq.sort.join('-')
                ]
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
            str.downcase.gsub(/\s+/, '-')
          end

          def params(values)
            values.map { |c| param c }.join(' ')
          end

          private

          attr_reader :filesystem

          def redcarpet
            @redcarpet ||=
              begin
                html = Redcarpet::Render::HTML.new(
                  escape_html: false,
                  link_attributes: { target: "_blank" }
                )
                Redcarpet::Markdown.new(
                  html,
                  autolink: true,
                  fenced_code_blocks: true,
                  no_intra_emphasis: true,
                  tables: true
                )
              end
          end

          def markdown(text)
            redcarpet.render(text)
          end
        end

        def finished
          template = ReportTemplate.new(
            issues,
            @filesystem
          )
          puts template.render
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
