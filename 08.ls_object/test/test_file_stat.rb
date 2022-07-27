# frozen_string_literal: true

require 'test/unit'
require_relative '../lib/file/file_stat'

class FileStatTest < Test::Unit::TestCase
  def test_format_stat
    # Example Output
    # -rw-rw-r-- 1 ymmtd0x0b ymmtd0x0b 304  7月 18 00:04 exec_ls.rb
    file_stat = FileStat.new('exec_ls.rb')
    assert_equal `ls -l exec_ls.rb`.chomp, file_stat.format_stat({ nlink: 1, user: 9, group: 9, size: 3 })
  end
end
