module Inkjet
  class Substring
    attr_accessor :pre, :codes, :string, :post

    def push(code)
      codes.push(code)
      self
    end
    
    def unshift(code)
      codes.unshift(code)
      self
    end

    def formattable?(chunk)
      !chunk.nil? && !chunk.empty? #&& !chunk.match(/\A[\r\n]+\Z/)
    end

    # Formats a chunk of the substring
    #
    # If no codes are provided, or the chunk is empty, it si not formatted
    def format_chunk(chunk, codes)
      codes = [codes].flatten
      return chunk if !formattable?(chunk) || (codes.nil? || codes.empty?)
      "\e[#{codes.join(";")}m#{chunk}\e[#{Inkjet::Close}m"
    end

    # Format the string by applying the proper codes to various chunks of the string.
    #
    # The primary string is formatted with this object's @codes
    #
    # If a super_code is provided, it is used to format the superstring (pre/post) chunks,
    # otherwise they are left unformatted.
    def format(super_code=nil)
      format_chunk(pre, super_code) +
      format_chunk(string, codes) +
      format_chunk(post, super_code)
    end

    private

    def initialize(pre, codes, string, post)
      @pre = pre
      @codes = codes
      @string = string
      @post = post
    end
  end

  module String

    # Clean out all escape codes from the formatted string
    def clean!
      gsub!(/\e\[[\d;]+m/, '')
    end
    
    def clean
      dup.clean!
    end

    # Apply a formatting code to the appropriate chunks in the string.
    #
    # If forcing a wrap, all chunks within the string get formatted with the new code, regardless of whether they were previously formatted
    #
    # If there are codes applied to the first chunk of the string, apply the new code to all previously formatted chunks with matching codes
    #
    # If the first chunk of the string is unformatted, apply the new code to all unformatted chunks
    #
    # If the string is completely unformatted, enclose self within the provided code
    def apply_inkjet_code!(code, wrap=false)
      if inkjet_substrings.length > 0
        
        replace(inkjet_substrings.map do |substr|
          if wrap # apply the code to every chunk within the string, formatted or unformatted
            substr.push(code).format(code)
          elsif !inkjet_codes.empty? && substr.codes == inkjet_codes # apply the code only to formatted chunks with matching codes
            substr.push(code).format
          else # apply the code only to the unformatted chunks
            substr.format(code)
          end
        end.join)

      else # enclose the entire unformatted string w/ the code
        replace("\e[#{code}m#{self}\e[#{Inkjet::Close}m")
      end
    end

    def apply_inkjet_code(code, wrap=false)
      dup.apply_inkjet_code!(code, wrap)
    end

    def apply_inkjet_codes(codes, wrap=false)
      dupd = dup
      codes.each { |code| dupd.apply_inkjet_code!(code, wrap) }
      dupd
    end
    
    def apply_inkjet_codes!(codes, wrap=false)
      codes.each { |code| apply_inkjet_code!(code, wrap) }
      self
    end
    
    protected

    # Return the first set of escape codes found in the string if no pre-string.
    # 
    # This determines whether the main chunks of the string are already formatted or not,
    # and helps decide whether multiple chunks of a string should be formatted when not 
    # forcing everything to be wrapped.
    def inkjet_codes
      inkjet_substrings.first.pre.empty? ? inkjet_substrings.first.codes : []
    rescue
      []
    end

    # Scan the string for formatted chunks and their surrounding unformatted chunks and
    # return an array of Inkjet::Substring objects.
    def inkjet_substrings
      scan(/([^\e]*)\e\[([\d;]+)m([^\e]*)\e\[#{Inkjet::Close}m([^\e]*)/).map { |pre,codes,str,post| Inkjet::Substring.new(pre, codes.split(";"), str, post) }
    end

  end
end

String.send :include, Inkjet::String
