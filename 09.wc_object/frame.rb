# frozen_string_literal: true

class Frame
  attr_reader :shots

  def initialize(shots = [])
    @shots = shots
  end

  def score
    @shots.sum(&:score)
  end

  def strike?
    @shots[0].score == 10
  end

  def spare?
    @shots.size == 2 && score == 10
  end
end
