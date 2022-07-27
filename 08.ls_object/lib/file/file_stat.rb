# frozen_string_literal: true

require 'etc'

class FileStat
  attr_reader :attr

  MODE_MAP = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  def initialize(file)
    @file = file
    @fstat = File.lstat(file)

    @attr = {}
    @attr[:type_and_mode] = format_type + format_mode
    @attr[:nlink]         = @fstat.nlink.to_s
    @attr[:user]          = Etc.getpwuid(@fstat.uid).name
    @attr[:group]         = Etc.getgrgid(@fstat.gid).name
    @attr[:size]          = @fstat.size.to_s
    @attr[:mtime]         = @fstat.mtime.strftime('%_m月 %_d %H:%M')
    @attr[:basename]      = format_basename
    @attr[:blocks]        = @fstat.blocks
  end

  def format_stat(max_chars)
    [
      @attr[:type_and_mode],
      @attr[:nlink].rjust(max_chars[:nlink]),
      @attr[:user].ljust(max_chars[:user]),
      @attr[:group].ljust(max_chars[:group]),
      @attr[:size].rjust(max_chars[:size]),
      @attr[:mtime],
      @attr[:basename]
    ].join(' ')
  end

  private

  def format_type
    %w[directory link].include?(@fstat.ftype) ? @fstat.ftype[0] : '-'
  end

  def format_mode
    mode = @fstat.mode.digits(8).reverse.slice(-3..)
    mode.map do |m|
      MODE_MAP[m.to_s]
    end.join
  end

  def format_basename
    @fstat.ftype == 'link' ? "#{@file} -> #{File.readlink(@file)}" : @file
  end
end
