require 'date'
require 'optparse'

class OneYearCalendar
  def initialize(date)
    @date = date
    @calendar = Array.new(4) { Array.new(3) }
    create_calendar
  end

  def print_calendar
    year_title = "                            #{@date.year}"
    print year_title + "\n"
    4.times do |r|
      title_line = ""
      3.times do |i|
        title_line += ("        " + @calendar[r][i].date.month.to_s + "月" + "           ").chars.slice(0..20).join
      end
      print title_line + "\n"

      wday_line = ""
      3.times do |i|
        wday_line += @calendar[r][i].wday.join
      end
      print wday_line + "\n"
    
      6.times do |row|  # カレンダーの日数部分は６行
        date_line = ""
        3.times do |i|
          date_line += @calendar[r][i].calendar[row].join + "  "
        end
        print date_line + "\n"
      end
    end
  end

  private

  def create_calendar
    month = 1
    4.times do |i| # １２ヶ月分のカレンダーを作成
      3.times do |j|
        date = (month == @date.month) ? @date : GetDate.new(Date.new(@date.year, month, 1))
        @calendar[i][j] = CalOneMonth.new(date)
        month += 1
      end
    end
  end
end

class ThreeMonthsCalendar
  def initialize(date)
    @date = date
    @calendar = Array.new(3)
    create_calendar
  end
  
  def print_calendar
    title_line =  @calendar[0].title +
                  @calendar[1].title +
                  @calendar[2].title
    print title_line + "\n"
    wday_line = ""
    3.times do |i|
      wday_line += @calendar[i].wday.join
    end

    print wday_line + "\n"
      6.times do |row|  # カレンダーの日数部分は６行
      date_line = ""
      3.times do |i|
        date_line += @calendar[i].calendar[row].join + "  "
      end
      print date_line + "\n"
    end
  end

  private

  def create_calendar
    date = @date.today.prev_month  # 基点の日付(前月)を計算
    @date.year = date.year
    @date.month = date.month
   
    3.times do |i| # ３ヶ月分のカレンダーを作成
      @calendar[i] = CalOneMonth.new(@date)
      date = date.next_month # 基点の日付を更新(次月を計算)
      @date.year = date.year
      @date.month = date.month
    end
  end
end

class CalOneMonth
  attr_reader :title, :wday, :month, :calendar, :date
  def initialize(date)
    @date = date
    @title = ("      #{@date.month.to_s}月 #{@date.year}        ").chars.slice(0..20).join
    @wday = ["日 ", "月 ", "火 ", "水 ", "木 ", "金 ", "土  "]
    @calendar = [["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],] # 日数の雛形(この雛形に当月の日数を埋めていく)
    create_calendar
  end

  def print_calendar
    print @title + "\n"
    print @wday.join + "\n"    
    rows = @calendar.size
    rows.times do |row|  # カレンダー：日数部分
      print @calendar[row].join + "  \n"
    end
  end
  
  private

  def create_calendar
    days = Date.new(@date.year, @date.month, -1).day # 当月の日数を取得
    week = 0
    1.step(days,1) do |day|
      date = Date.new(@date.year,@date.month,day)
      col = date.wday
      if date.sunday? # インデント数の調整(日曜日のみ１つ少ない)
        n = -2
      else
        n = -3
      end

      if HIGH_LIGHT_DAY == date && @date.h == true # 当月の日数を変数calenderの適切な座標に埋め込む
        day = (" " + day.to_s).slice(-2..-1)  # １桁の数字は直前の空白も含んでハイライトを付ける / 擬似的に２桁にする
        day = "\e[47;30m" + day + "\e[0m"  # 背景色：白, 文字色：黒のカラーコードで日にちを挟む
        n -= 12  # ANSIカラーコードの分だけスライスする数を増やす
      end
      @calendar[week][col] = (@calendar[week][col] + day.to_s).chars.slice(n..-1).join  # 日にちを適切な座標に埋め込み
      week += 1 if col == 6  # 金曜日(行末)まで到達したら週(行)を更新...()内は配列表現
    end
  end
end

class Options
  def initialize
    @options = {}
    OptionParser.new do |opt|      
      opt.on('-y [value]', '--year [value]') do |v|
        if v.nil?  # オプションのみで引数が与えられなかった場合
          @options[:y] = nil
        elsif (v =~ /\A[0-9]+\z/) == 0  # 引数が数字でのみで構成させているかチェック
          @options[:y] = v.to_i  # 数値に変換
        else  # エラー処理
          print "cal: not a valid year #{v}\n"
          exit
        end
      end 

      opt.on('-m [value]', '--month [value]') do |value|
        if value.nil?
          print "cal: option requires an argument -- 'm'\n"
          exit
        end
        v = value.to_i  # 数値に変換
        if 1 <= v && v <= 12
          @options[:m] = v
        else
          print "cal: #{value} is neither a month number (1..12) nor a name\n"
          exit
        end
      end
      opt.on('-h') { |v| @options[:h] = true  }
      opt.on('-1') { |v| @options[:one] = true  }
      opt.on('-3') { |v| @options[:three] = true  }
      begin
       opt.parse!(ARGV)
      rescue => e
        print "cal: invalid option -- '#{e.message.gsub(/.+: -/,'')}'\n"
        exit
      end

      if self.has?(:y) && self.has?(:m)  # cal -y year -m month において、片方の引数が与えられていない場合はエラーとして終了
        case
        when self.get(:y).nil? == true
          print "cal: option requires an argument -- 'y'\n"
          exit
        when self.get(:m).nil? == true
          print "cal: option requires an argument -- 'm'\n"
          exit
        end
      end
    end
  end

  def has?(name)
    @options.include?(name)
  end

  def get(name)
    @options[name]
  end
end

class Arguments
  def initialize
    @args = {}
    if ARGV.size >= 3  # 引数３つ以上で処理の終了(引数異常)
      exit
    elsif ARGV.size == 2  # 引数２つで月・年に代入
      @args[:m] = check_month(ARGV[0])
      @args[:y] = ARGV[1].to_i
    elsif ARGV.size == 1  # 引数１つで年に代入
      @args[:y] = ARGV[0].to_i
    end
  end

  def check_month(v)
    m = v.to_i  # 仮に文字が渡されていればココで０になる
    if 1 <= m && m <= 12
      m
    else
      print "cal: #{v} is neither a month number (1..12) nor a name\n"
      exit
    end
  end

  def has?(name)
    @args.include?(name)
  end

  def get(name)
    @args[name]
  end
end

class GetDate
  attr_reader :today, :year, :month, :h
  attr_writer :year, :month, :h
  def initialize(today)
    @today = today
    @year = @today.year
    @month = @today.month
    @h = true  # ハイライトの有無 デフォルトでハイライト有効
  end
end

HIGH_LIGHT_DAY = Date.today

date = GetDate.new(Date.today)
options = Options.new
args = Arguments.new

case  # オプションによるコマンドの分岐
when options.has?(:y) == true && options.has?(:m) == true  # cal -y [year] -m [month]
  date.year = options.get(:y)
  date.month = options.get(:m)
  cal = CalOneMonth.new(date)
when options.has?(:y) == true  # cal -y / cal -y [year]
  date.year = options.get(:y) unless options.get(:y).nil?  # 引数有りならyearに代入
  cal = OneYearCalendar.new(date)
when options.has?(:m) == true  # cal -m [month]
  date.month = options.get(:m)
  cal = CalOneMonth.new(date)
when options.has?(:h) == true  # cal -h
  date.h = false
  cal = CalOneMonth.new(date)
when options.has?(:one) == true  # cal -1
  cal = OneYearCalendar.new(date)
when options.has?(:three) == true  # cal -3 
  cal = ThreeMonthsCalendar.new(date)
when args.has?(:m) == true  # cal [month] [year] 引数に月の値が存在すれば年・月が指定された事を意味する
  date.year = args.get(:y)  # 引数から年を取得
  date.month = args.get(:m)  # 引数から月を取得
  cal = CalOneMonth.new(date)
when args.has?(:y) == true  # cal [year]
  date.year = args.get(:y)  # 引数から年を取得
  cal = OneYearCalendar.new(date)
else  # cal
  cal = CalOneMonth.new(date)
end

cal.print_calendar
