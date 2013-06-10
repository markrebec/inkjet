require 'active_support/inflector'
require 'inkjet/string'
require 'inkjet/colors'
require 'inkjet/styles'
require 'inkjet/indent'

module Inkjet
  Close     = 0
  include Colors::Formatters
  include Styles::Formatters

  def self.escape(code)
    "\e[#{code.to_s.chomp('m')}m"
  end

  def self.indent(*args, &block)
    Indent.indent(*args, &block)
  end
end
