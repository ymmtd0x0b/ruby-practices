# frozen_string_literal: true

require_relative './frames_factory'

class Game
  def initialize(score)
    @frames = FramesFactory.build(score)
  end

  def score
    @frames.each_with_index.sum do |frame, idx|
      if frame.strike? || frame.spare?
        @frames.next_three_shots_score(idx)
      else
        frame.score
      end
    end
  end
end
