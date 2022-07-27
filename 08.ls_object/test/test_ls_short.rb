# frozen_string_literal: true

require 'test/unit'
require_relative '../lib/file/file_loader'
require_relative '../lib/ls/ls_short'

class LsShortTest < Test::Unit::TestCase
  def setup
    @params = { dot_match: false, reverse: false }
  end

  def test_ls_short_run_with_no_option
    expected = <<~TEXT.chomp
      exec_ls.rb  lib  test
    TEXT
    files = FileLoader.load_files(**@params)
    assert_equal expected, LsShort.new(files).run
  end

  def test_ls_short_run_with_r_option
    expected = <<~TEXT.chomp
      test  lib  exec_ls.rb
    TEXT
    @params[:reverse] = true
    files = FileLoader.load_files(**@params)
    assert_equal expected, LsShort.new(files).run
  end

  def test_ls_short_run_with_a_option
    expected = <<~TEXT.chomp
      .   .gitkeep    lib
      ..  exec_ls.rb  test
    TEXT
    @params[:dot_match] = true
    files = FileLoader.load_files(**@params)
    assert_equal expected, LsShort.new(files).run
  end

  def test_ls_short_run_with_ar_options
    expected = <<~TEXT.chomp
      test  exec_ls.rb  ..
      lib   .gitkeep    .
    TEXT
    @params[:dot_match] = true
    @params[:reverse]   = true
    files = FileLoader.load_files(**@params)
    assert_equal expected, LsShort.new(files).run
  end
end
