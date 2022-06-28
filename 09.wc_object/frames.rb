# frozen_string_literal: true

require 'forwardable'
require_relative './frame'
require_relative './shot'

class Frames
  extend Forwardable
  def_delegators :@frames, :each_with_index, :slice
  include Enumerable

  FRAMES_PER_GAME = 10
  LAST_FRAME = FRAMES_PER_GAME - 1

  def initialize(score)
    mock_frames = mock_frames(score)

    @frames =
      mock_frames.map do |shots_per_frame|
        create_frame(shots_per_frame)
      end
  end

  private

  def create_shot(mark)
    Shot.new(mark)
  end

  def create_frame(shots_per_frame)
    Frame.new(shots_per_frame)
  end

  def mock_frames(score)
    scores = score.split(',').map { |mark| create_shot(mark) }

    Array.new(FRAMES_PER_GAME) do |idx|
      num = shots_per_frame(nth_frame: idx, first_shot_score: scores[0].score)
      scores.shift(num)
    end
  end

  def shots_per_frame(nth_frame:, first_shot_score:)
    if nth_frame == LAST_FRAME # ラストフレームは最大３投
      3
    else
      first_shot_score == 10 ? 1 : 2 # 各フレームは１投目が'X'(ストライク)なら１投、'X'(ストライク)以外なら２投
    end
  end
end
