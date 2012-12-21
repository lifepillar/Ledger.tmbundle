# -*- coding: utf-8 -*-
module Ledger
  module Html5

    # Turns a set of key-value pairs into a string of html attributes.
    # For example, { :class => ['foo','baz'], :id => 'abc'} is translated into
    # ' class="foo baz" id="abc"'.
    def self.attributes hash
      return '' if hash.nil?
      s = ''
      hash.each_pair do |k,v|
        unless v.nil? or v.empty?
          s << " #{k.to_s}=\"#{v.instance_of?(String) ? v : v.join(' ')}\""
        end
      end
      return s
    end

    class Page

      attr :title

      def initialize title, options = {}
        @title = title
        @attrs = { :class => [], :id => '', :css => [] }.merge!(options)
        @css = Array.new(@attrs[:css])
        @attrs.delete(:css)
        @snippets = []
      end

      def << snippet
        if snippet.instance_of?(String)
          @snippets << Ledger::Html5::Snippet.new(nil, snippet)
        else
          @snippets << snippet
        end
        return self
      end

      # Returns the last added snippet.
      def last_snippet
        @snippets.last
      end

      def to_s
        c = start_html
        @snippets.each { |s| c << s.to_s }
        c << end_html
        return c
      end

      def save path
        File.open(path, "w").write(self.to_s)
      end

      def start_html
        attrs = Ledger::Html5.attributes(@attrs)
        return "<!DOCTYPE html>\n<html>\n" + header + "<body#{attrs}>\n<h1>#{title}</h1>\n"
      end

      def end_html
        "</body>\n</html>\n"
      end

      def header
        "<head>\n<meta charset=\"UTF-8\">\n<title>#{title}</title>\n#{css}</head>\n"
      end

      def css
        return '' if @css.empty?
        style = "<style>\n"
        @css.each do |ss|
          style << File.open(ENV["TM_BUNDLE_SUPPORT"] + "/css/#{ss}.css", 'r').read
        end
        style << "</style>\n"
        return style
      end

    end # class Page

    class Snippet
      
      # Creates a new html snippet. The content can be a single string or snippet,
      # or a list of strings/snippets.
      #
      # Example:
      #
      #   sect = Snippet.new('section', '<h2>Title</h2><p>Blah blah</p>', :class => 'foo')
      def initialize tag, content, attrs = {}
        @tag = tag
        if content.nil?
          @content = []
        elsif content.instance_of?(Array)
          @content = content
        else
          @content = [content]
        end
        @attrs = attrs
      end

      def << snippet
        @content << snippet
      end

      def to_s
        s = ''
        s << '<' + @tag + Ledger::Html5.attributes(@attrs) + ">\n" unless @tag.nil?
        @content.each do |c|
            s << c.to_s
        end
        s << '</' + @tag + ">\n" unless @tag.nil?
        return s
      end

    end # class Snippet

    class Svg

      @@unique_id = 100000

      attr :id
      attr :name

      def initialize path
        @xml = File.open(path, 'r').read
        @name = File.basename(path, '.svg')
        @id = @name.downcase.gsub(/\s/,'-')
      end

      # Returns code suitable to be embedded into an HTML5 page.
      def to_s
        # Make xlink:hrefs unique across all the SVG images generated in one run.
        ideez =[]
        # 1) Collect all id's
        @xml.scan(/id\s*=\s*"(.+?)"/) do |match|
          ideez << match[0]
        end
        # 2) For each id, replace all of its occurrences with a new, unique, id
        ideez.each do |id|
          @xml.gsub!(/#{id}/, @@unique_id.to_s)
          @@unique_id += 1
        end
        @xml.gsub!(/^\s*<\?xml.*?\?>\n?/,'')
        @xml.sub!(/width=".+?"/, 'width="100%"')
        # Apparently, there is a bug in Safari 6 and in some versions of Chrome preventing labels
        # to be displayed when SVG images are inlined in HTML5 documents. The problem resides in the <use> tag.
        # See for example:
        #
        # http://stackoverflow.com/questions/12686247/safari-6-svg-tag-use-issues
        # http://stackoverflow.com/questions/11514248/svg-use-elements-in-chrome-not-displayed
        #
        # The last link described a workaround: instead of <use ... />, write <use ...></use>.
        # This is what we do here:
        @xml.gsub!(/<use(.+?)\/>/) { |m| '<use' + $1 + '></use>' }
        return @xml
      end

    end # class Svg

  end # end module Html5
end # module Ledger
