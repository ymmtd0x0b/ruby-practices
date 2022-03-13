# 仕様

# 引数と標準入力が同時に渡された場合は引数アリが優先される

#  - 引数：まずファイルを開けるか試みる
#         ➜ ファイルが無ければそのまま終了

#  - 標準入力：常に文字列(ファイルを開いた状態)として処理する

DIGIT = {stdin: 7, argv: 1}

def main
  ARGV.empty? ? stdin : argv
end

def stdin
  result = lines_words_size(STDIN.readlines, '')
  display(result, digit(result, :stdin))
end

def argv
  if ARGV.size.eql?(1)
    lws = lines_words_size(File.readlines(arg), arg) # lws = lines / words / size
    digit = digit(lws, :argv)
    display(lws, digit)
  else
    lws_list =
      ARGV.map do |arg|
        lines_words_size(File.readlines(arg), arg)
      end
    sums = sums(lws_list)
    digit = digit(sums, :argv)
    lws_list.each { |lws| display(lws, digit) }
    display(sums, digit)
  end
end

def sums(files)
  sum = {name: "合計", lines: 0, words: 0, size: 0}
  files.each do |file|
    file.each do |key, value|
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
