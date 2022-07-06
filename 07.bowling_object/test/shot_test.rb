# frozen_string_literal: true

require 'test/unit'
require_relative '../shot'

class TestShot < Test::Unit::TestCase
  sub_test_case 'Translate mark to score' do
    test '"0" to 0' do
      shot = Shot.new('0')
      assert_equal 0, shot.score
    end

    test '"X" to 10' do
      shot = Shot.new('X')
      assert_equal 10, shot.score
    end
  end
end
