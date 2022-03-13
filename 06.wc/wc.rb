# frozen_string_literal: true

DIGIT = { stdin: 7, argv: 1 }.freeze

def main
  option
  ARGV.empty? ? stdin : argv
end

def stdin
  result = lines_words_size($stdin.readlines, '')
  display(result, digit(result, :stdin))
end

def argv
  if ARGV.size.eql?(1)
    lws = lines_words_size(File.readlines(ARGV[0]), ARGV[0]) # lws = lines / words / size
    digit = digit(lws, :argv)
    display(lws, digit)
  else
    lws_list =
      ARGV.map do |arg|
        lines_words_size(File.readlines(arg), arg)
      end
    sums = sums(lws_list)
    digit = digit(sums, :argv)
    lws_list.each { |element| display(element, digit) }
    display(sums, digit)
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
def digit(file, process_type)
  digit = DIGIT[process_type]
  file.each do |key, value|
    next if key.eql?(:name)

    digit = value.digits.size if digit < value.digits.size
  end
  digit
end

def lines_words_size(contents, arg)
  {
    name: arg,
    lines: contents.count,
    words: contents.join.split(nil).count,
    size: contents.join.bytesize
  }
end

def display(file, digit)
  printf("%#{digit}s %#{digit}s %#{digit}s %s\n", file[:lines], file[:words], file[:size], file[:name])
end

main
