require File.expand_path(File.dirname(__FILE__) + "/neo")
require "debug"

# Greed is a dice game where you roll up to five dice to accumulate
# points.  The following "score" function will be used to calculate the
# score of a single roll of the dice.
#
# A greed roll is scored as follows:
#
# * A set of three ones is 1000 points
#
# * A set of three numbers (other than ones) is worth 100 times the
#   number. (e.g. three fives is 500 points).
#
# * A one (that is not part of a set of three) is worth 100 points.
#
# * A five (that is not part of a set of three) is worth 50 points.
#
# * Everything else is worth 0 points.
#
#
# Examples:
#
# score([1,1,1,5,1]) => 1150 points
# score([2,3,4,6,2]) => 0 points
# score([3,4,5,3,3]) => 350 points
# score([1,5,1,2,4]) => 250 points
#
# More scoring examples are given in the tests below:
#
# Your goal is to write the score method.

# TIL:
# - divmod method -> returns quotient and remainder of the division e.g. q, r = 4.divmod(3) -> [1, 1] -> q == 1, r == 1

# I swapped the order of the method and the class to leverage a constant and custom error class for my
# solution.

class AboutScoringProject < Neo::Koan
  NUMBERS = [1, 2, 3, 4, 5, 6]

  class InvalidDiceError < ArgumentError
  end

  def test_score_of_an_empty_list_is_zero
    assert_equal 0, score([])
  end

  def test_score_of_a_single_roll_of_5_is_50
    assert_equal 50, score([5])
  end

  def test_score_of_a_single_roll_of_1_is_100
    assert_equal 100, score([1])
  end

  def test_score_of_multiple_1s_and_5s_is_the_sum_of_individual_scores
    assert_equal 300, score([1, 5, 5, 1])
  end

  def test_score_of_single_2s_3s_4s_and_6s_are_zero
    assert_equal 0, score([2, 3, 4, 6])
  end

  def test_score_of_a_triple_1_is_1000
    assert_equal 1000, score([1, 1, 1])
  end

  def test_score_of_other_triples_is_100x
    assert_equal 200, score([2, 2, 2])
    assert_equal 300, score([3, 3, 3])
    assert_equal 400, score([4, 4, 4])
    assert_equal 500, score([5, 5, 5])
    assert_equal 600, score([6, 6, 6])
  end

  def test_score_of_mixed_is_sum
    assert_equal 250, score([2, 5, 2, 2, 3])
    assert_equal 550, score([5, 5, 5, 5])
    assert_equal 1100, score([1, 1, 1, 1])
    assert_equal 1200, score([1, 1, 1, 1, 1])
    assert_equal 1150, score([1, 1, 1, 5, 1])
  end
end

# score implementation for about_scoring_project
# def score(dice)
#   raise ArgumentError.new("Must be an array!") unless dice.is_a?(Array)
#   raise ArgumentError.new("Maximum 5 dice!") if dice.size > 5

#   num_count = Hash.new(0)
#   points = 0

#   for num in dice
#     raise InvalidDiceError.new("That's a dodgy dice!") unless AboutScoringProject::NUMBERS.include?(num)
#     num_count[num] += 1
#   end

#   num_count.each do |num, count|
#     next unless count > 0

#     if count >= 3
#       if num == 1
#         points += 1000
#       else
#         points += (num * 100)
#       end

#       count -= 3
#     end

#     next unless count > 0

#     points += (count * 100) if num == 1
#     points += (count * 50) if num == 5
#   end

#   points
# end

# ChatGPT Code Review:
# - raise error immediately if more than 5 dice provided
# - For efficiency when handling large inputs, use array e.g.
#   Initialize an array to count occurrences of each dice value -> counts = [0] * 7. Index 0 goes unused, 1-6 represents
#   dice numbers.
# Add counts same way then:
#
#   (1..6).each do |num|
#     if counts[num] >= 3
#       points += (num == 1) ? 1000 : num * 100
#       counts[num] -= 3
#     end
#   end
#
#   points += counts[1] * 100
#   points += counts[5] * 50

# modified score implementation for Greed game
def score(dice)
  raise ArgumentError.new("Must be an array!") unless dice.is_a?(Array)
  raise ArgumentError.new("Maximum 5 dice!") if dice.size > 5

  num_count = Hash.new(0)
  points = 0

  dice.each do |num|
    raise InvalidDiceError.new("That's a dodgy dice!") unless AboutScoringProject::NUMBERS.include?(num)
    num_count[num] += 1
  end

  num_count.each do |num, count|
    next unless count > 0

    if count >= 3
      points += if num == 1
        1000
      else
        (num * 100)
      end

      count -= 3
    end

    if num == 1
      points += (count * 100)
      count = 0
    end

    if num == 5
      points += (count * 50)
      count = 0
    end

    num_count[num] = count
  end

  [points, num_count]
end
