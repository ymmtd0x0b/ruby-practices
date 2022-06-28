# frozen_string_literal: true

def main
  score = ARGV[0]
  game = Game.new(score)
  puts game.score
end

main
