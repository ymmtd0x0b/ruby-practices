# frozen_string_literal: true

require_relative './short_ls'
require_relative './long_ls'

def main
  puts LongLs.new(ARGV).lines
end

main
