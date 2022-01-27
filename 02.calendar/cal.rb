require 'date'
require 'optparse'

### 事前準備
### 当月の各パラメータを取得
today = Date.today
year = today.year
month = today.month

### オプションの処理
opt = OptionParser.new

### オプションの登録
# オプション名とその処理を定義する
opt.on('-y opt_year') { |opt_year| year = opt_year.to_i }
opt.on('-m opt_month') { |opt_month| month = opt_month.to_i }

argv = opt.parse(ARGV)

### 変数一覧
# today：当月
# year：当月の年
# month：当月の月
# 曜日：wday

### 単純なカレンダー表示
days = Date.new(year, month, -1).day

calendar = [["  ", "   ", "   ", "   ", "   ", "   ", "   "],
      ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
      ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
      ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
      ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
      ["  ", "   ", "   ", "   ", "   ", "   ", "   "],]

### 日付を適切なカレンダー位置に埋め込む
week = 0
1.step(days,1) do |day|
  wday = Date.new(year,month,day)
  col = wday.wday
  if wday.sunday?
    n = -2
  else
    n = -3
  end
  #当月の日数を変数calenderの適切な座標に埋め込む
  calendar[week][col] = (calendar[week][col] + day.to_s).chars.slice(n..-1).join
  week += 1 if col == 6
end

### 出力
# カレンダー：タイトル
title = "      #{month.to_s}月 #{year}         "
print title.slice(0..21) + "\n"

# カレンダー：曜日
wday = ["日 ", "月 ", "火 ", "水 ", "木 ", "金 ", "土  "]
print wday.join + "\n"

# カレンダー：日数部分
rows = calendar.size
rows.times do |row|
  print calendar[row].join + "  \n"
end
