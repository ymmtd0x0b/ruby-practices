# frozen_string_literal: true

require 'optparse'

DEFAULT_DIGIT_SIZE = { stdin: 7, argv: 1 }.freeze

def main
  option = ARGV.getopts('l')
  ARGV.empty? ? stdin(option) : argv(option)
end

def stdin(option)
  lws = lines_words_size(contents: $stdin.readlines, file_name: '') # lws = lines / words / size の意
  digit = option['l'] ? 1 : max_digit_size(lws, :stdin)
  display(option, [lws], digit)
end

def argv(option)
  if ARGV.size == 1
    lws = lines_words_size(contents: File.readlines(ARGV[0]), file_name: ARGV[0])
    digit = option['l'] ? 1 : max_digit_size(lws, :argv)
    display(option, [lws], digit)
  else
    lws_list = ARGV.map { |arg| lines_words_size(contents: File.readlines(arg), file_name: arg) }
    lws_list << sums(lws_list)
    display(option, lws_list, max_digit_size(lws_list.last, :argv))
  end
end

def sums(lws_list)
  sum = { lines: 0, words: 0, size: 0 }
  sum.each_key do |key|
    lws_list.each do |lws|
      sum[key] += lws[key]
    end
  end
  sum.merge(name: '合計')
end

# 出力時の各列の桁は各列(行数/単語数/ファイルサイズ)の中で最も大きい桁数で揃える
def max_digit_size(file, process_type)
  [
    DEFAULT_DIGIT_SIZE[process_type],
    file[:lines].digits.size,
    file[:words].digits.size,
    file[:size].digits.size
  ].max
end

def lines_words_size(contents:, file_name:)
  {
    name: file_name,
    lines: contents.count,
    words: contents.join.split.count,
    size: contents.join.bytesize
  }
end

def display(option, lws_list, digit)
  lws_list.each do |lws|
    if option['l']
      printf("%#{digit}s %s\n", lws[:lines], lws[:name])
    else
      printf("%#{digit}s %#{digit}s %#{digit}s %s\n", lws[:lines], lws[:words], lws[:size], lws[:name])
    end
  end
end

main
