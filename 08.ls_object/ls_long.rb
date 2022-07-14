# frozen_string_literal: true

require 'etc'
require_relative './ls'

class LsLong < Ls
  BLOCK_SIZE = 1024
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

  def initialize(params)
    super(**params)
  end

  def run
    file_stats =
      @files.map do |file|
        stat = File.lstat(file)
        build_stat(file, stat)
      end

    max_chars = %i[nlink user group size].map do |key|
      [key, file_stats.map { |file| file[key].length }.max]
    end.to_h

    total = file_stats.map { |file| file[:size].to_i }.sum / BLOCK_SIZE
    body = file_stats.map { |stat| format_stat(stat, max_chars) }

    ["合計 #{total}", *body].join("\n")
  end

  private

  def build_stat(file, stat)
    {
      type_and_mode: format_type(stat) + format_mode(stat),
      nlink: stat.nlink.to_s,
      user: Etc.getpwuid(stat.uid).name,
      group: Etc.getgrgid(stat.gid).name,
      size: stat.size.to_s,
      mtime: stat.mtime.strftime('%_m月 %_d %H:%M'),
      basename: format_basename(file, stat)
    }
  end

  def format_type(stat)
    %w[directory link].include?(stat.ftype) ? stat.ftype[0] : '-'
  end

  def format_mode(stat)
    mode = stat.mode.digits(8).reverse.slice(-3..)
    mode.map do |m|
      MODE_MAP[m.to_s]
    end.join
  end

  def format_basename(file, stat)
    stat.ftype == 'link' ? "#{file} -> #{File.readlink(file)}" : file
  end

  def format_stat(stat, max_chars)
    [
      stat[:type_and_mode],
      stat[:nlink].rjust(max_chars[:nlink]),
      stat[:user].rjust(max_chars[:user]),
      stat[:group].rjust(max_chars[:group]),
      stat[:size].rjust(max_chars[:size]),
      stat[:mtime],
      stat[:basename]
    ].join(' ')
  end
end
