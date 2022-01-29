require 'date'
require 'optparse'
###################
#クラスの定義
###################
#カレンダーの雛形
class CalOneYear #１年分のカレンダー
  def initialize(today, year, month, highlight)
    @today = today
    @year = year
    @month = month
    @highlight = highlight
    @calendar = Array.new(4){ Array.new(3) }
  end

  def create_cal
    month = 1
    #１２ヶ月分のカレンダーを作成
    4.times do |i|
      3.times do |j|
        @calendar[i][j] = CalOneMonth.new(@today, @year, month, @otp_h)
        @calendar[i][j].create_cal
        month += 1
      end
    end
  end

  #出力処理
  def print_cal #３ヶ月分の出力
    ###それぞれ独立した各月のカレンダーを行単位で結合して出力する
    #タイトルの出力
    year_title = "                            #{@year}"
    print year_title + "\n"
    4.times do |r|
      title_line = ""
      3.times do |i|
        title_line += ("         " + @calendar[r][i].month.to_s + "月").chars.slice(-11..-1).join + "          " + " "
      end
      print title_line + "\n"

      #曜日の出力
      wday_line = ""
      3.times do |i|
        wday_line += @calendar[r][i].wday.join
      end
      print wday_line + "\n"
    
      #カレンダー：日数部分
      6.times do |row| #カレンダーの日数部分は６行
        date_line = ""
        3.times do |i|
          date_line += @calendar[r][i].calendar[row].join + "  "
        end
        print date_line + "\n"
      end
      print "\n" #１行空白
    end
  end
end

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
      @calendar[i] = CalOneMonth.new(@today, date.year, date.month, @otp_h)
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
  attr_reader :title, :wday, :month, :calendar
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

class GetOptions
  def initialize
    @options = {}
    OptionParser.new do |opt|
      opt.on('-y [value]', '--year [value]') { |v| @options[:y] = v  }
      opt.on('-m value', '--month value') { |v| @options[:m] = v  }
      opt.on('-h') { |v| @options[:h] = true  }
      opt.on('-1') { |v| @options[:one] = true  }
      opt.on('-3') { |v| @options[:three] = true  }
      opt.parse!(ARGV)
    end
  end

  def has?(name)
    @options.include?(name)
  end

  def get(name)
    @options[name]
  end
end

class GetArgument
  def initialize
    @arg = {}
    if ARGV.size >= 2
      @arg[:m] = ARGV[0].to_i
      @arg[:y] = ARGV[1].to_i
    elsif ARGV.size == 1
      @arg[:y] = ARGV[0].to_i
    end
  end

  def has_both?
    ARGV.size >= 2
  end

  def has_month_only?
    !@arg[:m].nil?
  end

  def has_year_only?
    !@arg[:y].nil?
  end

  def get(name)
    @arg[name]
  end
end

###事前準備
###当月の各パラメータを取得
today = Date.today
year = today.year
month = today.month

###############
#メイン処理
###############
option = GetOptions.new
arg = GetArgument.new

case #オプションによる処理の分岐
#cal -y / cal -y 数値
when option.has?(:y) == true
  year = option.get(:y).to_i unless option.get(:y).nil? #引数有りならyearに代入
  cal = CalOneYear.new(today, year, month, true)

#cal -m / cal -m 数値
when option.has?(:m) == true 
  month = option.get(:m).to_i
  cal = CalOneMonth.new(today, year, month, true)

#cal -h
when option.has?(:h) == true
  cal = CalOneMonth.new(today, year, month, false)

#cal -1
when option.has?(:one) == true
  cal = CalOneYear.new(today, year, month, true)

#cal -3 
when option.has?(:three) == true
  cal = CalThreeMonths.new(today, year, month, true)

#cal month year
when arg.has_both? == true
  year = arg.get(:y)
  month = arg.get(:m)
  cal = CalOneMonth.new(today, year, month, true)

#cal year
when arg.has_year_only? == true
  year = arg.get(:y)
  cal = CalOneYear.new(today, year, month, true)

#cal
else
  cal = CalOneMonth.new(today, year, month, true)
end

cal.create_cal #カレンダーの作成
cal.print_cal #出力
