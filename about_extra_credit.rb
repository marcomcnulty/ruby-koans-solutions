# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

require_relative "about_dice_project"
require_relative "about_scoring_project"
require "debug"
require "stringio"

# TIL:
# - Ruby's default behavior for an exception object is to return its message when you try to access the object in a
#   string-like context. So assigning the error to a variable or printing it will implicitly call message on the error
#   object.
#
# - NoMethodError is raised if trying to use += operator on a variable where you have defined a getter/setter because
#   it is shorthand for var = var + 1 so as var has not been previously defined and assigned a value within the local
#   scope, Ruby implicitly creates a local var variable set to nil, which does not respond to `+`.
#
# - When iterating over a collection, the block variable is only a copy of the item in the original data structure.
#   Therefore, if you want to update the item within the block and have the change persist, you need to explicitly
#   access the original object and modify the item, or use methods that modify in place like map!.
#
# - Be careful to never pass a keyword argument to a method that has only set up an optional argument. Doing so will
#   cause Ruby to interpret this as you passing a single hash argument rather than a keyword argument, which won't raise
#   an error but could cause unexpected behaviour.
#
# - Working with StringIO in irb is a bit of a pain because it displays the result of every expression after it's
#   evaluated, which messes up the output.
# - In my case, I wasn't bothered about testing the exact output of the message, but if you wanted to you could do:
#   ouput.rewind then ouput.read to get the actual string content of the StringIO object rather than the StringIO string
#   object itself.
#
# - Lambdas are awesome!
#
# - When nesting classes, it often helps to pass a reference of the enclosing class to the nested class, so that the
#   nested class is aware of its context.
#
# - Variables defined in a for loop block are accessible outside of the block because for loops do not create their own
#   scope.
#
# - Methods:
#   - all? -> condition satisfied within all iterations of the block
#   - any? -> at least one condition satisfied within all iteration of the block
#   - max_by -> returns the object that gives the maximum value from the given block
#   - min_by -> returns the object that gives the minimum value from the given block

class Game
  attr_reader :players, :rounds, :final_round

  class PlayerCountError < ArgumentError
  end

  ROUND_LIMIT = 50
  FINAL_ROUND_SCORE_THRESHOLD = 3000

  def initialize(player_count)
    raise PlayerCountError.new("You need at least 2 players to play!") if player_count < 2

    @players = []
    @rounds = 0
    @final_round = false
    create_players(player_count)
  end

  def play_game
    puts "******** Starting Greed! ********"

    until final_round
      start_new_round
    end
  end

  private

  def create_players(player_count)
    player_count.times { |n| players << Player.new("Player #{n + 1}", self) }
  end

  def start_new_round
    if rounds == ROUND_LIMIT
      puts "Round limit reached! The game is a draw!"
      @final_round = true
      return
    end

    @final_round = final_round?

    if final_round
      puts "*** Final round! ***"
    else
      @rounds += 1
      puts "*** Round #{rounds}! ***"
    end

    start_turns
  end

  def start_turns
    players.each do |p|
      p.turns = 0
      p.take_turn
    end

    announce_winner_if_final_round
  end

  def announce_winner_if_final_round
    if final_round
      winner = leading_player
      msg = "Game over! #{winner.name} won with #{winner.total_score} points!"
      puts msg
    end
  end

  def final_round?
    players.any? { |player| player.total_score >= FINAL_ROUND_SCORE_THRESHOLD }
  end

  def leading_player
    players.max_by { |p| p.total_score }
  end

  class Player
    attr_accessor :turns
    attr_reader :name, :turn_score, :total_score, :turn_state, :game

    def initialize(name, game)
      @name = name
      @turns = 0
      @total_score = 0
      @turn_score = 0
      @game = game
      @turn_state = :waiting
    end

    def take_turn
      start_turn
      dice_num = 5

      while turn_state == :playing
        @turns += 1

        values = roll_dice(dice_num)
        roll_score, results = score(values)

        dice_num = handle_score(roll_score, results)
        end_turn if dice_num == 0 || !roll_again?
      end
    end

    private

    def start_turn
      @turn_state = :playing
      puts "#{name} has #{total_score} points!"
    end

    def end_turn
      @turn_state = :finished
      @total_score += turn_score
      puts "#{name} ends their turn with #{total_score} points!"
    end

    def roll_dice(dice_num)
      dice = DiceSet.new

      puts "#{name} rolls!"
      values = dice.roll(dice_num)
      puts "#{name} gets #{values}!"

      values
    end

    def handle_score(roll_score, results)
      if roll_score == 0
        @turn_score = 0
        puts "Oops! #{name} gets 0 and loses all points this round!"
        return 0
      end

      if roll_score < 300 && total_score == 0
        @turn_score = 0
        puts "Sorry, #{name}! You didn't get enough points to continue..."
        return 0
      end

      @turn_score += roll_score
      puts "Nice! #{name} gets #{roll_score} points!"

      remaining_dice = remove_scoring_dice(results)

      unless remaining_dice > 0
        puts "#{name} has no more dice!"
        return 0
      end

      remaining_dice
    end

    def remove_scoring_dice(results)
      return 5 if results.values.sum == 0

      remaining = results.count { |_, count| count > 0 }
      puts "#{name} still has #{remaining} dice to play!"
      remaining
    end

    def roll_again?
      decision = game.final_round ? true : [true, false].sample

      if decision
        puts "#{name} decides to continue!"
      else
        puts "#{name} decides to cash out!"
      end

      decision
    end
  end
end

class GreedGameTests
  attr_accessor :test_results

  def initialize
    @test_results = []
  end

  def run_tests
    test_methods = private_methods.grep(/^test_/)
    test_methods.each do |test|
      send(test)
    end
    print_results
  end

  private

  # _____ TESTS _____

  def test_cannot_play_with_less_than_2_players
    result = nil

    begin
      Game.new(1)
    rescue Game::PlayerCountError => e
      result = e
    end

    _test_match(expectation: Game::PlayerCountError, actual: result.class)
  end

  def test_game_instantiates_correct_number_of_players
    g = Game.new(2)
    _test_match(expectation: 2, actual: g.players.count)
  end

  def test_each_player_takes_at_least_one_turn_per_round
    g = Game.new(3)
    g.play_game

    players = g.players
    condition = ->(turns) { turns > 0 }

    result = _test_obj_attr_matches_condition(players, :turns, condition)

    @test_results << (result ? true : [false, "A player has missed their turn!"])
  end

  def test_player_rolls_5_dice_following_full_score
    g = Game.new(2)
    p = Game::Player.new("Player 1", g)
    _, results = score([1, 1, 1, 1, 1])
    result = p.send(:remove_scoring_dice, results)

    _test_match(expectation: 5, actual: result)
  end

  def test_player_with_points_loses_points_following_no_score
    g = Game.new(2)
    p = Game::Player.new("Player 1", g)
    p.turn_score = 600
    p.send(:handle_score, 0, {3 => 5})

    _test_match(expectation: 0, actual: p.turn_score)
  end

  def test_player_with_0_points_does_not_accumulate_points_until_first_score_over_300
    g = Game.new(2)

    p = Game::Player.new("Player 1", g)
    p.total_score = 0
    p.send(:handle_score, 200, {3 => 3, 1 => 2})

    _test_match(expectation: 0, actual: p.total_score)
  end

  def test_game_enters_final_round_when_player_reaches_at_least_3000_points
    g = Game.new(2)
    g.players.first.total_score = 3000

    _test_match(expectation: true, actual: g.send(:final_round?))
  end

  def test_winner_is_determined_when_game_enters_final_round
    g = Game.new(2)
    g.players.first.total_score = 3000
    g.final_round = true

    output = StringIO.new
    $stdout = output
    g.send(:start_turns)
    $stdout = STDOUT

    expected = "Game over! Player 1 won"

    _test_match_includes?(expectation: expected, actual: output.string)
  end

  # _____ TEST HELPERS _____

  def _test_match(expectation:, actual:)
    test_results << ((expectation == actual) ? true : [false, "Expected: #{expectation}, got: #{actual}"])
  end

  def _test_match_includes?(expectation:, actual:)
    test_results << (actual.include?(expectation) ? true : [false, "#{actual} does not include #{expectation}"])
  end

  def _test_obj_attr_matches_condition(objs, attribute, condition)
    objs.all? do |obj|
      value = obj.send(attribute)
      condition.call(value)
    end
  end

  def print_results
    puts "Tests:"

    test_results.each.with_index(1) do |result, i|
      str = "#{i}. "

      if result.is_a?(Array)
        str += "Fail - "
        str += result.last
      else
        str += "Pass"
      end

      puts str
    end
  end
end

# GreedGameTests.new.run_tests
g = Game.new(2)
g.play_game
