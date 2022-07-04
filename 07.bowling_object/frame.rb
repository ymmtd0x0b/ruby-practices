# frozen_string_literal: true

class Frame
  attr_reader :shots

  BONUS_SCORE = 10

  def initialize(shots = [])
    @shots = shots
  end

  def score
    @shots.sum(&:score)
  end

  def strike?
    @shots[0].score == BONUS_SCORE
  end

  def spare?
    @shots.size == 2 && score == BONUS_SCORE
  end
end
