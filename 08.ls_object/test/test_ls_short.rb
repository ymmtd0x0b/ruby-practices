# frozen_string_literal: true

require 'test/unit'
require_relative '../lib/ls/ls_short'

class LsShortTest < Test::Unit::TestCase
  def setup
    @params = { dot_match: false, reverse: false }
  end

  def test_ls_short_run_with_no_option
    expected = <<~TEXT.chomp
      exec_ls.rb  lib  test
    TEXT
    assert_equal expected, LsShort.new(**@params).run
  end

  def test_ls_short_run_with_r_option
    expected = <<~TEXT.chomp
      test  lib  exec_ls.rb
    TEXT
    @params[:reverse] = true
    assert_equal expected, LsShort.new(**@params).run
  end

  def test_ls_short_run_with_a_option
    expected = <<~TEXT.chomp
      .   .gitkeep    lib
      ..  exec_ls.rb  test
    TEXT
    @params[:dot_match] = true
    assert_equal expected, LsShort.new(**@params).run
  end

  def test_ls_short_run_with_ar_options
    expected = <<~TEXT.chomp
      test  exec_ls.rb  ..
      lib   .gitkeep    .
    TEXT
    @params[:dot_match] = true
    @params[:reverse]   = true
    assert_equal expected, LsShort.new(**@params).run
  end
end
