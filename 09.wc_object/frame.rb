# frozen_string_literal: true

class Frame
  attr_reader :shots

  def initialize(shots=[])
    @shots = shots
  end

  # def first_shot
  #   shots[0]
  # end

  # def second_shot
  #   shots[1]
  # end

  def score
    shots.sum { |shot| shot.score }
  end

  def strike?
    shots[0].score == 10
  end

  def spare?
    shots.sum { |shot| shot.score } == 10
  end
end
