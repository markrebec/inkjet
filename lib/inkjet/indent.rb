module Inkjet
  module Indent
    TABSTOP = 2 # TODO set based on config

    class Formatter
      def call_on(str)
        str.send @meth, *@args
      end

      protected

      def initialize(meth, *args)
        @meth = meth.to_sym
        @args = args
      end
    end

    def self.add_bindings(block)
      block.binding.eval("def puts(output=''); Inkjet::Indent.puts(output); end")
      block.binding.eval("def print(output=''); Inkjet::Indent.print(output); end")
      block.binding.eval("def format_with(meth, *args); Inkjet::Indent.format_with(meth, *args); end")
      block.binding.eval("def undent(&block); Inkjet::Indent.undent(&block); end")
      block
    end

    def self.indent(*args, &block)
      @@spaces ||= 0
      if block_given?
        @@spaces += args[0] || TABSTOP
        scoped_formatters = formatters.clone

        add_bindings(block).call
        
        @@formatters = scoped_formatters
        @@spaces -= args[0] || TABSTOP
      else
        spaces = args[1] || TABSTOP
        "#{padding(spaces.to_i)}#{args[0].to_s.split("\n").join("\n#{padding(spaces.to_i)}")}"
      end
    end

    def self.undent(&block)
      @@spaces ||= 0
      if block_given?
        scoped_spaces = @@spaces
        @@spaces = 0
        scoped_formatters = formatters.clone

        add_bindings(block).call
        
        @@formatters = scoped_formatters
        @@spaces = scoped_spaces
      end
    end

    def self.formatters
      @@formatters ||= []
    end

    def self.format_with(fmeth, *fargs)
      formatters.push(Formatter.new(fmeth, *fargs))
    end

    def self.apply_formatters(output)
      formatters.each { |f| output = f.call_on(output) }
      output
    end

    def self.padding(spaces)
      spaces.times.map {" "}.join
    end

    def self.puts(output='')
      STDOUT.puts apply_formatters(indent(output, @@spaces))
    end

    def self.print(output='')
      STDOUT.print apply_formatters(indent(output, @@spaces))
    end

    module String
      def indent(*args)
        Inkjet::Indent.indent(*args.unshift(self))
      end
    end

  end
end

String.send :include, Inkjet::Indent::String
