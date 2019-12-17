require "cgi"

module MD2Indesign
  module Format
    class HTML
      def initialize(highlight: "none")
        @highlight = highlight
      end

      # indent with depth
      # remove empty line indent
      def indent(str, depth=2)
        space = " "*depth
        str.split("\n").join("\n#{space}").gsub(/^ *$/, "")
      end

      def root(node)
        indent(node[:value].to_s, 4)
      end

      def text(node)
        escape(node[:value])
      end

      def smart_quote(node)
        {
          lsquo: "&lsquo;",
          rsquo: "&rsquo;",
          ldquo: "&ldquo;",
          rdquo: "&rdquo;",
        }[node[:value]]
      end

      def typographic_sym(node)
        {
          hellip: "&hellip;",
          mdash:  "&mdash;",
          ndash:  "&ndash;",
          laquo:  "&laquo;",
          raquo:  "&raquo;",
        }[node[:value]]
      end

      def entity(node)
        # &gt; &lt; etc
        node[:options][:original]
      end

      def header(node)
        level = node[:options][:level]
        "<h#{level}>#{node[:value]}</a></h#{level}>\n"
      end

      def p(node)
        if node[:close]
          <<~EOS
        <p>
          #{indent(node[:value])}
        </p>
          EOS
        else
          "<p>#{node[:value]}\n"
        end
      end

      def ul(node)
        <<~EOS
      <ul>
        #{indent(node[:value])}
      </ul>
        EOS
      end

      def ol(node)
        <<~EOS
      <ol>
        #{indent(node[:value])}
      </ol>
        EOS
      end

      def li(node)
        if node[:close]
          <<~EOS
        <li>
          #{indent(node[:value])}
        </li>
          EOS
        else
          "<li>#{node[:value]}\n"
        end
      end

      def codeblock(node)
        lang = node[:lang]
        %(<pre#{lang ? %( class=#{lang}) : ''}><code translate="no">#{node[:value]}</code></pre>\n)
      end

      def codespan(node)
        %(<code translate="no">#{escape(node[:value])}</code>)
      end

      def code_format(arg)
        lang  = arg[:lang]
        code  = arg[:code]
        lexer = Rouge::Lexer.find(lang)
        case @highlight
        when "mono"
          formatter = MD2Indesign::Highlighter::HTML.new(highlight: "mono")
          formatted = formatter.format(lexer.new.lex(code))
          formatted
        when "color"
          formatter = MD2Indesign::Highlighter::HTML.new(highlight: "color")
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

      def xml_comment(node)
        category = node[:options][:category]
        case category
        when :block
          node[:value] + "\n"
        when :span
          node[:value]
        end
      end

      ### table
      def table(node)
        <<~EOS
      <table>
        #{indent(node[:value])}
      </table>
        EOS
      end
      def thead(node)
        <<~EOS
      <thead>
        #{indent(node[:value])}
      </thead>
        EOS
      end
      def tbody(node)
        <<~EOS
      <tbody>
        #{indent(node[:value])}
      </tbody>
        EOS
      end
      def tr(node)
        <<~EOS
      <tr>
        #{indent(node[:value])}
      </tr>
        EOS
      end
      def th(node)
        "<th class=align-#{node[:alignment]}>#{node[:value]}</th>\n"
      end
      def td(node)
        "<td class=align-#{node[:alignment]}>#{node[:value]}</td>\n"
      end

      ### dl
      def dl(node)
        <<~EOS
      <dl>
        #{indent(node[:value])}
      </dl>
        EOS
      end
      def dt(node)
        "<dt>#{node[:value]}\n"
      end
      def dd(node)
        "<dd>#{node[:value]}\n"
      end

      ### block elements
      def article(node)
        <<~EOS
      <article>
        #{indent(node[:value])}
      </article>
        EOS
      end
      def section(node)
        <<~EOS
      <section>
        #{indent(node[:value])}
      </section>
        EOS
      end
      def div(node)
        <<~EOS
      <div>
        #{indent(node[:value])}
      </div>
        EOS
      end
      def blockquote(node)
        <<~EOS
      <blockquote>
        #{indent(node[:value])}
      </blockquote>
        EOS
      end

      ### inline elements
      def strong(node)
        "<strong>#{node[:value]}</strong>"
      end
      def em(node)
        "<em>#{node[:value]}</em>"
      end
      def br(_node)
        "<br>\n"
      end
      def hr(_node)
        "<hr>\n"
      end
      def span(node)
        # only join children
        node[:children].join("")
      end
      def a(node)
        %(<a href="#{node[:attr]['href']}">#{node[:value]}</a>)
      end
      def img(node)
        %(<img src=#{node[:attr]['src']} alt="#{node[:attr]['alt']}" title="#{node[:attr]['title']}">)
      end

      private
      def escape(str)
        CGI.escape_html(str)
      end

      def debug(node)
        pp node.reject{|k,v| k == :parent}
      end
    end
  end
end
