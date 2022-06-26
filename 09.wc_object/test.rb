# frozen_string_literal: true

require 'test/unit'
require_relative './shot'
require_relative './frame'
require_relative './game'

class TestShot < Test::Unit::TestCase
  sub_test_case "Shot" do
    test "'0' => 0" do
      shot = Shot.new('0')
      assert_equal 0, shot.score
    end

    test "'X' => 10" do
      shot = Shot.new('X')
      assert_equal 10, shot.score
    end
  end
end

class TestFrame < Test::Unit::TestCase
  sub_test_case "Frame" do
    test "Not Strike" do
      shot1 = Shot.new('1')
      shot2 = Shot.new('5')
      frame = Frame.new([shot1, shot2])
      assert_equal 6, frame.score
    end

    test "Strike" do
      shot = Shot.new('X')
      frame = Frame.new([shot])
      assert_equal 10, frame.score
    end

    test "Strike in LastFrame" do
      shot = Shot.new('X')
      frame = Frame.new([shot, shot, shot])
      assert_equal 30, frame.score
    end

    test "Frame.strike? == true" do
      shot10 = Shot.new('X')
      frame = Frame.new([shot10])
      assert_true frame.strike?
    end

    test "Frame.strike? == false" do
      shot1 = Shot.new('1')
      shot2 = Shot.new('2')
      frame = Frame.new([shot1, shot2])
      assert_false frame.strike?
    end
  end

  class TestGame < Test::Unit::TestCase
    sub_test_case "Game" do
      test "6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5" do
        game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5')
        assert_equal 139, game.score
      end

      test "6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X" do
        game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X')
        assert_equal 164, game.score
      end

      test "0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4" do
        game = Game.new('0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4')
        assert_equal 107, game.score
      end
      
      test "6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0" do
        game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0')
        assert_equal 134, game.score
      end
      
      test "6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8" do
        game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8')
        assert_equal 144, game.score
      end
      
      test "X,X,X,X,X,X,X,X,X,X,X,X" do
        game = Game.new('X,X,X,X,X,X,X,X,X,X,X,X')
        assert_equal 300, game.score
      end
    end
  end
end
