module MD2Indesign
  module Format
    class Idtag
      def initialize(highlight: "none")
        @highlight = highlight
      end

      def root(node)
        node[:value]
      end

      def text(node)
        escape(node[:value])
      end

      def smart_quote(node)
        ## TODO: fix for indesign
        {
          lsquo: %('),
          rsquo: %('),
          ldquo: %("),
          rdquo: %("),
        }[node[:value]]
      end

      def typographic_sym(node)
        ## TODO: fix for indesign
        {
          hellip:      "...",
          mdash:       "---",
          ndash:       "--",
          laquo:       "\\<\\<",
          raquo:       "\\>\\>",
          laquo_space: "\\<\\< ",
          raquo_space: " \\>\\>",
        }[node[:value]]
      end

      def entity(node)
        # &gt; &lt; etc
        node[:options][:original]
      end

      def header(node)
        level = node[:options][:level]
        %(<ParaStyle:h#{level}>#{node[:value]}\n)
      end

      def p(node)
        if node.dig(:parent, :type) == :blockquote
          "<ParaStyle:blockquote>#{node[:value]}\n"
        else
          "<ParaStyle:p>#{node[:value]}\n"
        end
      end

      def ul(node)
        "#{node[:value]}"
      end

      def ol(node)
        "#{node[:value]}"
      end

      # <ulN>, <olN> based on parent
      def li(node)
        level = node[:parent][:level]
        type  = node[:parent][:type]
        if node[:close]
          "<ParaStyle:#{type}#{level}>#{node[:value]}"
        else
          "<ParaStyle:#{type}#{level}>#{node[:value]}\n"
        end
      end

      def codeblock(node)
        lang = node[:attr] && node[:attr]["class"].sub("language-", "")
        code = code_format(node).split("\n").map{|line| "<ParaStyle:code-#{lang}>#{line}"}.join("\n")
        "#{code}\n"
      end

      def codespan(node)
        %(<CharStyle:code>#{escape(node[:value])}<CharStyle:>)
      end

      def code_format(arg)
        lang = arg[:lang]
        code = arg[:code]

        case @highlight
        when "mono"
          lexer = Rouge::Lexer.guess(filename: ".#{lang}")
          formatter = MD2Indesign::Highlighter::Idtag.new(highlight: "mono")
          formatted = formatter.format(lexer.new.lex(code))
          formatted
        when "color"
          lexer = Rouge::Lexer.guess(filename: ".#{lang}")
          formatter = MD2Indesign::Highlighter::Idtag.new(highlight: "color")
          formatted = formatter.format(lexer.new.lex(code))
          formatted
        when "none"
          escape(code)
        end
      end

      ## output as-is
      def html_element(node)
        # :DEBUG
        # pp node[:parent][:type]
        # pp node.reject{|k,v| k == :parent}

        # gather attributes if exists
        attrs = node[:attr]&.map {|key, value|
          next key if value == ""
          %(#{key}="#{value}")
        }

        # join attributes if exists
        attr = attrs.nil? ? "" : " " + attrs.join(" ")

        "<#{node[:tag]}#{attr}>#{node[:value]}</#{node[:tag]}>"
      end

      ### table
      def table(node)
        node[:value]
      end
      def thead(node)
        node[:value]
      end
      def tbody(node)
        node[:value]
      end
      def tr(node)
        value = node[:children].map{|child| child[:value]}.join("\t")
        type = node[:children].first[:type]
        "<ParaStyle:#{type}>#{value}\n"
      end
      def th(node)
        node
      end
      def td(node)
        node
      end

      ### dl
      def dl(node)
        node[:value]
      end
      def dt(node)
        "<ParaStyle:dt>#{node[:value]}\n"
      end
      def dd(node)
        "<ParaStyle:dd>#{node[:value]}\n"
      end

      ### block elements
      def article(node)
        node[:value]
      end
      def section(node)
        node[:value]
      end
      def div(node)
        node[:value]
      end
      def blockquote(node)
        node[:value]
      end

      ### inline elements
      def strong(node)
        "<CharStyle:strong>#{node[:value]}<CharStyle:>"
      end
      def em(node)
        "<CharStyle:em>#{node[:value]}<CharStyle:>"
      end
      def br(node=nil)
        "<ParaStyle:br>\n"
      end
      def hr(node=nil)
        "<ParaStyle:hr>\n"
      end
      def span(node)
        # only join children
        node[:children].join("")
      end
      def a(node)
        href  = node[:attr]["href"]
        value = node[:value]
        "<CharStyle:link>#{value}<CharStyle:><CharStyle:href>#{href}<CharStyle:>"
      end
      def img(node)
        attr  = node[:attr]
        src   = attr["src"]
        alt   = attr["alt"]
        title = attr["title"]
        "<CharStyle:imgSrc>#{src}<CharStyle:><CharStyle:imgTitle>#{title}<CharStyle:><CharStyle:imgAlt>#{alt}<CharStyle:>"
      end

      private
      def escape(str)
        str
          .gsub('\\', '\\\\')
          .gsub('<', '\\<')
          .gsub('>', '\\>')
      end

      def debug(node)
        pp node.reject{|k,v| k == :parent}
      end
    end
  end
end
