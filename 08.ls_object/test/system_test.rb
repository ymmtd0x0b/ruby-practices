# frozen_string_literal: true

require 'test/unit'
require_relative '../ls_short'
require_relative '../ls_long'

class TestLsShort < Test::Unit::TestCase
  test 'short_ls' do
    expected = <<~TEXT.chomp
      Desktop    Public          fjord
      Documents  Templates       snap
      Downloads  Videos          work
      Music      VirtualBox VMs
      Pictures   bin
    TEXT
    params = { dot_match: false, reverse: false }
    assert_equal expected, LsShort.new(**params).run
  end
end

class TestLsLong < Test::Unit::TestCase
  test 'long_ls' do
    expected = `ls -l #{Dir.home}`.chomp
    params = { dot_match: false, reverse: false }
    assert_equal expected, LsLong.new(**params).run
  end
end
