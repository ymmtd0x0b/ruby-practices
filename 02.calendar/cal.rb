# frozen_string_literal: true

require 'date'
require 'optparse'
require_relative './class'

option = CalendarOption.new

cal =
  case option.options.keys.join(',')
  when 'year'
    OneYearCalendar.new(option.get_value(:year))
  when 'month'
    OneMonthCalendar.new(Date.today.year, option.get_value(:month))
  when 'year,month', 'month,year'
    OneMonthCalendar.new(option.get_value(:year), option.get_value(:month))
  when 'one_year'
    OneYearCalendar.new(Date.today.year)
  when 'three_months'
    prev_month = Date.today.prev_month
    ThreeMonthsCalendar.new(prev_month)
  when 'off_highlight'
    OneMonthCalendar.new(Date.today.year, Date.today.month).off_highlight
  when ''
    OneMonthCalendar.new(Date.today.year, Date.today.month)
  else
    exit
  end

cal.print
