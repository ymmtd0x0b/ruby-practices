# frozen_string_literal: true

module PointRule
  class << self
    def score(frames:)
      frames.each_with_index.sum do |frame, idx|
        if frame.strike?
          frame.score + strike_with_bonus(frames, idx)
        elsif frame.spare?
          frame.score + spare_with_bonus(frames, idx)
        else
          frame.score
        end
      end
    end

    private

    # 次のフレームから指定投球分(count)を合計し、その数値分をボーナスとする
    def bonus_score(frames:, idx:, count:)
      next_idx = idx + 1
  
      target_frames = frames.slice(next_idx, 2).compact # 連続ストライクの場合、最大２フレーム分が計算対象となる
      shots = target_frames.map(&:shots)
      shots.flatten.slice(0, count).sum(&:score)
    end

    def strike_with_bonus(frames, idx)
      bonus_score(frames: frames, idx: idx, count: 2)
    end

    def spare_with_bonus(frames, idx)
      bonus_score(frames: frames, idx: idx, count: 1)
    end
  end
end
