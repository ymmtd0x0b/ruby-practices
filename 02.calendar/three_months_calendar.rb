# frozen_string_literal: true

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
