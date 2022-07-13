# frozen_string_literal: true

require_relative './ls_short'
require_relative './ls_long'

def main
  opt = ARGV.getopts('alr')

  ls =
    if opt['l']
      LsLong.new(dot_match: opt['a'], reverse: opt['r'])
    else
      LsShort.new(dot_match: opt['a'], reverse: opt['r'])
    end
  puts ls.lines
end

main
