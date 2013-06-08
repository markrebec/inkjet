# Inkjet

Formatting, indentation, bash colors, etc. for ruby cli script output.

## Installation

    gem install inkjet

Or, if you're using bundler, add this to your Gemfile:

    gem 'inkjet'

## Usage

Inkjet provides some helper methods within the `Inkjet` namespace, but most of the formatting can be done inline on your string object and can be chained together.

### Colors

Available Colors: black, red, green, yellow, blue, magenta, cyan, gray, white
    
    puts "Hello World".blue             # Sets text color to blue
    puts "Hello World".red_background   # Sets the background color of the text to red
    puts "Hello World".red.green_bg     # Sets text color to red and background color to green
    puts "Hello World".blue_yellow      # Sets text color to blue and background color to yellow

All methods are aliased to their bang (`!`) counterparts to modify your string in place.
    
    my_str = "Hello World"
    my_str.blue!                        # my_str is now permanently blue
    my_str.yellow_bg!                   # my_str now also permanently has a yellow background

Colors will override each other.

    puts "Hello World".blue.yellow                     # Text will be yellow
    puts "Hello World".blue.magenta_bg.red.green_bg    # Text will be red on a green background

### Formatting

There are a few methods for other types of formatting as well.

    puts "Hello World".bold         # Makes text bold
    puts "Hello World".dim          # Makes text dim
    puts "Hello World".underline    # Makes text underlined
    puts "Hello World".blink        # Makes text blink
    puts "Hello World".invert       # Invert foreground and background color
    puts "Hello World".hidden       # Hides text (same color as background)

### Indentation

You can indent your text 'x' number of spaces with the 'indent' method.

    puts "Hello World".indent       # Indents by 2 spaces
    puts "Hello World".indent(8)    # Indents by 8 spaces
    my_str = <<STRING
    Hello
    World
    STRING
    puts my_str.indent              # Indents all newlines the same amount

#### Nesting

You can also use the `Inkjet.indent` method with a block for nested indentation. When passing a block to `Inkjet.indent` your calls to `puts` and `print` will be automatically indented to the current nested indentation level.

    puts "This is not indented"

    Inkjet.indent do
      puts "This is indented 2 spaces"
      
      Inkjet.indent(10) do
        print "This is indented 12 spaces"
      end
      
      Inkjet.indent do
        my_str <<EXAMPLE
    Each of these lines
    will be indented 4 spaces
        but this line will be indented 8 spaces because leading whitespace is not stripped
    EXAMPLE
        puts my_str
      end
    end
