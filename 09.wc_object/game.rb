# frozen_string_literal: true

require_relative './frames_factory'

class Game
  attr_reader :frames

  def initialize(score)
    @frames = FramesFactory.build(score)
  end

  def score
    (0..9).each.sum do |n|
      frame, next_frame, after_frame = frames.slice(n, 3)
      left_shots = (next_frame.nil? ? [] : next_frame.shots) + (after_frame.nil? ? [] : after_frame.shots)

      # frame = frames[n]
      if frame.strike?
        frame.score + left_shots.slice(0,2).sum { |shot| shot.score }
      elsif frame.spare?
        frame.score + left_shots[0].score
      else
        frame.score
      end
    end
  end
end
