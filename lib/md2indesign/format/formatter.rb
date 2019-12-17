require "md2indesign/format/html"
require "md2indesign/format/idtag"

module MD2Indesign
  module Format
    module_function

    def formatter(format)
      case format
      when "idtag"
        MD2Indesign::Format::Idtag
      when "html"
        MD2Indesign::Format::HTML
      end
    end
  end
end
