# frozen_string_literal: true

class ThreeMonthsCalendar
  ONE_MONTH_WIDTH = 20
  def initialize(date)
    three_months = months(date)
    @months_title = formatte_month_title(three_months)
    @wdays = formatte_wdays(three_months)
    @dates = formatte_dates(three_months)
  end

  def print
    puts @months_title
    puts @wdays
    puts @dates
  end

  def delete_year_from_months_title
    @months_title = @months_title.scan(/[0-9]+月/).map { |month| month.center(ONE_MONTH_WIDTH) }.join(' ')
    self
  end

  private

  def formatte_month_title(three_months)
    three_months.map(&:month_title).join(' ')
  end

  def formatte_wdays(three_months)
    three_months.map(&:wdays).join(' ')
  end

  def formatte_dates(three_months)
    (0..5).map do |week|
      three_months.map { |month| month.dates[week] }.join('  ')
    end.join("\n")
  end

  def months(date)
    base_date = Date.new(date.year, date.month, 1)
    (0..2).map do |n|
      date = base_date.next_month(n)
      OneMonthCalendar.new(date.year, date.month)
    end
  end
end
