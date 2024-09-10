require File.expand_path(File.dirname(__FILE__) + "/neo")

# TIL:
# - Ruby handling of symbols (unique objects, GC, creating a symbol if not already exists when comparing)
# - Why using strings over symbols can be more memory safe (GC, not unique objects)
# - Avoid memory bloat by creating dynamic symbols in a loop or from user input
# - This is why Rails creates string from parameter keys
#
# - MRI stands for Matz's Ruby Interpreter (also known as CRuby). It is the reference implementation of Ruby, written in
#   C. Other implementations include: JRuby, Rubinius, TruffleRuby and mruby. They either focus more on performance or
#   serve a lightweight implentation that can be embedded in other applications
#   Method and Constant names become automatically available as symbols.

class AboutSymbols < Neo::Koan
  def test_symbols_are_symbols
    symbol = :ruby
    assert_equal true, symbol.is_a?(Symbol)
  end

  def test_symbols_can_be_compared
    symbol1 = :a_symbol
    symbol2 = :a_symbol
    symbol3 = :something_else

    assert_equal true, symbol1 == symbol2
    assert_equal false, symbol1 == symbol3
  end

  def test_identical_symbols_are_a_single_internal_object
    symbol1 = :a_symbol
    symbol2 = :a_symbol

    assert_equal true, symbol1 == symbol2
    assert_equal true, symbol1.equal?(symbol2)
  end

  def test_method_names_become_symbols
    symbols_as_strings = Symbol.all_symbols.map { |x| x.to_s }
    assert_equal true, symbols_as_strings.include?("test_method_names_become_symbols")
  end

  # THINK ABOUT IT:
  #
  # Why do we convert the list of symbols to strings and then compare
  # against the string value rather than against symbols?

  # A: When directly comparing against a symbol, Ruby will create a new symbol if it doesn't already exist. Symbols
  # are unique, immutable objects (only one copy of the key is kept in memory). Once a symbol is created, it exists for the duration of the program i.e. it's not
  # garbage collected. (Ruby < 1.8 never GC! Ruby >= 2.2 can reclaim unused symbols, especially dynamically created ones
  # e.g. String#to_sym or :#{dynamic_string})
  #
  # This means that performing a comparison similar to above could result in false being returned on the first run, but
  # true returned on the second run because the a copy of the symbol we were comparing has been created during the first
  # run and now exists in the symbol table (an internal data structure maintained by the Ruby interpreter).
  #
  # Comparing two strings (O(n)) is less efficient than comparing two symbols (O(1)) because you need to compare the
  # contents of the string char by char, whereas with symbols, you're just comparing two integer memory addresses.
  # In the example above, you also incur the overhead of creating each symbol to a string before the assertion. However,
  # due to strings not being unique and getting garbage collected, it is more memory safe to use strings.

  in_ruby_version("mri") do
    RubyConstant = "What is the sound of one hand clapping?"
    def test_constants_become_symbols
      all_symbols_as_strings = Symbol.all_symbols.map { |x| x.to_s }

      assert_equal true, all_symbols_as_strings.include?("RubyConstant")
    end
  end

  def test_symbols_can_be_made_from_strings
    string = "catsAndDogs"
    assert_equal :catsAndDogs, string.to_sym
  end

  def test_symbols_with_spaces_can_be_built
    symbol = :"cats and dogs"

    assert_equal :"cats and dogs", symbol
  end

  def test_symbols_with_interpolation_can_be_built
    value = "and"
    symbol = :"cats #{value} dogs"

    assert_equal :"cats and dogs", symbol
  end

  def test_to_s_is_called_on_interpolated_symbols
    symbol = :cats
    string = "It is raining #{symbol} and dogs."

    assert_equal "It is raining cats and dogs.", string
  end

  def test_symbols_are_not_strings
    symbol = :ruby
    assert_equal false, symbol.is_a?(String)
    assert_equal false, symbol.eql?("ruby")
  end

  def test_symbols_do_not_have_string_methods
    symbol = :not_a_string
    assert_equal false, symbol.respond_to?(:each_char)
    assert_equal false, symbol.respond_to?(:reverse)
  end

  # It's important to realize that symbols are not "immutable
  # strings", though they are immutable. None of the
  # interesting string operations are available on symbols.

  def test_symbols_cannot_be_concatenated
    # Exceptions will be pondered further down the path
    assert_raise(NoMethodError) do
      :cats + :dogs
    end
  end

  def test_symbols_can_be_dynamically_created
    assert_equal :catsdogs, ("cats" + "dogs").to_sym
  end

  # THINK ABOUT IT:
  #
  # Why is it not a good idea to dynamically create a lot of symbols?

  # A: Doing this can lead to memory bloat and as the symbol table grows, performance can be degraded as Ruby internals
  # are affected (symbol lookups etc.)
  # Dynamically creating symbols based on user input or other external sources can pose security risks. DoS attack
  # vulnerability - malicious input could potentially lead to the creation of a large number of symbols, affecting
  # performance or crashing the server due to memory exhaustion.
end
