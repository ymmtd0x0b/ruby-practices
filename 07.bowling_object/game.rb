# frozen_string_literal: true

require_relative './frames_factory'

class Game
  def initialize(score)
    @frames = FramesFactory.create(score)
  end

  def score
    @frames.each_with_index.sum do |frame, idx|
      if frame.strike?
        frame.score + bonus_score(idx: idx, count: 2)
      elsif frame.spare?
        frame.score + bonus_score(idx: idx, count: 1)
      else
        frame.score
      end
    end
  end

  private

  # 次のフレームから指定投球分(count)を合計し、その数値分をボーナスとする
  def bonus_score(idx:, count:)
    next_idx = idx + 1
    target_frames = frames.slice(next_idx, 2).compact # 最大２フレーム分が計算対象となる
    shots = target_frames.map(&:shots)
    shots.flatten.slice(0, count).sum(&:score)
  end
end
