# frozen_string_literal: true

require 'etc'

class FileStat
  attr_reader :blocks, :nlink, :user, :group, :size

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

    @type_and_mode = format_type + format_mode
    @nlink         = @fstat.nlink.to_s
    @user          = Etc.getpwuid(@fstat.uid).name
    @group         = Etc.getgrgid(@fstat.gid).name
    @size          = @fstat.size.to_s
    @mtime         = @fstat.mtime.strftime('%_m月 %_d %H:%M')
    @basename      = format_basename
    @blocks        = @fstat.blocks
  end

  def format_stat(max_chars = { nlink: 0, user: 0, group: 0, size: 0 })
    [
      @type_and_mode,
      @nlink.rjust(max_chars[:nlink]),
      @user.ljust(max_chars[:user]),
      @group.ljust(max_chars[:group]),
      @size.rjust(max_chars[:size]),
      @mtime,
      @basename
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
