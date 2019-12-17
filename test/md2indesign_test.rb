require "test_helper"

class MD2IndesignTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MD2Indesign::VERSION
  end

  def test_it_has_class
    refute_nil ::MD2Indesign::Format::HTML
    refute_nil ::MD2Indesign::Format::Idtag
  end

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

  def test_mono_idtag
    path = "./example/test.md"
    option = {
      highlight: "mono",
      format:    "idtag",
    }
    encode(path, option)
  end

  def test_color_idtag
    path = "./example/test.md"
    option = {
      highlight: "color",
      format:    "idtag",
    }
    encode(path, option)
  end

  def test_mono_html
    path = "./example/test.md"
    option = {
      highlight: "mono",
      format:    "html",
    }
    encode(path, option)
  end

  def test_color_html
    path = "./example/test.md"
    option = {
      highlight: "color",
      format:    "html",
    }
    encode(path, option)
  end
end
