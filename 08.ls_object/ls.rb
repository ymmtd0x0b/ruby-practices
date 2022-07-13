# frozen_string_literal: true

require 'optparse'

class Ls
  attr_reader :lines

  def initialize(dot_match: false, reverse: false)
    Dir.chdir(Dir.home)

    params = dot_match ? ['*', File::FNM_DOTMATCH] : ['*']
    @files = Dir.glob(*params)

    @files = reverse ? @files.reverse : @files.sort
  end
end
