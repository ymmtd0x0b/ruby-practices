# frozen_string_literal: true

require_relative './game'

def main
  score = ARGV[0]
  game = Game.new(score)
  puts game.score
end

main
