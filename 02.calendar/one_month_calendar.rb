# frozen_string_literal: true

class OneMonthCalendar
  attr_reader :month_title, :wdays, :dates

  DATE_CELL_WIDTH = 3
  LINE_WIDTH = 20
  WDAYS = %w[日 月 火 水 木 金 土].freeze
  def initialize(year, month, highlight: true)
    @month_title = ("#{month}月 #{year}").center(LINE_WIDTH)
    @wdays = "#{WDAYS.join(' ')} "
    @dates = create_dates(year, month, highlight)
  end

  def print
    puts @month_title
    puts @wdays
    puts @dates
  end

  private

  def formatted_day_for_table(date, highlight)
    day = (date.day / 10).zero? ? date.day.to_s.rjust(2, ' ') : date.day.to_s # １桁の場合はスペースもハイライトの対象にする
    if date == Date.today && highlight # コマンド実行日と同じならハイライトにする
      " \e[47;30m#{day}\e[0m"
    else
      day.rjust(DATE_CELL_WIDTH, ' ')
    end
  end

  def formatted_blank_space_for_table
    ' ' * DATE_CELL_WIDTH
  end

  def create_dates(year, month, highlight)
    current_date = Date.new(year, month, 1)
    Array.new(6, '').map do |week| # 1 month == 6 weeks
      (0..6).each do |wday| # 1 week == 7 days (0~6,0:Sunday)
        if wday == current_date.wday && month == current_date.month
          week += formatted_day_for_table(current_date, highlight)
          current_date = current_date.next_day
        else
          week += formatted_blank_space_for_table
        end
      end
      week.slice(1..) # calコマンドの出力表示に合わせるために先頭の空白を削除
    end
  end
end
