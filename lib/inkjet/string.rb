module Inkjet
  module String
    def bold
      clone.bold!
    end

    def bold!
      apply_inkjet_code!(Inkjet::Bold)
    end

    def dim
      clone.dim!
    end

    def dim!
      apply_inkjet_code!(Inkjet::Dim)
    end

    def underline
      clone.underline!
    end

    def underline!
      apply_inkjet_code!(Inkjet::Underline)
    end
    
    def blink
      clone.blink!
    end

    def blink!
      apply_inkjet_code!(Inkjet::Blink)
    end
    
    def invert
      clone.invert!
    end

    def invert!
      apply_inkjet_code!(Inkjet::Invert)
    end
    
    def hidden
      clone.hidden!
    end

    def hidden!
      apply_inkjet_code!(Inkjet::Hidden)
    end
    
    def inkjet_codes
      match(/\e\[([\d;]+)m/)[1].split(";")
    rescue
      Array.new
    end

    def apply_inkjet_code(code)
      clone.apply_inkjet_code!(c)
    end

    def apply_inkjet_code!(code)
      inkjet_codes.length > 0 ? sub!(/\e\[([\d;]+)m/, "\e[#{inkjet_codes.push(code).join(";")}m") : replace("\e[#{code}m#{self}\e[0m")
    end

    def apply_inkjet_codes(*codes)
      sclone = clone
      codes.each { |code| sclone.apply_inkjet_code!(code) }
      sclone
    end
    
    def apply_inkjet_codes!(*codes)
      codes.each { |code| apply_inkjet_code!(code) }
      self
    end

    def clean
      clone.clean!
    end

    def clean!
      gsub!(/\e\[[\d;]+m/, '')
    end
  end
end

String.send :include, Inkjet::String
