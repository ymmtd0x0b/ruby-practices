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
    files_status =
      @files.map do |fname|
        fstatus = File.lstat(fname)
        build_status(fname, fstatus)
      end

    max_chars = %i[nlink user group size].map do |key|
      [key, files_status.map { |file| file[key].size }.max]
    end.to_h

    total = files_status.map { |file| file[:size].to_i }.sum / BLOCK_SIZE
    body = files_status.map { |file| format_files(file, max_chars) }

    ["合計 #{total}", *body].join("\n")
  end

  private

  def build_status(fname, fstatus)
    {
      type_and_mode: format_type(fstatus) + format_mode(fstatus),
      nlink: fstatus.nlink.to_s,
      user: Etc.getpwuid(fstatus.uid).name,
      group: Etc.getgrgid(fstatus.gid).name,
      size: fstatus.size.to_s,
      mtime: fstatus.mtime.strftime('%_m月 %_d %H:%M'),
      fname: format_file_name(fname, fstatus)
    }
  end

  def format_type(fstatus)
    %w[directory link].include?(fstatus.ftype) ? fstatus.ftype[0] : '-'
  end

  def format_mode(fstatus)
    mode = fstatus.mode.digits(8).reverse.slice(-3..)
    mode.map do |m|
      MODE_MAP[m.to_s]
    end.join
  end

  def format_file_name(fname, fstatus)
    fstatus.ftype == 'link' ? "#{fname} -> #{File.readlink("./#{fname}")}" : fname
  end

  def format_files(fstatus, max_chars)
    [
      fstatus[:type_and_mode],
      fstatus[:nlink].rjust(max_chars[:nlink]),
      fstatus[:user].rjust(max_chars[:user]),
      fstatus[:group].rjust(max_chars[:group]),
      fstatus[:size].rjust(max_chars[:size]),
      fstatus[:mtime],
      fstatus[:fname]
    ].join(' ')
  end
end
