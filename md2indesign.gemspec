# -*- encoding: utf-8 -*-
# stub: md2indesign 0.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "md2indesign".freeze
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/jxck/md2indesign" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jxck".freeze]
  s.bindir = "exe".freeze
  s.date = "2020-05-18"
  s.description = "convert markdown to indesign tagged text format".freeze
  s.email = ["block.rxckin.beats@gmail.com".freeze]
  s.executables = ["md2indesign".freeze]
  s.files = [".gitignore".freeze, ".travis.yml".freeze, "Gemfile".freeze, "Gemfile.lock".freeze, "README.md".freeze, "Rakefile".freeze, "bin/console".freeze, "bin/setup".freeze, "example/code/Makefile".freeze, "example/code/http".freeze, "example/code/nginx.conf".freeze, "example/code/sample.go".freeze, "example/code/sample.html".freeze, "example/code/sample.java".freeze, "example/code/script.js".freeze, "example/code/style.css".freeze, "example/test.color.html".freeze, "example/test.color.idtag".freeze, "example/test.md".freeze, "example/test.mono.html".freeze, "example/test.mono.idtag".freeze, "exe/md2indesign".freeze, "lib/md2indesign.rb".freeze, "lib/md2indesign/format/formatter.rb".freeze, "lib/md2indesign/format/html.rb".freeze, "lib/md2indesign/format/idtag.rb".freeze, "lib/md2indesign/highlighter/html.rb".freeze, "lib/md2indesign/highlighter/idtag.rb".freeze, "lib/md2indesign/markdown/ast.rb".freeze, "lib/md2indesign/markdown/traverser.rb".freeze, "lib/md2indesign/version.rb".freeze, "md2indesign.gemspec".freeze, "template/css/color.css".freeze, "template/css/mono.css".freeze, "template/html.erb".freeze, "template/idtag.erb".freeze]
  s.homepage = "https://github.com/jxck/md2indesign".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "markdown to indesign".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<kramdown>.freeze, ["> 2.3.0"])
    s.add_runtime_dependency(%q<kramdown-parser-gfm>.freeze, ["= 1.1.0"])
    s.add_runtime_dependency(%q<rouge>.freeze, ["= 3.12.0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
  else
    s.add_dependency(%q<kramdown>.freeze, ["> 2.3.0"])
    s.add_dependency(%q<kramdown-parser-gfm>.freeze, ["= 1.1.0"])
    s.add_dependency(%q<rouge>.freeze, ["= 3.12.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
  end
end
