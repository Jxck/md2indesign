require "test_helper"

class MD2IndesignTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MD2Indesign::VERSION
  end

  def test_it_has_class
    refute_nil ::MD2Indesign::Format::HTML
    refute_nil ::MD2Indesign::Format::Idtag
  end

  def test_mono_idtag
    path = "./example/test.md"
    dir  = File.dirname(path)
    body = File.read(path)

    format    = MD2Indesign::Format::Idtag.new(highlight: "mono")
    ast       = MD2Indesign::Markdown::AST.new(body).ast
    traverser = MD2Indesign::Markdown::Traverser.new(format, dir)

    body      = traverser.start(ast)
    entry     = OpenStruct.new({body: body})
    template  = ERB.new(File.read("./template/idtag.erb"))
    idtag     = template.result(entry.instance_eval{binding}).strip

    File.write("#{dir}/test.idtag", idtag)
  end

  def test_color_idtag
    path = "./example/test.md"
    dir  = File.dirname(path)
    body = File.read(path)

    format    = MD2Indesign::Format::Idtag.new(highlight: "color")
    ast       = MD2Indesign::Markdown::AST.new(body).ast
    traverser = MD2Indesign::Markdown::Traverser.new(format, dir)

    body     = traverser.start(ast)
    entry    = OpenStruct.new({body: body})
    template = ERB.new(File.read("./template/idtag.erb"))
    idtag    = template.result(entry.instance_eval{binding}).strip

    File.write("#{dir}/test.color.idtag", idtag)
  end

  def test_html
    path = "./example/test.md"
    dir  = File.dirname(path)
    body = File.read(path)

    format    = MD2Indesign::Format::HTML.new(highlight: "mono")
    ast       = MD2Indesign::Markdown::AST.new(body).ast
    traverser = MD2Indesign::Markdown::Traverser.new(format, dir)

    body     = traverser.start(ast)
    entry    = OpenStruct.new({title: path, body: body})
    template = ERB.new(File.read("./template/html.erb"))
    html     = template.result(entry.instance_eval{binding}).strip

    File.write("#{dir}/test.html", html)
  end
end
