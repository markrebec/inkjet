module Inkjet
  module String
    
    def method_missing(meth, *args)
      if meth.match(/(#{%w(bold dim underline blink invert hidden).join('|')})(!?)/)
        send "apply_inkjet_code#{$2}", "Inkjet::#{meth.capitalize}".constantize, *args
      else
        super
      end
    end
    
    def clean
      clone.clean!
    end

    def clean!
      gsub!(/\e\[[\d;]+m/, '')
    end

    def apply_inkjet_code(code, wrap=false)
      clone.apply_inkjet_code!(code, wrap)
    end

    def apply_inkjet_code!(code, wrap=false)
      if inkjet_strings.length > 0
        replace(inkjet_strings.map do |istr|
          if wrap # apply the code to every chunk within the string, formatted or unformatted
            
            (istr[0].empty? ? "" : apply_inkjet_codes_to_substring([code], istr[0])) +
            apply_inkjet_codes_to_substring(istr[1].push(code), istr[2]) +
            (istr[3].empty? ? "" : apply_inkjet_codes_to_substring([code], istr[3]))
          
          elsif !inkjet_codes.empty? && istr[1] == inkjet_codes # apply the code only to the formatted chunks of the 'primary string'
            
            istr[0] + apply_inkjet_codes_to_substring(istr[1].push(code), istr[2]) + istr[3]
          
          else # apply the code only to the unformatted chunks of the 'primary string' leaving any formatted substrings untouched
            
            (istr[0].empty? ? "" : apply_inkjet_codes_to_substring([code], istr[0])) +
            apply_inkjet_codes_to_substring(istr[1], istr[2]) +
            (istr[3].empty? ? "" : apply_inkjet_codes_to_substring([code], istr[3]))
          
          end
        end.join(""))
      else # wrap the entire unformatted string w/ the code
        replace("\e[#{code}m#{self}\e[#{Inkjet::Close}m")
      end
    end

    def apply_inkjet_codes(codes, wrap=false)
      cloned = clone
      codes.each { |code| cloned.apply_inkjet_code!(code, wrap) }
      cloned
    end
    
    def apply_inkjet_codes!(codes, wrap=false)
      codes.each { |code| apply_inkjet_code!(code, wrap) }
      self
    end
    
    protected

    # return the first set of escape codes found in the string if no pre-string
    def inkjet_codes
      inkjet_strings.first[0].empty? ? inkjet_strings.first[1] : []
    rescue
      []
    end

    def inkjet_strings
      scan(/([^\e]*)\e\[([\d;]+)m([^\e]*)\e\[#{Inkjet::Close}m([^\e]*)/).map { |pre,codes,str,post| [pre, codes.split(";"), str, post] } # TODO make a class for these
    end

    def apply_inkjet_codes_to_substring(codes, substr)
      "\e[#{codes.join(";")}m#{substr}\e[#{Inkjet::Close}m"
    end

  end
end

String.send :include, Inkjet::String
