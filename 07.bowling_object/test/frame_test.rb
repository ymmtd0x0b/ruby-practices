# frozen_string_literal: true

require 'test/unit'
require_relative '../shot'
require_relative '../frame'

class TestFrame < Test::Unit::TestCase
  def setup
    @shot1 = Shot.new('1')
    @shot2 = Shot.new('2')
    @shot3 = Shot.new('3')
    @shot7 = Shot.new('7')
    @shot10 = Shot.new('X')
  end

  sub_test_case 'Frame score' do
    test '[1,2] == 3' do
      frame = Frame.new([@shot1, @shot2])
      assert_equal 3, frame.score
    end

    test 'Strike == 10' do
      frame = Frame.new([@shot10])
      assert_equal 10, frame.score
    end

    test 'All Strike in LastFrame == 30' do
      frame = Frame.new([@shot10, @shot10, @shot10])
      assert_equal 30, frame.score
    end
  end

  sub_test_case 'Confirmation strike' do
    test '[1,2] is not strike' do
      frame = Frame.new([@shot1, @shot2])
      assert_false frame.strike?
    end

    test '[X] is strike' do
      frame = Frame.new([@shot10])
      assert_true frame.strike?
    end
  end

  sub_test_case 'Confirmation spare' do
    test '[1,2] = 3 is not spare' do
      frame = Frame.new([@shot1, @shot2])
      assert_false frame.spare?
    end

    test '[3,7] = 10 is spare' do
      frame = Frame.new([@shot3, @shot7])
      assert_true frame.spare?
    end
  end
end
