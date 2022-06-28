# frozen_string_literal: true

require_relative './frames'
require_relative './point_rule'

class Game
  def initialize(score)
    @frames = Frames.new(score)
  end

  def score
    PointRule.score(frames: @frames)
  end
end
