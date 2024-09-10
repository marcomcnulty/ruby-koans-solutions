# Triangle Project Code.

# Triangle analyzes the lengths of the sides of a triangle
# (represented by a, b and c) and returns the type of triangle.
#
# It returns:
#   :equilateral  if all sides are equal
#   :isosceles    if exactly 2 sides are equal
#   :scalene      if no sides are equal
#
# The tests for this method can be found in
#   about_triangle_project.rb
# and
#   about_triangle_project_2.rb

# TIL:
# - There are six key rules a triangle must satisfy:
#   1. Angle Sum Property - The sum of the interior angles of a triangle is always 180 degrees.
#   2. Non-degeneracy - No side of the triangle can have a length of zero.
#   3. Positive Area - The area of a triangle must be greater than zero, which implies that the triangle cannot be flat.
#   4. Distinct points - A triangle's vertices must be distinct points.
#   5. Internal and External Angle Rules - An exterior angle of a triangle is equal to the sum of the two opposite
#      interior angles.
#   6. Triangle inequality theorem - The sum of any two numbers is always greater than the third.

# def triangle(a, b, c)
#   raise TriangleError if [a, b, c].min <= 0

#   a, b, c = [a, b, c].sort
#   raise TriangleError unless a + b > c

#   return :equilateral if a == b && a == c
#   return :scalene if a != b && a != c && b != c

#   :isosceles
# end

def triangle(a, b, c)
  raise TriangleError, "Sides must be positive" if [a, b, c].min <= 0

  a, b, c = [a, b, c].sort
  raise TriangleError, "Invalid side lengths for a triangle" unless a + b > c

  return :equilateral if a == c
  return :isosceles if a == b || b == c

  :scalene
end

# ChatGPT Code Review:
# Should raise TriangleError with a message e.g.raise TriangleError.new("Sides must be positive") if [a, b, c].min <= 0
# Check for the triangle inequality violation e.g.
# raise TriangleError.new("Invalid side lengths for a triangle") unless a + b > c
# Simplify the checks:
# - Because we've already sorted the sides, if a == c then a must also equal b -> return :equilateral if a == c
# - Now that we've ruled out all sides being equal, we can check for exactly two sides being equal i.e. isosceles:
#   - return :isosceles if a == b || b == c
# - Given that we've ensured we have a valid triangle that isn't equilateral or isosceles, we can safely assume it's
#   scalene.

# Error class used in part 2.  No need to change this code.
class TriangleError < StandardError
end
