require "kramdown"
require "kramdown-parser-gfm"
require "rouge"
require "ostruct"

require "md2indesign/version"

require "md2indesign/format/formatter"

require "md2indesign/highlighter/html.rb"
require "md2indesign/highlighter/idtag.rb"

require "md2indesign/markdown/ast.rb"
require "md2indesign/markdown/traverser.rb"

module MD2Indesign
  module_function

  def encode(path, option={})

    ext  = File.extname(path)
    name = File.basename(path, ext)
    dir  = File.dirname(path)
    body = File.read(path)

    format    = option[:format]    || "html"
    highlight = option[:highlight] || "color"
    outfile   = option[:outfile]   || "#{dir}/#{name}.#{highlight}.#{format}"
    template  = option[:template]  || "#{__dir__}/../template/#{format}.erb"

    puts "\e[1;34mencode #{path} with #{highlight}.#{format} to #{outfile}\e[0m"

    formatter = MD2Indesign::Format::formatter(format).new(highlight: highlight)
    traverser = MD2Indesign::Markdown::Traverser.new(formatter, dir)
    ast       = MD2Indesign::Markdown::AST.new(body).ast

    body      = traverser.start(ast)
    entry     = OpenStruct.new({title: path, highlight: highlight, body: body})
    encoded   = ERB.new(File.read(template)).result(entry.instance_eval{binding}).strip

    File.write(outfile, encoded)
  end
end
