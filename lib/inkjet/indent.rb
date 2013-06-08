module Inkjet
  module Indent
    TABSTOP = 2 # TODO set based on config
    
    def self.indent(*args, &block)
      @spaces ||= 0
      if block_given?
        @spaces += args[0] || TABSTOP
        class_eval &block
        @spaces -= args[0] || TABSTOP
      else
        spaces = args[1] || TABSTOP
        "#{padding(@spaces + spaces.to_i)}#{args[0].to_s.split("\n").join("\n#{padding(@spaces + spaces.to_i)}")}"
      end
    end

    def self.padding(spaces)
      spaces.times.map {" "}.join
    end

    def self.puts(output)
      STDOUT.puts indent(output, 0)
    end

    def self.print(output)
      STDOUT.print indent(output, 0)
    end

    module String
      def indent(*args)
        Inkjet::Indent.indent(*args.unshift(self))
      end
    end

  end
end

String.send :include, Inkjet::Indent::String
