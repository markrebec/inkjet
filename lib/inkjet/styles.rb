module Inkjet
  module Styles
    Styles = %w(bold dim underline blink invert hidden)
    Bold      = 1
    Dim       = 2
    Underline = 4
    Blink     = 5
    Invert    = 7
    Hidden    = 8
    
    def self.style(style)
      "Inkjet::Styles::#{style.capitalize}".constantize rescue raise("Style does not exist: '#{style}'")
    end

    module Formatters
      def self.included(base)
        base.send :extend, self
      end

      def stylize(style, str, wrap=false)
        stylize!(style, str.dup, wrap)
      end
      
      def stylize!(style, str, wrap=false)
        str.apply_inkjet_code!(Inkjet::Styles.style(style), wrap)
      end

      def method_missing(meth, *args)
        if meth.match(/\A(#{Inkjet::Styles::Styles.join("|")})(!?)\Z/)
          stylize($1, *args)
        else
          super(meth, *args)
        end
      end
    end

    module String
      def method_missing(meth, *args)
        if meth.match(/\A(#{Inkjet::Styles::Styles.join("|")})(!?)\Z/)
          Inkjet.send("stylize#{$2}", $1, self, *args)
        else
          super(meth, *args)
        end
      end
    end
  
  end
end

String.send :include, Inkjet::Styles::String
