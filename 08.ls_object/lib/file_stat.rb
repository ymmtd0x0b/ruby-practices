# frozen_string_literal: true

require 'etc'

class FileStat
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

  attr_reader :stat

  def initialize(path)
    @path = path
    @fstat = File::Stat.new(path)

    @stat = {}
    @stat[:type_and_mode] = format_type + format_mode
    @stat[:nlink]         = @fstat.nlink.to_s
    @stat[:user]          = Etc.getpwuid(@fstat.uid).name
    @stat[:group]         = Etc.getgrgid(@fstat.gid).name
    @stat[:size]          = @fstat.size.to_s
    @stat[:mtime]         = @fstat.mtime.strftime('%_m月 %_d %H:%M')
    @stat[:basename]      = format_basename
  end

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
    file = File.basename(@path)
    @fstat.ftype == 'link' ? "#{file} -> #{File.readlink(file)}" : file
  end

  def format_stat(max_chars)
    [
      @stat[:type_and_mode],
      @stat[:nlink].rjust(max_chars[:nlink]),
      @stat[:user].rjust(max_chars[:user]),
      @stat[:group].rjust(max_chars[:group]),
      @stat[:size].rjust(max_chars[:size]),
      @stat[:mtime],
      @stat[:basename]
    ].join(' ')
  end
end
