# frozen_string_literal: true

require 'test/unit'
require_relative '../lib/file/file_loader'

class TestFileLoader < Test::Unit::TestCase
  def test_file_load
    files = %w[Rakefile exec_ls.rb lib test]
    assert_equal files, FileLoader.load_files(dot_match: false, reverse: false)
  end

  def test_file_load_with_dot_match_option
    files = %w[. .. .gitkeep Rakefile exec_ls.rb lib test]
    assert_equal files, FileLoader.load_files(dot_match: true, reverse: false)
  end

  def test_file_load_with_reverse_option
    files = %w[Rakefile exec_ls.rb lib test].reverse
    assert_equal files, FileLoader.load_files(dot_match: false, reverse: true)
  end

  def test_file_load_with_all_options
    files = %w[. .. .gitkeep Rakefile exec_ls.rb lib test].reverse
    assert_equal files, FileLoader.load_files(dot_match: true, reverse: true)
  end
end
