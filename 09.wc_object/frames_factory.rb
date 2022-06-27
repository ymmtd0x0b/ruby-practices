# frozen_string_literal: true

require_relative './shot'
require_relative './frame'
require_relative './frames'

module FramesFactory
  FRAMES_PER_GAME = 10

  def self.build(score)
    shots_per_frames = create_shots_per_frames(score)
    Frames.new(
      shots_per_frames.map do |shots_per_frame|
        create_frame(shots_per_frame)
      end
    )
  end

  class << self
    private

    def create_shot(score)
      Shot.new(score)
    end

    def create_frame(shots_per_frame)
      Frame.new(shots_per_frame)
    end

    def create_shots_per_frames(score)
      scores = score.split(',').map { |s| create_shot(s) }

      Array.new(FRAMES_PER_GAME) do |idx|
        num = shots_per_frame(number_of_frame: idx, first_shot: scores[0].score)
        scores.shift(num)
      end
    end

    def shots_per_frame(number_of_frame:, first_shot:)
      if number_of_frame == 9 # ラストフレームは最大３投
        3
      else
        first_shot == 10 ? 1 : 2 # １〜９フレームは１投目が'X'(ストライク)なら１投、'X'(ストライク)以外なら２投
      end
    end
  end
end
