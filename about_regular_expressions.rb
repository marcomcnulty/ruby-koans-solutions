require File.expand_path(File.dirname(__FILE__) + "/neo")

# TIL:
# - // -> Match with [/string/] returns string or substring (1st instance). No match returns nil.
# - ? -> [/string?/] (optional) returns first instance of any char. No match returns nil.
# - + -> [/string+/] (one or more) returns all instances of preceding char.
#   e.g. "abbcccddddeeeee"[/fb+c+/] returns nil because no match for "fb"
# - * -> [/string*/] (zero or more).
#   e.g. "abbcccddddeeeee"[/e*/] returns "" because, starting at the 1st char, no occurences of "e" are found, hence
#   condition is met.
#
# - Summary of repetition operators (greedy):
# * (zero or more)
# + (one or more)
# ? (zero or one)
# {m,n} -> (between m and n times)
#
# - To make repetition operators non-greedy, append a ? after e.g. *?
# - Interesting example of matching: animals.select { |a| a[/[cbr]at/] } a being the element in the array of strings
# e.g "cat" -> "cat"[/[cbr]at/]
#
# - Character classes in regex are a way to define a set of characters that you want to match at a particular position
#   in the input string. By using character classes, you can match any one character from a specific set of characters.
#
# - \A Forces a match from the start of the string
# - Caret ^ can either denote anchor at the start of a line, or at the beginning within a character class, it negates
#   the character class
#
# - When matching a string with parentheses, to return the first group, you use index of 1. This is because index 0
# returns the entire match.
#
# Example:
# string = "Gray, James"
# pattern = /(\w+), (\w+)/
# Entire match
# puts string[pattern, 0]  # => "Gray, James"

# First capture group
# puts string[pattern, 1]  # => "Gray"

# Second capture group
# puts string[pattern, 2]  # => "James"
# When a regular expression with capture groups is used, Ruby stores the results of those groups in special variables
# like $1, $2, etc., corresponding to the respective capture groups.

class AboutRegularExpressions < Neo::Koan
  def test_a_pattern_is_a_regular_expression
    assert_equal Regexp, /pattern/.class
  end

  def test_a_regexp_can_search_a_string_for_matching_content
    assert_equal "match", "some matching content"[/match/]
  end

  def test_a_failed_match_returns_nil
    assert_equal nil, "some matching content"[/missing/]
  end

  # ------------------------------------------------------------------

  def test_question_mark_means_optional
    assert_equal "ab", "abbcccddddeeeee"[/ab?/]
    assert_equal "a", "abbcccddddeeeee"[/az?/]
  end

  def test_plus_means_one_or_more
    assert_equal "bccc", "abbcccddddeeeee"[/bc+/]
  end

  def test_asterisk_means_zero_or_more
    assert_equal "abb", "abbcccddddeeeee"[/ab*/]
    assert_equal "a", "abbcccddddeeeee"[/az*/]
    assert_equal "", "abbcccddddeeeee"[/z*/]
  end
  # THINK ABOUT IT: When would * fail to match?
  #
  # A: The * quantifier will always match, even if that match is an empty string.

  # THINK ABOUT IT:
  # We say that the repetition operators above are "greedy."
  # Why?
  #
  # A: Greedy operators will match the longest possible substring that satisfies the pattern.
  # Lazy operators will match the shortest possible substring that satisfies the pattern.

  # ------------------------------------------------------------------

  def test_the_left_most_match_wins
    assert_equal "a", "abbccc az"[/az*/]
  end

  # ------------------------------------------------------------------

  def test_character_classes_give_options_for_a_character
    animals = ["cat", "bat", "rat", "zat"]
    assert_equal ["cat", "bat", "rat"], animals.select { |a| a[/[cbr]at/] }
  end

  def test_slash_d_is_a_shortcut_for_a_digit_character_class
    assert_equal "42", "the number is 42"[/[0123456789]+/]
    assert_equal "42", "the number is 42"[/\d+/]
  end

  def test_character_classes_can_include_ranges
    assert_equal "42", "the number is 42"[/[0-9]+/]
  end

  def test_slash_s_is_a_shortcut_for_a_whitespace_character_class
    assert_equal " \t\n", "space: \t\n"[/\s+/]
  end

  def test_slash_w_is_a_shortcut_for_a_word_character_class
    # NOTE:  This is more like how a programmer might define a word.
    assert_equal "variable_1", "variable_1 = 42"[/[a-zA-Z0-9_]+/]
    assert_equal "variable_1", "variable_1 = 42"[/\w+/]
  end

  def test_period_is_a_shortcut_for_any_non_newline_character
    assert_equal "abc", "abc\n123"[/a.+/]
  end

  def test_a_character_class_can_be_negated
    assert_equal "the number is ", "the number is 42"[/[^0-9]+/]
  end

  def test_shortcut_character_classes_are_negated_with_capitals
    assert_equal "the number is ", "the number is 42"[/\D+/]
    assert_equal "space:", "space: \t\n"[/\S+/]
    # ... a programmer would most likely do
    assert_equal " = ", "variable_1 = 42"[/[^a-zA-Z0-9_]+/]
    assert_equal " = ", "variable_1 = 42"[/\W+/]
  end

  # ------------------------------------------------------------------

  def test_slash_a_anchors_to_the_start_of_the_string
    assert_equal "start", "start end"[/\Astart/]
    assert_equal nil, "start end"[/\Aend/]
  end

  def test_slash_z_anchors_to_the_end_of_the_string
    assert_equal "end", "start end"[/end\z/]
    assert_equal nil, "start end"[/start\z/]
  end

  def test_caret_anchors_to_the_start_of_lines
    assert_equal "2", "num 42\n2 lines"[/^\d+/]
  end

  def test_dollar_sign_anchors_to_the_end_of_lines
    assert_equal "42", "2 lines\nnum 42"[/\d+$/]
  end

  def test_slash_b_anchors_to_a_word_boundary
    assert_equal "vines", "bovine vines"[/\bvine./]
  end

  # ------------------------------------------------------------------

  def test_parentheses_group_contents
    assert_equal "hahaha", "ahahaha"[/(ha)+/]
  end

  # ------------------------------------------------------------------

  def test_parentheses_also_capture_matched_content_by_number
    assert_equal "Gray", "Gray, James"[/(\w+), (\w+)/, 1]
    assert_equal "James", "Gray, James"[/(\w+), (\w+)/, 2]
  end

  def test_variables_can_also_be_used_to_access_captures
    assert_equal "Gray, James", "Name:  Gray, James"[/(\w+), (\w+)/]
    assert_equal "Gray", $1
    assert_equal "James", $2
  end

  # ------------------------------------------------------------------

  def test_a_vertical_pipe_means_or
    grays = /(James|Dana|Summer) Gray/
    assert_equal "James Gray", "James Gray"[grays]
    assert_equal "Summer", "Summer Gray"[grays, 1]
    assert_equal nil, "Jim Gray"[grays, 1]
  end

  # THINK ABOUT IT:
  #
  # Explain the difference between a character class ([...]) and alternation (|).

  # A: The character class matches a single character from a set of characters.
  #    Alternation matches any of several complete patterns

  # ------------------------------------------------------------------

  def test_scan_is_like_find_all
    assert_equal ["one", "two", "three"], "one two-three".scan(/\w+/)
  end

  def test_sub_is_like_find_and_replace
    assert_equal "one t-three", "one two-three".sub(/(t\w*)/) { $1[0, 1] }
  end

  # This is tricky at first glance but can be broken down easily enough:
  # - (t\w*) -> match `t` followed by 0 or more word characters, capture in group
  # - "two" is captured and passed to the block
  # - "two" held by $1 variable, the first character of which is extracted
  # - Finally, two is replaced by `t`

  def test_gsub_is_like_find_and_replace_all
    assert_equal "one t-t", "one two-three".gsub(/(t\w*)/) { $1[0, 1] }
  end
end
