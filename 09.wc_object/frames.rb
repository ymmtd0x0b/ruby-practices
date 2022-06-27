# frozen_string_literal: true

require 'forwardable'

class Frames
  extend Forwardable
  def_delegators :@frames, :each_with_index
  include Enumerable

  def initialize(frames)
    @frames = frames
  end

  def next_three_shots_score(idx)
    # 指定フレーム(idx)から最大３フレーム(３連続ストライク)分のショットの内、最初の３ショット分を合計
    three_frames = @frames.slice(idx, 3).compact
    shots = three_frames.map(&:shots)
    shots.flatten.slice(0, 3).sum(&:score)
  end
end
