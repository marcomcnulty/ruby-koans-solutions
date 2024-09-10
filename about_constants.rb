require File.expand_path(File.dirname(__FILE__) + "/neo")

# TIL:
# - Access a top-level constant with `::`. Can resolve name conflicts with nested constants.
# - Nested constant takes precedence over (shadows) inherited constant of same name (within scope).
#
# - Ruby searches for constant definitions in this order:
#   1. The enclosing scope
#   2. Any outer scopes (up to but not including the top level)
#   3. Included modules
#   4. Superclass(es)
#   5. Top level
#   6. Object
#   7. Kernel

# Consider this example:
#
#   class Alien
#     LEGS = 3
#
#     puts "Alien has #{LEGS} legs\n"
#   end
#
#   class Human
#     LEGS = 2
#
#     puts "Human has #{LEGS} legs\n"
#
#     class Zombie < Alien
#       puts "Zombie has #{LEGS} legs\n"
#     end
#   end

#   class Child < Human::Zombie
#     puts "Child has #{LEGS} legs\n"
#   end
#
# In this example, the Child class will output: "Child has 3 legs". Although lexical and encapsulated scopes have
# precedence, and the Human class defines a LEGS constant with the value of 2, Child is defined at the top level
# and does not define a LEGS constant. Therefore, nothing is found in the immediate lexical scope and there is no
# encapsulating scope, so Ruby starts looking up the inheritance hierarchy. Once it does this, it cannot switch back
# until the full hierarchy has been searched, therefore it searches Zombie which does not define LEGS and as Zombie
# inherits from Alien, it searches there and finds LEGS with a value of 3.
#
# - Class definitions are executed immediately in a Ruby program, meaning any top level code inside a class definition is
#   run as soon as the class definition is encountered by the Ruby interpreter.
#
# - The order of Class definition matters due to the way Ruby handles constant resolution and loading.
#   1. Constant Resolution
#      Ruby uses a constant resolution process to determine the value of constants and class references. When a class or
#      module is referenced, Ruby looks up the constant in the current scope and its enclosing scopes. If you attempt to
#      reference a class or module before it is defined, Ruby will raise a NameError because it cannot find the constant.
#
#   2. Loading Order
#      Files need to be loaded in the correct order. Frameworks like Rails have an autoloading mechanism (Zeitwerk in 6+)
#      that lazy loads classes and modules, so the corresponding file (determined by naming convention) is loaded only
#      when the class is referenced. In production, Rails uses eager loading to load all classes at startup. This ensures
#      that all dependencies are resolved before the application starts handling requests.

#   3. Code dependencies
#      When defining classes and modules that depend on each other, they must be defined and hence loaded in the correct
#      order to avoid a NameError (uninitialized constant XYZ)

C = "top level"

class AboutConstants < Neo::Koan
  C = "nested"

  def test_nested_constants_may_also_be_referenced_with_relative_paths
    assert_equal "nested", C
  end

  def test_top_level_constants_are_referenced_by_double_colons
    assert_equal "top level", ::C
  end

  def test_nested_constants_are_referenced_by_their_complete_path
    assert_equal "nested", AboutConstants::C
    assert_equal "nested", ::AboutConstants::C
  end

  # ------------------------------------------------------------------

  class Animal
    LEGS = 4
    def legs_in_animal
      LEGS
    end

    class NestedAnimal
      def legs_in_nested_animal
        LEGS
      end
    end
  end

  def test_nested_classes_inherit_constants_from_enclosing_classes
    assert_equal 4, Animal::NestedAnimal.new.legs_in_nested_animal
  end

  # ------------------------------------------------------------------

  class Reptile < Animal
    def legs_in_reptile
      LEGS
    end
  end

  def test_subclasses_inherit_constants_from_parent_classes
    assert_equal 4, Reptile.new.legs_in_reptile
  end

  # ------------------------------------------------------------------

  class MyAnimals
    LEGS = 2

    class Bird < Animal
      def legs_in_bird
        LEGS
      end
    end
  end

  def test_who_wins_with_both_nested_and_inherited_constants
    assert_equal 2, MyAnimals::Bird.new.legs_in_bird
  end

  # QUESTION: Which has precedence: The constant in the lexical scope,
  # or the constant from the inheritance hierarchy?

  # A: The constant in the lexical scope.

  # ------------------------------------------------------------------

  class MyAnimals::Oyster < Animal
    def legs_in_oyster
      LEGS
    end
  end

  def test_who_wins_with_explicit_scoping_on_class_definition
    assert_equal 4, MyAnimals::Oyster.new.legs_in_oyster
  end

  # QUESTION: Now which has precedence: The constant in the lexical
  # scope, or the constant from the inheritance hierarchy?  Why is it
  # different than the previous answer?

  # A: In this example, MyAnimals::Oyster is defined as a top-level nested class under Human. It is not within the
  # lexical scope of the Human class body. As such, LEGS is not found in the current scope, nor in any enclosing scope
  # so Ruby then looks up the inheritance hierarchy of the current class or module.
end
