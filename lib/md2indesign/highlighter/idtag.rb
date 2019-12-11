module MD2Indesign
  module Highlighter
    class Idtag < Rouge::Formatter
      def initialize(highlight: "none")
        @highlight = highlight
      end

      def stream(tokens, &b)
        tokens.each { |tok, val| yield span(tok, val) }
      end

      def span(token, val)
        val = escape(val)
        return val if token == Rouge::Token::Tokens::Text

        classes = token.qualname.split(".")

        case @highlight
        when "mono"
          "<CharStyle:#{self.classname(classes)}>#{val}<CharStyle:>"
        when "color"
          "<CharStyle:Code#{classes.join}>#{val}<CharStyle:>"
        end
      end

      def classname(classes)
        return "CodeItalic" if classes.include?("Comment")
        return "CodeItalic" if classes.include?("String")
        return "CodePale"   if classes.include?("Number")
        return "CodePale"   if classes.include?("Operator")
        return "CodeBold"   if classes.include?("Label")
        return "CodeBold"   if classes.include?("Tag")
        return "CodeMedium" if classes.include?("Name")
        return "CodeBold"   if classes.include?("Keyword")
        return "CodeError"  if classes.include?("Error")
        return "CodeOther"
      end

      private
      def escape(str)
        str
          .gsub(/\\/){'\\\\'}
          .gsub('<', '\\<')
          .gsub('>', '\\>')
      end
    end
  end
end
