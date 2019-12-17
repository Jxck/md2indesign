require "kramdown"
require "kramdown-parser-gfm"
require "rouge"

require "md2indesign/version"

require "md2indesign/format/html"
require "md2indesign/format/idtag"

require "md2indesign/highlighter/html.rb"
require "md2indesign/highlighter/idtag.rb"

require "md2indesign/markdown/ast.rb"
require "md2indesign/markdown/traverser.rb"

module MD2Indesign
  module_function
  def encode(path, option)
    ext  = File.extname(path)
    name = File.basename(path, ext)
    dir  = File.dirname(path)
    body = File.read(path)

    format = case option[:format]
             when "idtag"
               MD2Indesign::Format::Idtag.new(highlight: option[:highlight])
             when "html"
               MD2Indesign::Format::HTML.new(highlight: option[:highlight])
             end

    traverser = MD2Indesign::Markdown::Traverser.new(format, dir)
    ast       = MD2Indesign::Markdown::AST.new(body).ast
    body      = traverser.start(ast)
    entry     = OpenStruct.new({title: path, highlight: option[:highlight], body: body})
    template  = ERB.new(File.read("./template/#{option[:format]}.erb"))
    encoded   = template.result(entry.instance_eval{binding}).strip

    File.write("#{dir}/#{name}.#{option[:highlight]}.#{option[:format]}", encoded)
  end
end
