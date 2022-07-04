# frozen_string_literal: true

require_relative './shot'
require_relative './frame'

module FramesFactory
  FRAMES_PER_GAME = 10
  LAST_FRAME = FRAMES_PER_GAME - 1

  class << self
    def create(score)
      scores = score.split(',').map { |mark| Shot.new(mark) }

      Array.new(FRAMES_PER_GAME) do |idx|
        num = shots_per_frame(nth_frame: idx, first_shot_score: scores[0].score)
        Frame.new(scores.shift(num))
      end
    end

    private

    def shots_per_frame(nth_frame:, first_shot_score:)
      if nth_frame == LAST_FRAME # ラストフレームは最大３投
        3
      else
        first_shot_score == 10 ? 1 : 2 # 各フレームは１投目が'X'(ストライク)なら１投、'X'(ストライク)以外なら２投
      end
    end
  end
end
