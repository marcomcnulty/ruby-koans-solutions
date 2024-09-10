require File.expand_path(File.dirname(__FILE__) + "/neo")

# TIL:
# - Singleton classes:
# Special, hidden class that is created for a specific object to hold methods that are only applicable to that single
# object. This allows you to define methods on a per-object basis, rather than on the class as a whole. Most commonly
# used when you want to define methods that only apply to a single instance of a class, rather than to all instances of
# that class. For example, you might want a specific object to have a custom behavior that other instances of the same
# class don’t share.
#
# You can access an object’s singleton class using the class << object syntax. Inside this block, any method definitions
# are added to the singleton class of the object. Example using the remove_method method:

# # Define a base class
# class Animal
#   def speak
#     "I'm an animal"
#   end
# end

# # Define a subclass
# class Dog < Animal
#   def speak
#     "Woof!"
#   end
# end

# # Create an instance of the Dog class
# fido = Dog.new

# # Define a singleton method on the instance `fido`
# def fido.speak
#   "Bark!"
# end

# # Define another singleton method on `fido`
# def fido.run
#   "Running fast!"
# end

# # Let's test the inheritance and method look-up
# puts fido.speak       # => "Bark!" (singleton method on `fido`)
# puts fido.run         # => "Running fast!" (singleton method on `fido`)

# # Create another instance of Dog
# rover = Dog.new

# # Check if `rover` has access to the singleton methods defined on `fido`
# puts rover.speak      # => "Woof!" (regular method from the `Dog` class)
# puts rover.respond_to?(:run) # => false (singleton method `run` is not available to `rover`)

# # Remove the singleton method `speak` from `fido`
# class << fido
#   remove_method :speak
# end

# # Now `fido` will use the method from the `Dog` class
# puts fido.speak       # => "Woof!" (method from the `Dog` class after singleton method is removed)

# # Remove the method `speak` from the `Dog` class and `fido` will look up to `Animal`
# class Dog
#   remove_method :speak
# end

# puts fido.speak

class AboutClassMethods < Neo::Koan
  class Dog
  end

  def test_objects_are_objects
    fido = Dog.new
    assert_equal true, fido.is_a?(Object)
  end

  def test_classes_are_classes
    assert_equal true, Dog.is_a?(Class)
  end

  def test_classes_are_objects_too
    assert_equal true, Dog.is_a?(Object)
  end

  def test_objects_have_methods
    fido = Dog.new
    assert fido.methods.size > 0
  end

  def test_classes_have_methods
    assert Dog.methods.size > 0
  end

  def test_you_can_define_methods_on_individual_objects
    fido = Dog.new
    def fido.wag
      :fidos_wag
    end
    assert_equal :fidos_wag, fido.wag
  end

  def test_other_objects_are_not_affected_by_these_singleton_methods
    fido = Dog.new
    rover = Dog.new
    def fido.wag
      :fidos_wag
    end

    assert_raise(NoMethodError) do
      rover.wag
    end
  end

  # ------------------------------------------------------------------

  class Dog2
    def wag
      :instance_level_wag
    end
  end

  def Dog2.wag
    :class_level_wag
  end

  def test_since_classes_are_objects_you_can_define_singleton_methods_on_them_too
    assert_equal :class_level_wag, Dog2.wag
  end

  def test_class_methods_are_independent_of_instance_methods
    fido = Dog2.new
    assert_equal :instance_level_wag, fido.wag
    assert_equal :class_level_wag, Dog2.wag
  end

  # ------------------------------------------------------------------

  class Dog
    attr_accessor :name
  end

  def Dog.name
    @name
  end

  def test_classes_and_instances_do_not_share_instance_variables
    fido = Dog.new
    fido.name = "Fido"
    assert_equal "Fido", fido.name
    assert_equal nil, Dog.name
  end

  # ------------------------------------------------------------------

  class Dog
    def self.a_class_method
      :dogs_class_method
    end
  end

  def test_you_can_define_class_methods_inside_the_class
    assert_equal :dogs_class_method, Dog.a_class_method
  end

  # ------------------------------------------------------------------

  LastExpressionInClassStatement = class Dog
                                     21
                                   end

  def test_class_statements_return_the_value_of_their_last_expression
    assert_equal 21, LastExpressionInClassStatement
  end

  # ------------------------------------------------------------------

  SelfInsideOfClassStatement = class Dog
                                 self
                               end

  def test_self_while_inside_class_is_class_object_not_instance
    assert_equal true, Dog == SelfInsideOfClassStatement
  end

  # ------------------------------------------------------------------

  class Dog
    def self.class_method2
      :another_way_to_write_class_methods
    end
  end

  def test_you_can_use_self_instead_of_an_explicit_reference_to_dog
    assert_equal :another_way_to_write_class_methods, Dog.class_method2
  end

  # ------------------------------------------------------------------

  class Dog
    class << self
      def another_class_method
        :still_another_way
      end
    end
  end

  def test_heres_still_another_way_to_write_class_methods
    assert_equal :still_another_way, Dog.another_class_method
  end

  # THINK ABOUT IT:
  #
  # The two major ways to write class methods are:
  #   class Demo
  #     def self.method
  #     end

  #     class << self
  #       def class_methods
  #       end
  #     end
  #   end

  # Which do you prefer and why?
  # Are there times you might prefer one over the other?
  #
  # A: If a class had many class methods then I'd use the second example, as it would look cleaner and better organise
  # the code, otherwise, I'd just use the first example.

  # ------------------------------------------------------------------

  def test_heres_an_easy_way_to_call_class_methods_from_instance_methods
    fido = Dog.new
    assert_equal :still_another_way, fido.class.another_class_method
  end
end
