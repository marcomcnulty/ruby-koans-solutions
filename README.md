# Ruby Koans

## Why?

I came across the [Ruby Koans](https://github.com/edgecase/ruby_koans) project by chance and thought it looked fun and a
good way to revisit Ruby fundamentals.

## TIL

I've summarised all my learnings below (also individually found in their respective files). There's a mix of "Wow! How
did I not know that!?!?" as well as reminders to future self and some "Duh!"s.

### Arrays

- If the second argument when array slicing is "out of bounds" Ruby simply returns the elements up to the end of the
  array.

- If the first argument is "out of bounds" when slicing an array then `nil` is returned, unless the first argument is
  equal to the length of the array, in which case, you're slicing from the end of the array which is still considered
  valid, so an empty array is returned.

- Triple dot in range excludes last element.

### Blocks

- Methods can take blocks

- When iterating over a collection, the block variable is only a copy of the item in the original data structure.
  Therefore, if you want to update the item within the block and have the change persist, you need to explicitly access
  the original object and modify the item, or use methods that modify in place like map!.

- Variables defined in a for loop block are accessible outside of the block because for loops do not create their own
  scope.

- When you use the block syntax for opening a file, Ruby will automatically handle closing the file when the work
  within the block is done. It will also close the file in case of an exception. Without using a block, you have to
  manually close the file, and in the event of an exception, a memory leak could arise from an open file handle. The
  block also has the added advantage that, it is clear the file is only needed within the scope of the block.

### Classes

- Instance variables are stored as symbols within the `instance_variables` array.

- You can retrieve an instance variable with:

  - `instance_variable_get("@name")`
  - `instance_eval("@name")`
  - `instance_eval { @name }`

- Defining a class more than once, results in the class definitions being merged. If a method with the same name exists
  in both classes, the method defined last will overwrite the previously defined method.

- A Singleton class is a special, hidden class that is created for a specific object to hold methods that are only
  applicable to that single object. This allows you to define methods on a per-object basis, rather than on the class as
  a whole. Most commonly used when you want to define methods that only apply to a single instance of a class, rather
  than to all instances of that class. For example, you might want a specific object to have a custom behavior that
  other instances of the same class don’t share. You can access an object’s singleton class using the `class << object`
  syntax. Inside this block, any method definitions are added to the singleton class of the object.

Example using the `remove_method` method:

```
# Define a base class
class Animal
  def speak
    "I'm an animal"
  end
end

# Define a subclass
class Dog < Animal
  def speak
    "Woof!"
  end
end

# Create an instance of the Dog class
fido = Dog.new

#Define a singleton method on the instance `fido`
def fido.speak
  "Bark!"
end

# Define another singleton method on `fido`
def fido.run
  "Running fast!"
end

# Test the inheritance and method look-up
puts fido.speak => "Bark!" (singleton method on `fido`)
puts fido.run   => "Running fast!" (singleton method on `fido`)

# Create another instance of Dog
rover = Dog.new

# Check if `rover` has access to the singleton methods defined on `fido`
puts rover.speak             => "Woof!" (regular method from the `Dog` class)
puts rover.respond_to?(:run) => false (singleton method `run` is not available to `rover`)

# Remove the singleton method `speak` from `fido`
class << fido
  remove_method :speak
end

# Now `fido` will use the method from the `Dog` class
puts fido.speak => "Woof!" (method from the `Dog` class after singleton method is removed)

# Remove the method `speak` from the `Dog` class and `fido` will look up to `Animal`
class Dog
  remove_method :speak
end

# Now `fido` will use the method from the `Animal` class
puts fido.speak => "I'm an animal" (method from the `Animal` class after instance method is removed from Dog)
```

- There are 2 major ways to write class methods:

```
class Demo
  def self.method
  end

  class << self
    def class_methods
    end
  end
end
```

- If a class had many class methods then you'd typically follow the second example, as it would look cleaner and better
  organise the code, otherwise, the first example is the norm.

- When nesting classes, it often helps to pass a reference of the enclosing class to the nested class, so that the
  nested class is aware of its context.

### Methods

- When `super` is called within a method, it can only call that same method throughout the lookup chain.

- You can return a value with break statement e.g. `break i if i % 2 == 0`.

- EVERY statement in Ruby will return a value. Ruby methods return the last evaluated expression by default. This will
  be `nil` when a method or block doesn't explicitly evaluate to anything. Many of Ruby’s built-in methods, however,
  particularly from classes like Array, Hash, String, and Enumerable, will return a useful value rather than `nil`.

- Methods with named parameters can be called without any arguments and the values belonging to the parameters will be
  used by default.

- Methods can have mandatory parameters and optional parameters but the optional params must come after the named ones.

- By providing a named parameter without a value, you make it a mandatory named parameter.

- The `__send__` method exists to avoid conflicts with methods that might be named `send` in user-defined classes
  or libraries. If a class or module defines its own send method, it would override Ruby’s built-in send method,
  which could lead to unexpected behavior. `__send__` always refers to the method-invoking functionality, regardless
  of whether `send` is redefined.

- The `method_missing` method can be overridden to dynamically handle method calls that aren't explicitly defined.

- When defining a custom `method_missing` method, it is good practice to also define a `respond_to_missing?` method
  that allows `respond_to` to accurately report whether the object can handle a method call that is not explicitly
  defined.

- Make sure to use super to delegate to the parent object's behaviour where necessary.

### Constants

- You can access a top-level constant with `::`. This can resolve name conflicts with nested constants. A nested
  constant takes precedence over (shadows) an inherited constant of same name (within same scope).

- Ruby searches for constant definitions in this order:

  - The enclosing scope
  - Any outer scopes (up to but not including the top level)
  - Included modules
  - Superclass(es)
  - Top level
  - Object
  - Kernel

- Consider this example:

```
class Alien
  LEGS = 3

  puts "Alien has #{LEGS} legs\n"
end

class Human
  LEGS = 2

  puts "Human has #{LEGS} legs\n"

  class Zombie < Alien
    puts "Zombie has #{LEGS} legs\n"
  end
end

class Child < Human::Zombie
  puts "Child has #{LEGS} legs\n"
end
```

- In this example, the Child class will output: "Child has 3 legs". Although lexical and encapsulated scopes have
  precedence, and the Human class defines a `LEGS` constant with the value of 2, Child is defined at the top level
  and does not define a `LEGS` constant. Therefore, nothing is found in the immediate lexical scope and there is no
  encapsulating scope, so Ruby starts looking up the inheritance hierarchy. Once it does this, it cannot switch back
  until the full hierarchy has been searched, therefore it searches Zombie which does not define `LEGS` and as Zombie
  inherits from Alien, it searches there and finds `LEGS` with a value of 3.

- Class definitions are executed immediately in a Ruby program, meaning any top level code inside a class definition is
  run as soon as the class definition is encountered by the Ruby interpreter.

- The order of Class definition matters due to the way Ruby handles constant resolution and loading:

  1. Constant Resolution
     Ruby uses a constant resolution process to determine the value of constants and class references. When a class or
     module is referenced, Ruby looks up the constant in the current scope and its enclosing scopes. If you attempt to
     reference a class or module before it is defined, Ruby will raise a NameError because it cannot find the constant.

  2. Loading Order
     Files need to be loaded in the correct order. Frameworks like Rails have an autoloading mechanism (Zeitwerk in 6+)
     that lazy loads classes and modules, so the corresponding file (determined by naming convention) is loaded only
     when the class is referenced. In production, Rails uses eager loading to load all classes at startup. This ensures
     that all dependencies are resolved before the application starts handling requests.

  3. Code dependencies
     When defining classes and modules that depend on each other, they must be defined and hence loaded in the correct
     order to avoid a NameError (uninitialized constant XYZ)

### Randomness

- When expecting a random number(s) not to match e.g. in a unit test, it's best to also check object id in the rare case
  that a matching number(s) is selected more than once.

### Exceptions

- `fail` keyword as an alias for `raise`.

- The first element when calling `ancestors` on a class is the class itself, so the first ancestor starts at index: 1.

- Ruby Exception Hierarchy:

```
Exception
├── NoMemoryError
├── ScriptError
│   ├── LoadError
│   ├── NotImplementedError
│   └── SyntaxError
├── SignalException
│   └── Interrupt
├── StandardError  (default for `rescue` if no class is specified)
│   ├── ArgumentError
│   ├── EncodingError
│   ├── FiberError
│   ├── IOError
│   │   └── EOFError
│   ├── IndexError
│   │   ├── KeyError
│   │   └── StopIteration
│   ├── LocalJumpError
│   ├── NameError
│   │   └── NoMethodError
│   ├── RangeError
│   │   └── FloatDomainError
│   ├── RegexpError
│   ├── RuntimeError
│   ├── SecurityError
│   ├── SystemCallError
│   ├── SystemStackError
│   ├── ThreadError
│   ├── TypeError
│   └── ZeroDivisionError
├── SystemExit
├── fatal   (Internal, not accessible from Ruby code)
└── NoMemoryError
```

- `Exception` is the root of all exceptions.

- `StandardError`: This is the default exception that is rescued when you use rescue without specifying an exception
  class. Most common exceptions inherit from StandardError.

- `ScriptError`: This is the parent of exceptions related to program execution, such as `SyntaxError`, `LoadError`, and
  `NotImplementedError`.

- `SignalException`: Raised when a signal is received (e.g., `Interrupt` is raised when the user sends an interrupt signal
  like Ctrl+C).

- `SystemExit`: Raised when exit is called, allowing the program to terminate gracefully.

- `NoMemoryError`: Raised when memory allocation fails (rarely encountered in typical applications).

- Common Exceptions:

- `RuntimeError`: A generic error class used when no specific subclass is appropriate.

- `NoMethodError`: Raised when a method is called on an object that does not define it.

- `NameError`: Raised when a variable or constant is referenced that hasn't been defined.

- `ArgumentError`: Raised when the arguments provided to a method are incorrect.

- `TypeError`: Raised when an object is of the wrong type for an operation.

- `IOError`: Raised when an IO operation fails (e.g., when trying to read a closed file).

- `EOFError`: Raised when reaching the end of a file unexpectedly.

- `ZeroDivisionError`: Raised when attempting to divide a number by zero.

- `KeyError`: Raised when attempting to retrieve a non-existent key from a hash.

- Ruby's default behavior for an exception object is to return its message when you try to access the object in a
  string-like context. So assigning the error to a variable or printing it will implicitly call message on the error
  object.

- `NoMethodError` is raised if trying to use `+=` operator on a variable where you have defined a getter/setter because
  it is shorthand for `var = var + 1` so as var has not been previously defined and assigned a value within the local
  scope, Ruby implicitly creates a local var variable set to `nil`, which does not respond to `+`.

### Hashes

- When a hash is initialised with an array as the default object, then that default object is not assigned to a key if you attempt to
  access the hash with a non-existent key. It is simply returned whenever you do so. As, in the example, if you are
  doing e.g. `hash[:one] << 1, hash[:two] << 2, hash[:three] << 3` then each time the same default array object is
  returned and you are adding the value to the array, so you end up with `[1,2,3]`.

- `#fetch` will raise a KeyError when you attempt to retrieve a value from the hash with a key that doesn't exist. This
  can prevent subtle bugs and silent failures. #fetch allows you to provide a 2nd argument that serves as a default
  value should a key not exist. By providing a block, you can also return a dynamically created default value.

### Regexp

- `//` -> Match with [/string/] returns string or substring (1st instance). No match returns `nil`.
- `?` -> [/string?/] (optional) returns first instance of any char. No match returns `nil`.
- `+` -> [/string+/] (one or more) returns all instances of preceding char. e.g. `"abbcccddddeeeee"[/fb+c+/]` returns `nil`
  because no match for "fb"
- `-` -> [/string*/] (zero or more). e.g. `"abbcccddddeeeee"[/e*/]` returns "" because, starting at the 1st char, no
  occurrences of "e" are found, hence
  condition is met.

- Summary of repetition operators (greedy):

  - `*` (zero or more)
  - `-` (one or more)
  - `?` (zero or one)
  - `{m,n}` -> (between m and n times)

- To make repetition operators non-greedy, append a `?` after e.g. `\*?`
- Interesting example of matching: `animals.select { |a| a[/[cbr]at/] }` a being the element in the array of strings
  e.g `"cat" -> "cat"[/[cbr]at/]`

- Character classes in regex are a way to define a set of characters that you want to match at a particular position
  in the input string. By using character classes, you can match any one character from a specific set of characters.

- `\A` Forces a match from the start of the string
- Caret `^` can either denote anchor at the start of a line, or at the beginning within a character class, it negates
  the character class

- When matching a string with parentheses, to return the first group, you use index of 1. This is because index 0
  returns the entire match.

Example:

```
string = "Gray, James"
pattern = /(\w+), (\w+)/

# Entire match
puts string[pattern, 0] # => "Gray, James"

# First capture group
puts string[pattern, 1] # => "Gray"

# Second capture group
puts string[pattern, 2] # => "James"
```

- When a regular expression with capture groups is used, Ruby stores the results of those groups in special variables
  like `$1`, `$2`, etc., corresponding to the respective capture groups.

- Greedy operators will match the longest possible substring that satisfies the pattern.

- Lazy operators will match the shortest possible substring that satisfies the pattern.

- The character class `([...])` e.g. `"Jim Gray"[grays, 1]` matches a single character from a set of characters.

- Alternation `(x|y|z)` matches any one of several complete patterns or alternatives.

Example:

```
regex = /[ab]c/
# This matches 'ac' or 'bc' (but only one of 'a' or 'b' can be chosen)

puts "ac".match?(regex)  # true
puts "bc".match?(regex)  # true
puts "abc".match?(regex) # false (only 'ac' or 'bc' can match)

regex = /a|bc/

# This matches either 'a' or 'bc' as alternatives

puts "ac".match?(regex) # true (matches 'a')
puts "bc".match?(regex) # true (matches 'bc')
puts "abc".match?(regex) # true (matches 'a' first)
```

- Another RegExp example:

```
"one two-three".sub(/(t\w*)/) { $1[0, 1] }` -> "one t-three".

# (t\w*) -> match `t` followed by 0 or more word characters.
# Result ("two") capture in group by parentheses and passed to the block.
# "two" held by $1 variable, the first character of which is extracted with a string slice ([0, 1]).
# Finally, "two" is replaced by "t".
```

### Strings

- Flexible quoting with custom delimiters can handle single and double quotes. e.g. `%('")`, `%!'"!`, `%{'"}`.

- Single quoted strings interpret backslashes literally, unless to escape another single quote.

- Flexible quotes can handle multiple lines, they DO consider the new line before the last delimiter.

- Here documents can handle multiple lines, they DON'T consider the new line before the end of block.

Example:

```
# 53 characters long
long_string = <<EOS
  It was the best of times,
  It was the worst of times.
EOS

54 characters long
long_string = %{
  It was the best of times,
  It was the worst of times.
}
```

- `<<` modifies string object in place

- Assigning a variable to an object, then another variable to the same object results in both variables holding a
  reference to the same object. Modifying the object will alter the value of both.

- `+=` creates a new object for concatenating two string values.

- Double quotes interpret newline characters, single quotes do not.

- Only objects truly intended to be used as strings respond to `to_str`, whereas every object responds to `to_s`.

- All objects support `to_s` and `inspect`.

- Calling inspect on a string returns the string in double quotes with the inner double quotes escaped.

- `nil.to_s` returns `""` but `nil.inspect` returns `"nil"`

### Symbols

- Symbols are unique objects i.e. you can have two `"str"` objects but not two `:str` objects.

Example:

```
a = :str
b = :str

# a.object_id => 700828
# b.object_id => 700828

c = "str"
d = "str"

# c.object_id => 700600
# d.object_id => 786643
```

- In older versions of Ruby, symbols are never garbage collected. Once a symbol is created, it stays in memory for the
  lifetime of the program.

- From Ruby 2.2, the Ruby garbage collector (GC) can reclaim unused symbols, specifically those created dynamically
  using methods like `String#to_sym` or `:"#{dynamic_string}"`. This change was introduced to mitigate the risk of
  memory bloat from excessive symbol creation.

- When directly comparing against a symbol, Ruby will create a new symbol if it doesn't already exist.

- For this reason, it is better to convert symbols to strings before performing comparisons, especially if the
  comparisons are run more than once because on subsequent runs the comparison will erroneously match (if they failed
  the first time) because a copy of the symbol we were comparing to has been created during the first run and now exists
  in the symbol table (an internal data structure maintained by the Ruby interpreter).

- Comparing two strings `O(n)` is less efficient than comparing two symbols `O(1)` because you need to compare the
  contents of the string char by char, whereas with symbols, you're just comparing two integer memory addresses.

- In the example above, you also incur the overhead of creating each symbol to a string before the assertion. However,
  due to strings not being unique and getting garbage collected, it is more memory safe to use strings.

- Avoid memory bloat caused by creating dynamic symbols in a loop or from user input!

- This is why Rails creates string from parameter keys, to avoid issues from too many symbols being dynamically created.

- Creating too many symbols can lead to memory bloat and as the symbol table grows, performance can be degraded as Ruby
  internals are affected (symbol lookups etc.).

- Dynamically creating symbols based on user input or other external sources can pose security risks. DoS attack
  vulnerability - malicious input could potentially lead to the creation of a large number of symbols, affecting
  performance or crashing the server due to memory exhaustion.

- MRI stands for Matz's Ruby Interpreter (also known as CRuby). It is the reference implementation of Ruby, written in
  C. Other implementations include: JRuby, Rubinius, TruffleRuby and mruby. They either focus more on performance or
  serve a lightweight implementation that can be embedded in other applications
  Method and Constant names become automatically available as symbols.

### Methods

- `divmod` -> returns quotient and remainder of the division e.g. `q, r = 4.divmod(3) -> [1, 1] -> q == 1, r == 1`.

- `all?` -> condition satisfied within all iterations of the block.

- `any?` -> at least one condition satisfied within all iteration of the block.

- `max_by` -> returns the object that gives the maximum value from the given block.

- `min_by` -> returns the object that gives the minimum value from the given block.

### Misc.

- Working with `StringIO` in `irb` is a bit of a pain because it displays the result of every expression after it's
  evaluated, which messes up the output. In my case, I wasn't bothered about testing the exact output of the message,
  but if you wanted to you could do: `output.rewind` then `output.read` to get the actual string content of the
  `StringIO` object rather than the `StringIO` string object itself.

### And...Triangles...

- There are six key rules a triangle must satisfy:

  1. Angle Sum Property - The sum of the interior angles of a triangle is always 180 degrees.

  2. Non-degeneracy - No side of the triangle can have a length of zero.

  3. Positive Area - The area of a triangle must be greater than zero, which implies that the triangle cannot be flat.

  4. Distinct points - A triangle's vertices must be distinct points.

  5. Internal and External Angle Rules - An exterior angle of a triangle is equal to the sum of the two opposite
     interior angles.

  6. Triangle inequality theorem - The sum of any two numbers is always greater than the third.
