# frozen_string_literal: true

require_relative './ls_short'
require_relative './ls_long'

def main
  opt = ARGV.getopts('alr')
  params = { dot_match: opt['a'], reverse: opt['r'] }

  ls = opt['l'] ? LsLong.new(**params) : LsShort.new(**params)

  puts ls.run
end

main
