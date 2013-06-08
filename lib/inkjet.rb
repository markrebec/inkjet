require 'active_support/inflector'
require 'inkjet/string'
require 'inkjet/colors'
require 'inkjet/indent'

module Inkjet
  Close     = 0
  Bold      = 1
  Dim       = 2
  Underline = 4
  Blink     = 5
  Invert    = 7
  Hidden    = 8
  include Colors::Formatters

  def self.escape(code)
    "\e[#{code.to_s.chomp('m')}m"
  end

  def self.indent(*args, &block)
    Indent.indent(*args, &block)
  end
end
