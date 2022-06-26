# frozen_string_literal: true

require_relative './shot'
require_relative './frame'

module FramesFactory
  NUMBER_OF_FRAMES_PER_GAME = 10
  
  def self.build(score)
    shots_per_frames = create_shots_per_frames(score)
    shots_per_frames.map do |shots_per_frame|
      Frame.new(shots_per_frame)
    end
  end

  private

  def self.create_shots_per_frames(score)
    scores = score.split(',')
    scores = scores.map { |score| Shot.new(score) }

    NUMBER_OF_FRAMES_PER_GAME.times.map do |frame|
      num = number_of_throws_per_frame(frame, scores[0].score)
      scores.shift(num)
    end
  end

  def self.number_of_throws_per_frame(number_of_frame, first_shot_of_frame)
    if number_of_frame == 9 # ラストフレームは最大３投
      3
    else
      first_shot_of_frame == 10 ? 1 : 2 # １〜９フレームは１投目が'X'(ストライク)なら１投、'X'(ストライク)以外なら２投
    end
  end
end
