# frozen_string_literal: true

require 'test/unit'
require_relative './shot'
require_relative './frame'
require_relative './game'

class TestShot < Test::Unit::TestCase
  test 'Translate "0" to 0' do
    shot = Shot.new('0')
    assert_equal 0, shot.score
  end

  test 'Translate "X" to 10' do
    shot = Shot.new('X')
    assert_equal 10, shot.score
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

  test 'Frame.score method' do
    frame = Frame.new([@shot1, @shot2])
    assert_equal 3, frame.score

    frame = Frame.new([@shot10])
    assert_equal 10, frame.score

    frame = Frame.new([@shot10, @shot10, @shot10])
    assert_equal 30, frame.score
  end

  test 'Frame.strike?' do
    frame = Frame.new([@shot1, @shot2])
    assert_false frame.strike?

    frame = Frame.new([@shot10])
    assert_true frame.strike?
  end

  test 'Frame.spare?' do
    frame = Frame.new([@shot1, @shot2])
    assert_false frame.spare?

    frame = Frame.new([@shot3, @shot7])
    assert_true frame.spare?
  end
end

class TestFrames < Test::Unit::TestCase
  test 'Frames.next_three_shots_score' do
    frames = FramesFactory.build('X,X,X,X,X,X,X,X,X,X,X,X')
    assert_equal 30, frames.next_three_shots_score(0)

    frames = FramesFactory.build('1,9,X,X,X,X,X,X,X,X,X,X,X')
    assert_equal 20, frames.next_three_shots_score(0)
  end
end

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
