# frozen_string_literal: true

require 'date'
require 'optparse'

class OneYearCalendar
  YEAR_LINE_WIDTH = 63
  def initialize(year)
    @year = year
    @one_year_calendar = create_one_year_calendar(year)
  end

  def create_year_line
    "#{@year.to_s.center(YEAR_LINE_WIDTH)}\n"
  end

  def create_months_line(three_months)
    months = three_months.three_months_calendar.map do |month|
      month.month_title.sub(/ *([0-9]+月).*/, '\1').center(OneMonthCalendar::LINE_WIDTH)
    end
    "#{months.join(' ')}\n"
  end

  def print_calendar
    print create_year_line
    @one_year_calendar.map do |three_months|
      print create_months_line(three_months)
      print three_months.create_wdays_line
      print three_months.create_dates_lines
    end
  end

  private

  def create_one_year_calendar(year)
    january = Date.new(year, 1, 1)
    (0..3).map do |n|
      date = january.next_month(n * 3)
      ThreeMonthsCalendar.new(date.year, date.month)
    end
  end
end

class ThreeMonthsCalendar
  attr_reader :three_months_calendar

  def initialize(year, month)
    @three_months_calendar = create_three_months_calendar(year, month)
  end

  def create_months_title
    "#{@three_months_calendar.map(&:monthonth_title).join(' ')}\n"
  end

  def create_wdays_line
    "#{Array.new(3) { OneMonthCalendar::WDAYS.join(' ') }.join('  ')}\n"
  end

  def create_dates_lines
    dates =
      (0..5).map do |week|
        one_week_line = @three_months_calendar.map { |current_month| current_month.dates_table[week] }
        "#{one_week_line.join('  ')}\n"
      end
    dates.join
  end

  def print_calendar
    print create_months_title
    print create_wdays_line
    print create_dates_lines
  end

  private

  def create_three_months_calendar(year, month)
    base_date = Date.new(year, month, 1)
    (0..2).map do |n|
      date = base_date.next_month(n)
      OneMonthCalendar.new(date.year, date.month)
    end
  end
end

class OneMonthCalendar
  attr_reader :month_title, :wdays, :dates_table

  DATE_CELL_WIDTH = 3
  LINE_WIDTH = 20
  WDAYS = %w[日 月 火 水 木 金 土].freeze
  def initialize(year, month)
    @month_title = create_month_title(year, month)
    @wdays = WDAYS.join(' ')
    @dates_table = create_dates_table(year, month)
  end

  def print_calendar
    puts @month_title
    puts @wdays
    print @dates_table.join("\n")
  end

  def create_formatted_day(date)
    day = (date.day / 10).zero? ? date.day.to_s.rjust(2, ' ') : date.day.to_s # １桁の場合はスペースもハイライトの対象にする
    if date == Date.today
      " \e[47;30m#{day}\e[0m"
    else
      day.rjust(DATE_CELL_WIDTH, ' ')
    end
  end

  def create_formatted_blank_space
    (' ' * DATE_CELL_WIDTH)
  end

  def off_highlight
    @dates_table.map! do |one_week|
      if one_week.inspect.include?('\e[47;30m')
        one_week.inspect.gsub(/"(.*)\\e\[47;30m(..)\\e\[0m(.*)"/, '\1\2\3')
      else
        one_week
      end
    end
    self
  end

  private

  def create_month_title(year, month)
    ("#{month}月 #{year}").center(LINE_WIDTH)
  end

  def create_dates_table(year, month)
    date = Date.new(year, month, 1)
    Array.new(6, '').map do |week| # 1 month == 6 weeks
      (0..6).each do |wday| # 1 week == 6 days (0~6,0:Sunday)
        if wday == date.wday && month == date.month
          week += create_formatted_day(date)
          date = date.next_day
        else
          week += create_formatted_blank_space
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
      opt.on('-1') { @options[:one_month] = true }
      opt.on('-3') { @options[:three_months] = true }
      begin
        opt.parse!(ARGV)
      rescue StandardError => e
        print "cal: invalid option -- '#{e.message.gsub(/.+: -/, '')}'\n"
        exit
      end
      check_argument_only
      check_option_value
    end
  end

  def has?(name)
    @options.include?(name)
  end

  def get_value(name)
    @options[name]
  end

  private

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

  def check_argument_only
    return unless ARGV[0] =~ /\A[0-9]+\z/ || ARGV[1] =~ /\A[0-9]+\z/

    case ARGV.size
    when 2 # 引数２つで月・年に代入
      @options[:month] = ARGV[0]
      @options[:year] = ARGV[1]
    when 1 # 引数１つで年に代入
      @options[:year] = ARGV[0]
    end
  end
end

option = CalendarOption.new
today = Date.today

cal =
  case option.options.keys.join(',')
  when 'year'
    OneYearCalendar.new(option.get_value(:year))
  when 'month'
    OneMonthCalendar.new(today.year, option.get_value(:month))
  when 'year,month', 'month,year'
    OneMonthCalendar.new(option.get_value(:year), option.get_value(:month))
  when '1'
    OneYearCalendar.new(today.year)
  when '3'
    ThreeMonthsCalendar.new(today.year, today.month)
  when 'off_highlight'
    OneMonthCalendar.new(today.year, today.month).off_highlight
  when ''
    OneMonthCalendar.new(today.year, today.month)
  else
    exit
  end

cal.print_calendar
