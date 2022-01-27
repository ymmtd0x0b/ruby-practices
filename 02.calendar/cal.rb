require 'date'

### 変数一覧
# today：当月
# year：当月の年
# month：当月の月
# 曜日：wday

### メモ
# Date.new(year,month,1) ...当月の月初を取得
# Date.new(year,month,1).next_month.prev_day ...当月の月末を取得

### 当月の各パラメータを取得
today = Date.today
year = today.year
month = today.month


### 単純なカレンダー表示
# days = Date.new(year,month,1).next_month.prev_day.day
days = Date.new(year, month, -1).day

=begin
1.step(days,1) do |day|
  if day % 7 == 1
    print (" " + day.to_s).chars.slice(-2..-1).join
  else
    print ("  " + day.to_s).chars.slice(-3..-1).join
  end
  print "\n" if day % 7 == 0
end
=end

cal = [["  ", "   ", "   ", "   ", "   ", "   ", "   "],
      ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
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
  cal[week][col] = (cal[week][col] + day.to_s).chars.slice(n..-1).join
  week += 1 if col == 6
end

### 出力
# カレンダー：タイトル
title = "      #{month.to_s}月 #{year}\n"
print title

# カレンダー：曜日
wday = ["日 ", "月 ", "火 ", "水 ", "木 ", "金 ", "土 "]
print wday.join + "\n"

# カレンダー：日数部分
rows = cal.size
rows.times do |row|
  print cal[row].join + "\n"
end
