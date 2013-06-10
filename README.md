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

    puts "Hello World".blue.yellow                      # Text will be yellow
    puts "Hello World".blue.magenta_bg.red.green_bg     # Text will be red on a green background

Passing `true` to any color method will force the addition of that color formatting to the entire string, including previously formatted substrings.

    name = "Mark"
    puts "Hello #{name.cyan}, how are #{"you".green}?".blue        # The `name` will by cyan, the word 'you' will be green and all surrounding text will be blue
    puts "Hello #{name.cyan}, how are #{"you".green}?".blue(true)  # All text will be blue, including previously formatted or colored substrings like the `name` and the text 'you'

### Formatting

There are a few methods for other types of formatting as well.

    puts "Hello World".bold         # Makes text bold
    puts "Hello World".dim          # Makes text dim
    puts "Hello World".underline    # Makes text underlined
    puts "Hello World".blink        # Makes text blink
    puts "Hello World".invert       # Invert foreground and background color
    puts "Hello World".hidden       # Hides text (same color as background)

As with the color methods, passing `true` to any formatting method will force the addition of that formatting to the entire string, including previously formatted substrings.

    name = "Mark"
    puts "Hello #{name.underline}, how are #{"you".green}?".bold        # The `name` will be underlined but not bold, the text 'you' will be green but not bold, and all surrounding text will be bold
    puts "Hello #{name.underline}, how are #{"you".green}?".bold(true)  # The `name` will be underlined, the text 'you' will be green, and the entire string (including `name` and 'you') will be bold

### Indentation

You can indent your text any number of spaces with the `String#indent` method.

    puts "Hello World".indent       # Indents by 2 spaces
    puts "Hello World".indent(8)    # Indents by 8 spaces
    my_str = <<STRING
    Hello
    World
    STRING
    puts my_str.indent              # Indents all newlines the same amount

It should be noted that indentation is not accounted for when formatting a string with styles and colors. Most of the time you don't need to even think about it, but because indentation is handled by padding with spaces, things like background colors or underline will apply to the padding.

This means that if you were to call this:

    "Hello World".blue_background.indent(10)

You would end up with 10 empty spaces, and "Hello World" with a blue background.

However, if you called the methods in the opposite order:

    "Hello World".indent(10).blue_background

You would end up with a blue background behind the entire string, including the padded spaces.

#### Nesting

You can also use the `Inkjet.indent` method with a block for nested indentation. When passing a block to `Inkjet.indent` your calls to `puts` and `print` will be automatically indented to the current nested indentation level.

    puts "This is not indented"

    Inkjet.indent do
      puts "This is indented 2 spaces"
      
      Inkjet.indent(10) do
        print "This is indented 12 spaces"
      end

      puts "This is indented 6 spaces".indent(4) # string helpers will indent properly within nested blocks
      
      Inkjet.indent do
        my_str <<EXAMPLE
    Each of these lines
    will be indented 4 spaces
        but this line will be indented 8 spaces because leading whitespace is not stripped
    EXAMPLE
        puts my_str
      end
    end

**Note: Because inkjet currently uses a call to `class_eval` for nested indentation blocks, there are some scoping issues. For example, instance variables referenced inside the block might not behave as you would expect (they would reference instance vars belonging to the `Inkjet::Indent` module).** This should be cleaned up in future versions, when the indentation logic gets cleaned up and refactored.

#### Custom Formatters

If you'd like to easily format everything within an `Inkjet.indent` block, you can use the `format_with` method and pass any of the color or style formatting methods.

    # All outputted text will be indented 10 spaces and be green
    Inkjet.indent(10) do
      format_with :green
      puts "Hello!"
      puts "How are you?"
    end

These formatters also support the force wrapping argument that the color and style formatting methods support. Using the same example as above:
    
    # All outputted text will be indented 10 spaces, "Hello!" will be blue and "How are you?" will be green.
    # The inline blue formatter is not overridden by the green formatter applied to the block.
    Inkjet.indent(10) do
      format_with :green
      puts "Hello!".blue
      puts "How are you?"
    end
    
    # All outputted text will be indented 10 spaces and be green.
    # The `true` argument tells the green block formatter to override the inline blue formatter.
    Inkjet.indent(10) do
      format_with :green, true
      puts "Hello!".blue
      puts "How are you?"
    end
