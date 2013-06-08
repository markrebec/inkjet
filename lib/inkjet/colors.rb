module Inkjet
  module Colors
    Colors = %w(black red green yellow blue magenta cyan gray white)
    module Foreground
      Black   = 30
      Red     = 31
      Green   = 32
      Yellow  = 33
      Blue    = 34
      Magenta = 35
      Cyan    = 36
      Gray    = 37
      Default = 39
      White   = 97
    end

    module Background
      Black   = 40
      Red     = 41
      Green   = 42
      Yellow  = 43
      Blue    = 44
      Magenta = 45
      Cyan    = 46
      Gray    = 47
      Default = 49
      White   = 107
    end

    def self.foreground(color)
      "::Inkjet::Colors::Foreground::#{color.capitalize}".constantize rescue raise("Color does not exist: '#{color}'")
    end

    def self.background(color)
      "::Inkjet::Colors::Background::#{color.capitalize}".constantize rescue raise("Color does not exist: '#{color}'")
    end

    module Formatters
      def self.included(base)
        base.send :extend, self
      end

      def colorize(color, str)
        colorize!(color, str.clone)
      end
      
      def colorize!(color, str)
        str.apply_inkjet_code!(Inkjet::Colors.foreground(color))
      end

      def colorize_background(color, str)
        colorize_background!(color, str.clone)
      end
      
      def colorize_background!(color, str)
        str.apply_inkjet_code!(Inkjet::Colors.background(color))
      end

      def colorize_with_background(fg_color, bg_color, str)
        colorize_with_background!(fg_color, bg_color, str.clone)
      end
      
      def colorize_with_background!(fg_color, bg_color, str)
        str.apply_inkjet_codes!(Inkjet::Colors.foreground(fg_color), Inkjet::Colors.background(bg_color))
      end

      def method_missing(meth, *args)
        if meth.match(/\A(#{Inkjet::Colors::Colors.push("default").join("|")})_text(!?)\Z/)
          colorize($1, args.map(&:to_s).join(" "))
        elsif meth.match(/\A(#{Inkjet::Colors::Colors.push("default").join("|")})_(background|bg)(!?)\Z/)
          colorize_background($1, args.map(&:to_s).join(" "))
        elsif meth.match(/\A(#{Inkjet::Colors::Colors.push("default").join("|")})_(#{Inkjet::Colors::Colors.push("default").join("|")})(!?)\Z/)
          colorize_with_background($1, $2, args.map(&:to_s).join(" "))
        else
          super
        end
      end
    end

    module String
      def method_missing(meth, *args)
        if meth.match(/\A(#{Inkjet::Colors::Colors.join("|")})(!?)\Z/)
          Inkjet.send("colorize#{$2}", $1, self)
        elsif meth.match(/\A(#{Inkjet::Colors::Colors.join("|")})_(background|bg)(!?)\Z/)
          Inkjet.send("colorize_background#{$3}", $1, self)
        elsif meth.match(/\A(#{Inkjet::Colors::Colors.join("|")})_(#{Inkjet::Colors::Colors.join("|")})(!?)\Z/)
          Inkjet.send("colorize_with_background#{$3}", $1, $2, self)
        else
          super
        end
      end
    end
  
  end
end

String.send :include, Inkjet::Colors::String
