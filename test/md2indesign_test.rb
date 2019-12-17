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
    option = {
      highlight: "mono",
      format:    "idtag",
    }
    ::MD2Indesign::encode(path, option)
  end

  def test_color_idtag
    path = "./example/test.md"
    option = {
      highlight: "color",
      format:    "idtag",
    }
    ::MD2Indesign::encode(path, option)
  end

  def test_mono_html
    path = "./example/test.md"
    option = {
      highlight: "mono",
      format:    "html",
    }
    ::MD2Indesign::encode(path, option)
  end

  def test_color_html
    path = "./example/test.md"
    option = {
      highlight: "color",
      format:    "html",
    }
    ::MD2Indesign::encode(path, option)
  end
end
