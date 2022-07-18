# frozen_string_literal: true

require 'test/unit'
require_relative '../lib/ls/ls_long'

class LsLongTest < Test::Unit::TestCase
  def setup
    @params = { dot_match: false, reverse: false }
  end

  def test_ls_long_run_with_no_option
    assert_equal `ls -l`.chomp, LsLong.new(**@params).run
  end

  def test_ls_long_run_with_r_option
    @params[:reverse] = true
    assert_equal `ls -lr`.chomp, LsLong.new(**@params).run
  end

  def test_ls_long_run_with_a_option
    @params[:dot_match] = true
    assert_equal `ls -la`.chomp, LsLong.new(**@params).run
  end

  def test_ls_long_run_with_ar_options
    @params[:dot_match] = true
    @params[:reverse]   = true
    assert_equal `ls -lar`.chomp, LsLong.new(**@params).run
  end
end
