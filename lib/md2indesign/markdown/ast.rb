module MD2Indesign
  module Markdown
    class AST
      attr_accessor :ast
      def initialize(md)
        option = {
          input: "GFM"
        }
        @inlines = [:text, :a, :br, :codespan, :dd, :dt, :em, :header, :hr, :li, :p, :strong, :td, :th]

        @ast = Kramdown::Document.new(md, option).to_hashAST

        # correct <section> hierarchy
        @ast[:children] = sectioning(@ast[:children], 1)

        # inline labeling
        @ast[:children] = labeling(@ast[:children])
      end

      def labeling(children)
        # add inline label
        # TODO: inline?
        return if children.nil?
        children.map{|child|
          child[:inline] = @inlines.include?(child[:type])
          labeling(child[:children]) if child[:children]
        }
        children
      end

      def tabling(table)
        # thead > tr > td  => th 
        alignment = table[:options][:alignment]
        table[:children] = table[:children].map {|node|
          node[:children].map {|tr|
            tr[:children].map.with_index {|td, i|
              td[:type] = :th if node[:type] == :thead
              td[:alignment] = alignment[i]
            }
          }
          next node
        }
        table
      end

      def dling(dl)
        # remove <dd><p>hoge</dd> 's <p>
        dl[:children] = dl[:children].map {|c|
          next c if c[:type] == :dt
          c[:children] = c[:children].first[:children]
          next c
        }

        i = 0
        dl[:children] = dl[:children].group_by {|c|
          if c[:type] == :dt
            next i
          elsif c[:type] == :dd
            j = i
            i = i+1
            next j
          end
        }.map{|k, c|
          {:type => :div, :children => c}
        }
        dl
      end

      def sectioning(children, level)
        # first <section> should <article>
        section = {
          type: level == 1 ? :article : :section,
          options: {
            level: level,
          },
          children: [],
        }

        # same level <section> s
        sections = []

        loop do
          # for each same level child
          child = children.shift
          break if child.nil?

          # remove blank
          next if child[:type] == :blank

          child = tabling(child) if child[:type] == :table

          child = dling(child) if child[:type] == :dl

          # add new <section> for next level <h>
          if child[:type] == :header
            if section[:options][:level] < child[:options][:level]
              # Lower level <h>
              # add new <section> under current <section>
              # <section>
              #  <h2>
              #  <section>
              #    <h3> <- here

              # unshift <h>
              children.unshift(child)

              # start recurcive from current point
              # next new <section> starts with unshifted <h>
              section[:children].concat(sectioning(children, child[:options][:level]))
              next
            elsif section[:options][:level] == child[:options][:level]
              # Same level <h>
              # add new <section> to same current level
              # <section>
              #  <h2>
              # </section>
              # <section>
              #  <h2> <- here

              # finish current <section> and add parents child 
              # start same level <section>
              unless section[:children].empty?
                sections.push(section)
                section = {
                  type: :section,
                  options: {
                    level: child[:options][:level]
                  },
                  children: []
                }
              end
              # if current <section> has no child
              # add to current <section>
            elsif section[:options][:level] > child[:options][:level]
              # Upper Level <h>
              # current recurcive should finish
              # <section>
              #   <h2>
              #   <section>
              #     <h3>
              #     <p>
              #   <h2> <- here

              # unshift <h>
              children.unshift(child)

              # finish loop and return from current recurcive function
              break
            end
          end

          # add to current <section>'s children
          section[:children].push(child)
        end

        # last <section>
        sections.push(section)

        # return <section> tree
        # will be child of parent children when returned
        sections
      end
    end
  end
end
