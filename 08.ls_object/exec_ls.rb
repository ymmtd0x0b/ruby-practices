# frozen_string_literal: true

require 'optparse'
require_relative './lib/file/file_loader'
require_relative './lib/ls/ls_short'
require_relative './lib/ls/ls_long'

def main
  opt = ARGV.getopts('alr')
  params = { dot_match: opt['a'], reverse: opt['r'] }

  files = FileLoader.load_files(**params)

  ls = opt['l'] ? LsLong.new(files) : LsShort.new(files)
  puts ls.run
end

main
