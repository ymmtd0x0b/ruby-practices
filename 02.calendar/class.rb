# frozen_string_literal: true

class OneYearCalendar
  YEAR_LINE_WIDTH = 63
  def initialize(year)
    @data = {
      year_title: Date.today.year.to_s.center(YEAR_LINE_WIDTH),
      twelve_months: create(year)
    }
  end

  def print
    puts @data[:year_title]
    @data[:twelve_months].each(&:print)
  end

  private

  def create(year)
    january = Date.new(year, 1, 1)
    (0..3).map do |n|
      date = january.next_month(n * 3)
      ThreeMonthsCalendar.new(date).delete_year_from_months_title
    end
  end
end

class ThreeMonthsCalendar
  attr_reader :data

  ONE_MONTH_WIDTH = 20
  def initialize(date)
    three_months = create(date)
    @data = {
      months_title: formatte_month_title_and_wdays(three_months, :month_title),
      wdays: formatte_month_title_and_wdays(three_months, :wdays),
      dates: formatte_dates(three_months)
    }
  end

  def print
    @data.each_value { |data| puts data }
  end

  def delete_year_from_months_title
    @data[:months_title] = @data[:months_title].scan(/[0-9]+月/).map { |month| month.center(ONE_MONTH_WIDTH) }.join(' ')
    self
  end

  private

  def formatte_month_title_and_wdays(three_months, target)
    three_months.map { |month| month.data[target] }.join(' ')
  end

  def formatte_dates(three_months)
    (0..5).map do |week|
      three_months.map { |month| month.data[:dates][week] }.join('  ')
    end.join("\n")
  end

  def create(date)
    base_date = Date.new(date.year, date.month, 1)
    (0..2).map do |n|
      date = base_date.next_month(n)
      OneMonthCalendar.new(date.year, date.month)
    end
  end
end

class OneMonthCalendar
  attr_reader :data

  DATE_CELL_WIDTH = 3
  LINE_WIDTH = 20
  WDAYS = %w[日 月 火 水 木 金 土].freeze
  def initialize(year, month)
    @data = {
      month_title: ("#{month}月 #{year}").center(LINE_WIDTH),
      wdays: "#{WDAYS.join(' ')} ",
      dates: create_dates(year, month)
    }
  end

  def off_highlight
    @data[:dates].map! do |one_week|
      if one_week.inspect.include?('\e[47;30m')
        one_week.inspect.gsub(/"(.*)\\e\[47;30m(..)\\e\[0m(.*)"/, '\1\2\3')
      else
        one_week
      end
    end
    self
  end

  def print
    @data.each_value { |data| puts data }
  end

  private

  def formatted_day_for_table(date)
    day = (date.day / 10).zero? ? date.day.to_s.rjust(2, ' ') : date.day.to_s # １桁の場合はスペースもハイライトの対象にする
    if date == Date.today # コマンド実行日と同じならハイライトにする
      " \e[47;30m#{day}\e[0m"
    else
      day.rjust(DATE_CELL_WIDTH, ' ')
    end
  end

  def formatted_blank_space_for_table
    ' ' * DATE_CELL_WIDTH
  end

  def create_dates(year, month)
    current_date = Date.new(year, month, 1)
    Array.new(6, '').map do |week| # 1 month == 6 weeks
      (0..6).each do |wday| # 1 week == 7 days (0~6,0:Sunday)
        if wday == current_date.wday && month == current_date.month
          week += formatted_day_for_table(current_date)
          current_date = current_date.next_day
        else
          week += formatted_blank_space_for_table
        end
      end
      week.slice(1..) # calコマンドの出力表示に合わせるために先頭の空白を削除
    end
  end
end

class CalendarOption
  attr_reader :options

  def initialize
    @options = {}
    OptionParser.new do |opt|
      opt.on('-y [value]', '--year [value]') { |value| @options[:year] = value }
      opt.on('-m [value]', '--month [value]') { |value| @options[:month] = value }
      opt.on('-h') { @options[:off_highlight] = true }
      opt.on('-1') { @options[:one_year] = true }
      opt.on('-3') { @options[:three_months] = true }
      begin
        opt.parse!(ARGV)
      rescue StandardError => e
        print "cal: invalid option -- '#{e.message.gsub(/.+: -/, '')}'\n"
        exit
      end
      check_argument
      check_option_value
    end
  end

  def get_value(name)
    @options[name]
  end

  private

  def has?(name)
    @options.include?(name)
  end

  def check_year_value
    value = get_value(:year)
    if value.nil?
      @options[:year] = Date.today.year
    elsif value.start_with?(/\A[0-9]+\z/)
      @options[:year] = value.to_i
    else # 引数が存在し、数字以外が含まれていればエラー
      print "cal: not a valid year #{@options[:year]}\n"
      exit
    end
  end

  def check_month_value
    value = get_value(:month)
    if value.nil?
      print "cal: option requires an argument -- 'm'\n"
      exit
    end

    num = value.to_i
    if (1..12).cover?(num)
      @options[:month] = num
    else
      print "cal: #{value} is neither a month number (1..12) nor a name\n"
      exit
    end
  end

  def check_year_and_month_with_value
    if has?(:month) && get_value(:year).nil? # cal -y year -m month において、片方の引数が与えられていない場合はエラーとして終了
      print "cal: option requires an argument -- 'y'\n"
      exit
    elsif has?(:year) && get_value(:month).nil?
      print "cal: option requires an argument -- 'm'\n"
      exit
    end
  end

  def check_option_value
    case @options.keys.join
    when 'year'
      check_year_value
    when 'month'
      check_month_value
    when 'yearmonth', 'monthyear'
      check_year_value
      check_month_value
      check_year_and_month_with_value
    end
  end

  def check_argument
    case ARGV.size
    when 2 # 引数２つで月・年の順で指定されたと見做す
      @options[:month] = ARGV[0]
      @options[:year] = ARGV[1]
    when 1 # 引数１つで年のみ指定されたと見做す
      @options[:year] = ARGV[0]
    end
  end
end
