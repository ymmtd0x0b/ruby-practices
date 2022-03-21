# frozen_string_literal: true

require 'optparse'

DIGIT = { stdin: 7, argv: 1 }.freeze

def main
  option = ARGV.getopts('l')
  ARGV.empty? ? stdin(option) : argv(option)
end

def stdin(option)
  lws = lines_words_size($stdin.readlines, '') # lws = lines / words / size の意
  digit = option['l'] ? 1 : max_digit(lws, :stdin)
  display(option, [lws], digit)
end

def argv(option)
  if ARGV.size == 1
    lws = lines_words_size(File.readlines(ARGV[0]), ARGV[0])
    digit = option['l'] ? 1 : max_digit(lws, :argv)
    display(option, [lws], digit)
  else
    lws_list = ARGV.map { |arg| lines_words_size(File.readlines(arg), arg) }
    lws_list << sums(lws_list)
    display(option, lws_list, max_digit(lws_list.last, :argv))
  end
end

def sums(lws_list)
  sum = { name: '合計', lines: 0, words: 0, size: 0 }
  lws_list.each do |lws|
    lws.each do |key, value|
      next if key.eql?(:name)

      sum[key] += value
    end
  end
  sum
end

# 出力時の各列の桁は各列(行数/単語数/ファイルサイズ)の中で最も大きい桁数で揃える
def max_digit(file, process_type)
  [
    DIGIT[process_type],
    file[:lines].digits.size,
    file[:words].digits.size,
    file[:size].digits.size
  ].max
end

def lines_words_size(contents, arg)
  {
    name: arg,
    lines: contents.count,
    words: contents.join.split(nil).count,
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
