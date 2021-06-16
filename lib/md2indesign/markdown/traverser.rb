module MD2Indesign
  module Markdown
    # build with format during traverse ast
    class Traverser
      attr_reader :codes

      def default_plugin
        {
          :enter => lambda {|node| node}, # call after  enter
          :leave => lambda {|node| node}, # call before leave
        }
      end

      def initialize(format, dir, plugin=default_plugin)
        @codes  = {} # escape codeblock here
        @format = format
        @dir    = dir
        @plugin = plugin
      end

      def start(ast)
        ast[:parent] = nil
        # traverse whole of AST
        result = traverse(ast)

        # @codes has escaped codeblock while traverse
        # for avoid indent
        # repalce them with hash
        @codes.each {|key, value|
          # formatting code
          code = @format.code_format(value)
          # replace with hash
          result.gsub!("// #{key}") { code }
        }

        result
      end

      def traverse(node)
        enter(node)
        @plugin[:enter].call(node) # call plugin

        node[:children] = node[:children]&.map {|child|
          #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          # cyclic reference for plugin
          #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          child[:parent] = node

          # hide :parent when output
          class <<child
            def inspect
              self.reject{|k,v| k == :parent}.inspect
            end
            def to_s
              self.reject{|k,v| k == :parent}.to_s
            end
          end
          traverse(child)
        }

        @plugin[:leave].call(node) # call plugin
        leave(node)
      end

      def enter(node)
        # doing pre-process which necessary to see child from parent
        # while traverse down

        if node[:type] == :html_element
          # html element has tag name in :value
          # but :value should have processed children
          # so move tagname from :value to :tag
          node[:tag]   = node[:value]
          node[:value] = ""
        end

        if node[:type] == :blockquote
          # children has multi-line <p> with <br>
          # ex) <p>lorem<br>ipsum</p>
          p = node[:children][0]

          # split with <br> and separate multi <p>
          # ex) <p>lorem</p><p>ipsum</p>
          children = p[:children].reduce([{type: :p, children: []}]) {|acc, e|
            if e[:type] === :text and e[:value].start_with?("\n")
              e[:value] = e[:value].gsub("\n", "")
            end

            if e[:type] === :br
              acc << {type: :p, children: []}
            else
              acc.last[:children] << e
            end
            acc
          }

          node[:children] = children
        end

        if node[:type] == :ul or node[:type] == :ol
          # add the <ul>/<ol> nested level
          # first level is 1
          node[:level] = 1 if node[:level].nil?
        end

        if node[:type] == :li
          # remove <p> of <li><p>foo</p></li>
          first = node[:children].shift
          if first[:type] == :p
            first[:children].reverse.each{|child|
              node[:children].unshift child
            }
          end

          # close <li> as default
          node[:close] = true
          if node[:children].size == 1 and node[:children].first[:inline]
            # if <li> has only single :text, don't close
            node[:close] = false
          end

          # li has nested <ul>/<ol>
          # increment level of <li>'s parent
          node[:children].map {|child|
            if child[:type] == :ul or child[:type] == :ol
              child[:level] = node[:parent][:level] + 1
            end
          }
        end

        # close <p> when child is <img>
        if node[:type] == :p and node&.[](:children).first&.[](:type) == :img
          node[:close] = true
        end

        # pass @dir to formatter
        if node[:type] == :img
          node[:dir] = @dir
        end
      end

      def leave(node)
        # puts "[##{__LINE__}] leave: #{node[:type]} #{node[:value]}"

        if node[:type] == :codeblock
          lang = node[:attr] && node[:attr]["class"].sub("language-", "")
          code = node[:value].chomp
          if code == ""
            # if node code, then read from file
            # ex) ```js:main.js <- read from main.js
            lang, node[:path] = lang.split(":")
            path = "#{@dir}/#{node[:path]}"
            code = File.read(path).chomp
          end

          # indent while building will break codeblock indent
          # so remove codeblock with hash and escape to @codes
          # after builed has done, replace hash & @codes
          hash = code.hash.to_s
          node[:value] = "// #{hash}" # place hash of code as value
          node[:code]  = code         # but add codeblock as-is to :code proparty
          node[:lang]  = lang
          @codes[hash] = {lang: lang, code: code} # escape into HashMap {hash_of_code => code}
        end

        # join children as value
        if node[:children]
          node[:value] = node[:children].join
        end

        # call formatter method for build each tag
        up = @format.send(node[:type], node)
        up
      end
    end
  end
end
