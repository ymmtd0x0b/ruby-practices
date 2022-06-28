# frozen_string_literal: true

require 'test/unit'
require_relative './shot'
require_relative './frame'
require_relative './frames'
require_relative './game'

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

# class TestFrames < Test::Unit::TestCase
#   test 'Frames.next_shots_score' do
#     frames = Frames.new('X,X,X,X,X,X,X,X,X,X,X,X')
#     assert_equal 20, frames.next_shots_score(idx: 0, throws: 2)

#     frames = Frames.new('X,X,X,X,X,X,X,X,X,X,X,X,X')
#     assert_equal 10, frames.next_shots_score(idx: 0, throws: 1)
#   end
# end

class TestGame < Test::Unit::TestCase
  test '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5' do
    game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5')
    assert_equal 139, game.score
  end

  test '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X' do
    game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X')
    assert_equal 164, game.score
  end

  test '0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4' do
    game = Game.new('0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4')
    assert_equal 107, game.score
  end

  test '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0' do
    game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0')
    assert_equal 134, game.score
  end

  test '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8' do
    game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8')
    assert_equal 144, game.score
  end

  test 'X,X,X,X,X,X,X,X,X,X,X,X' do
    game = Game.new('X,X,X,X,X,X,X,X,X,X,X,X')
    assert_equal 300, game.score
  end
end
