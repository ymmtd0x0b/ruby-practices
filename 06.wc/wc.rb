# 仕様

# 引数と標準入力が同時に渡された場合は引数アリが優先される

#  - 引数：まずファイルを開けるか試みる
#         ➜ ファイルが無ければそのまま終了

#  - 標準入力：常に文字列(ファイルを開いた状態)として処理する

DEFAULT_DIGIT_IN_STDIN = 7
DEFAULT_DIGIT_IN_ARGV = 1

def main
  ARGV.empty? ? stdin : argv
end

def stdin
  result = wc(STDIN.readlines, '')
  digit = DEFAULT_DIGIT_IN_STDIN
  sum = 0
  result.each do |key, value|
    next if key.eql?(:name)
    digit = value.digits.size if digit < value.digits.size
  end
  display(result, digit)
end

def argv
  files =
    ARGV.map do |arg|
      wc(File.readlines(arg), arg)
    end

  digit = DEFAULT_DIGIT_IN_ARGV
  sum = {name: "合計", lines: 0, words: 0, size: 0}
  files.each do |file|
    file.each do |key, value|
      next if key.eql?(:name)
      sum[key] += value
      digit = sum[key].digits.size if digit < sum[key].digits.size
    end
  end

  files.each { |file| display(file, digit) }
  printf("%#{digit}s %#{digit}s %#{digit}s %s\n", sum[:lines], sum[:words], sum[:size], sum[:name]) if ARGV.size >= 2

end

def wc(contents, arg)
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
