# frozen_string_literal: true

require 'test/unit'
require_relative './shot'

class TestShot < Test::Unit::TestCase
  sub_test_case "Shot" do
    test "'0' == 0" do
      shot = Shot.new('0')
      assert_equal 0, shot.score
    end

    test "'X' == 10" do
      shot = Shot.new('X')
      assert_equal 10, shot.score
    end
  end
end
