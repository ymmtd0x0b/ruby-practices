# frozen_string_literal: true

module FileLoader
  def self.load_files(dot_match: false, reverse: false)
    files = dot_match ? Dir.entries('.') : Dir.glob('*')
    reverse ? files.sort.reverse : files.sort
  end
end
