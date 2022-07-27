# frozen_string_literal: true

module FileLoader
  def self.load_files(dot_match: false, reverse: false)
    files = dot_match ? Dir.entries('.').sort : Dir.glob('*').sort
    files = files.reverse if reverse

    files
  end
end
