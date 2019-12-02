module MD2Indesign
  module Highlighter
    class Idtag < Rouge::Formatter
      def stream(tokens, &b)
        tokens.each { |tok, val| yield span(tok, val) }
      end

      def span(token, val)
        val = escape(val)
        return val if token == Rouge::Token::Tokens::Text

        classes = token.qualname.split(".")

        return "<CharStyle:#{self.classname(classes)}>#{val}<CharStyle:>"
      end

      def classname(classes)
        return ("RegularSilverItalic") if classes.include?("Comment")
        return ("RegularSilverItalic") if classes.include?("String")
        return ("RegularDark"        ) if classes.include?("Number")
        return ("RegularDark"        ) if classes.include?("Operator")
        return ("BoldBlack"          ) if classes.include?("Label")
        return ("BoldBlack"          ) if classes.include?("Tag")
        return ("BoldGray"           ) if classes.include?("Name")
        return ("BoldBlack"          ) if classes.include?("Keyword")
        classes.join(" ")
      end
      private
      def escape(str)
        str
          .gsub('\\', '\\\\')
          .gsub('<', '\\<')
          .gsub('>', '\\>')
      end
    end
  end
end
