# frozen_string_literal: true

require_relative './frames_factory'
require_relative './point_rule'

class Game
  def initialize(score)
    @frames = FramesFactory.create(score)
  end

  def score
    PointRule.score(frames: @frames)
  end
end
