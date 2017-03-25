require 'yaml'
require 'pry'
require 'benchmark'

class WordCounter
  def run
    paths = file_paths
    words = []

    paths.each do |path|
      puts "[path: #{path}] processiong"
      text = read(path)
      words.concat(extract_words(text))
      puts "[path: #{path}] completed"
    end

    result = count_words(words)
    dump(result)
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

  def is_rejection?(word)
    return true if word.empty?
    return true if word.match(/^[=\/a-z]$/)
    return true if word.match(/^\d+$/)
    return true if word.match(/https?:\/\//)
    return true if word.match(/[|│├└]/)
    return true if word.match(/\p{Hiragana}/)
    return true if word.match(/\p{Katakana}/)
    return true if word.match(/[一-龠々]/)
    return true if word.match(/.+[.=&<>(){}\/"'@;].+/)
    return true if word.start_with?('<', '{', '[', '`', '+', '-', '_', '@')
    return true if word.end_with?('>', '}', ']', '`')
    false
  end

  def clean(word)
    word = word.gsub(/^[("':;\-&%#]+/, '')
    word = word.gsub(/[.,!?)"':;\-&%#]+$/, '')
    word.downcase
  end

  def count_words(words)
    uniq_words = words.uniq
    result = {}

    uniq_words.each do |target|
      puts "[count: #{target}] processing"
      time = Benchmark.realtime do
        count = 0
        words.each { |w| count += 1 if w == target }
        words.delete(target)
        result[target] = count
      end
      puts "[count: #{target}] completed #{time}s"
    end

    Hash[ result.sort_by { |(_, v)| -v } ]
  end

  def dump(result)
    YAML.dump(result, File.open(File.expand_path('../../../out/result.yaml', __FILE__), 'w'))
  end
end

WordCounter.new.run