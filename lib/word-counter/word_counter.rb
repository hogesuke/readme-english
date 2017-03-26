require 'yaml'
require 'pry'
require 'benchmark'

class WordCounter
  def initialize
    @counts = {}
  end

  def run
    paths = file_paths

    paths.each do |path|
      puts "[path: #{path}] processiong"

      text  = read(path)
      words = extract_words(text)
      count_words(words)

      puts "[path: #{path}] completed"
    end

    sort
    dump
  end

  private

  def file_paths
    Dir.glob(File.expand_path('../../../out/plain-texts/*.text', __FILE__))
  end

  def read(path)
    File.open(path, 'r') { |f| f.read }
  end

  def extract_words(text)
    words = text.split(/[\n\s]/)

    clean_words = []
    words.each do |w|
      next if is_rejection?(w)

      w = clean(w)
      clean_words << w unless w.empty? || is_rejection?(w)
    end

    clean_words
  end

  def count_words(words)
    words.each do |w|
      if @counts.has_key?(w)
        @counts[w] += 1
      else
        @counts[w] = 1
      end
    end
  end

  def is_rejection?(word)
    return true if word.empty?
    return true if word.match(/^[\d.,-]+$/)
    return true if word.match(/https?:\/\//)
    return true if word.match(/[|│├└=\/\\]/)
    return true if word.match(/\p{Hiragana}/)
    return true if word.match(/\p{Katakana}/)
    return true if word.match(/[一-龠々]/)
    return true if word.match(/.+[.&<>(){}"'*@\$:;~].+/)
    return true if word.start_with?('<', '{', '[', '`', '+', '-', '_', '@')
    return true if word.end_with?('>', '}', ']', '`')
    false
  end

  def clean(word)
    word = word.gsub(/^[.("':;\-~*&%#\$]+/, '')
    word = word.gsub(/[.,!?)"':;\-~*&%#\$]+$/, '')
    word.downcase
  end

  def sort
    @counts = Hash[ @counts.sort_by { |(_, v)| -v } ]
  end

  def dump
    file = File.open(File.expand_path('../../../out/result.yaml', __FILE__), 'w')
    YAML.dump(@counts, file)
    file.close
  end
end
