module MD2Indesign
  module Highlighter
    class HTML < Rouge::Formatters::HTML
      def initialize(highlight: "none")
        @highlight = highlight
      end

      def safe_span(tok, safe_val)
        return safe_val if tok == Rouge::Token::Tokens::Text

        classes = tok.qualname.split(".")

        case @highlight
        when "mono"
          "<span class=\"#{self.classname(classes)}\">#{safe_val}</span>"
        when "color"
          "<span class=\"#{classes.join}\">#{safe_val}</span>"
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
    end
  end
end
