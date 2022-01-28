require 'date'
require 'optparse'

#カレンダーの雛形
class CalThreeMonths #３ヶ月分のカレンダー
  def initialize(today, year, month, highlight)
    @today = today
    @year = year
    @month = month
    @highlight = highlight
    @calendar = Array.new(3)
  end

  def create_cal
    ###前月を基点の日付(変数date)として、３ヶ月分のカレンダーを作成
    #基点の日付(前月)を計算
    date = @today.prev_month

    #３ヶ月分のカレンダーを作成
    3.times do |i|
      #変数dateに設定された日付のカレンダーを作成
      @calendar[i] = CalOneMonth.new(@today, date.year, date.month, @highlight)
      @calendar[i].create_cal

      #基点の日付を更新(次月を計算)
      date = date.next_month
    end
  end

  #出力処理
  def print_cal #３ヶ月分の出力
    ###それぞれ独立した各月のカレンダーを行単位で結合して出力する
    #タイトルの出力
    title_line =  @calendar[0].title +
                  @calendar[1].title +
                  @calendar[2].title
    print title_line + "\n"

    #曜日の出力
    wday_line = ""
    3.times do |i|
      wday_line += @calendar[i].wday.join
    end
    print wday_line + "\n"
  
    #カレンダー：日数部分
    6.times do |row| #カレンダーの日数部分は６行
      date_line = ""
      3.times do |i|
        date_line += @calendar[i].calendar[row].join + "  "
      end
      print date_line + "\n"
    end
  end
end

class CalOneMonth #１ヶ月分のカレンダー
  attr_reader :title, :wday, :calendar
  def initialize(today, year, month, highlight)
    #インスタンス変数
    @today = today
    @year = year
    @month = month
    @highlight = highlight

    #カレンダー：タイトル
    @title = ("      #{month.to_s}月 #{year}         ").chars.slice(0..21).join
    
    #カレンダー：曜日
    @wday = ["日 ", "月 ", "火 ", "水 ", "木 ", "金 ", "土  "]

    #日数の雛形(この雛形に当月の日数を埋めていく)
    @calendar = [["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],]
  end

  #出力処理
  def print_cal #１ヶ月分の出力
    #タイトルの出力
    print @title + "\n"

    #曜日の出力
    print @wday.join + "\n"
  
    #カレンダー：日数部分
    rows = @calendar.size
    rows.times do |row|
      print @calendar[row].join + "  \n"
    end
  end
  
  #雛形に日数を埋め込む処理
  def create_cal
    #当月の日数を取得
    days = Date.new(@year, @month, -1).day
    
    ###日付を適切なカレンダー位置に埋め込む
    week = 0
    1.step(days,1) do |day|
      date = Date.new(@year,@month,day)
      col = date.wday
      if date.sunday?
        n = -2
      else
        n = -3
      end
      #当月の日数を変数calenderの適切な座標に埋め込む
      #当日をハイライト
      if date == @today && @highlight == true
        day = (" " + day.to_s).slice(-2..-1) #１桁の数字は直前の空白も含んでハイライトを付ける / 擬似的に２桁にする
        day = "\e[47;30m" + day + "\e[0m" #背景色：白, 文字色：黒のカラーコードで日にちを挟む
        n -= 12 #ANSIカラーコードの分だけスライスする数を増やす
      end
      @calendar[week][col] = (@calendar[week][col] + day.to_s).chars.slice(n..-1).join #日にちを適切な座標に埋め込み
      week += 1 if col == 6 #金曜日(行末)まで到達したら週(行)を更新...()内は配列表現
    end
  end
end

###事前準備
###当月の各パラメータを取得
today = Date.today
year = today.year
month = today.month

###デフォルト値の設定
highlight = false #当日のハイライト

###オプションの処理
opt = OptionParser.new

###オプションの登録
#オプション名とその処理を定義する
opt.on('-y opt_year') { |opt_year| year = opt_year.to_i }
opt.on('-m opt_month') { |opt_month| month = opt_month.to_i }
opt.on('-1') {} 
opt.on('-3') do
  cal = CalThreeMonths.new(today, year, month, highlight)
  cal.create_cal #カレンダーの作成
  cal.print_cal #出力
end
opt.on('-h') { highlight = false }

#オプシションの実行
argv = opt.parse(ARGV)

#メイン処理
# cal = CalOneMonth.new(today, year, month, highlight) #初期化
# cal.create_cal #カレンダーの作成
# cal.print_cal #出力
