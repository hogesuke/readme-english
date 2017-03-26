require_relative '../lib/ranking-loader/ranking_loader'
require_relative '../lib/readme-loader/readme_loader'
require_relative '../lib/md-to-plain-converter/md_to_plain_converter'
require_relative '../lib/word-counter/word_counter'

if ARGV.size < 1 || ARGV[0] !~ /^\d+$/
  puts "Please specify the number of repositories."
  exit(1)
end


puts "=============== RankingLoader ==============="
RankingLoader.new.run(ARGV[0].to_i)
puts "=============== ReadmeLoader ==============="
ReadmeLoader.new.run
puts "=============== MdToPlainConverter ==============="
MdToPlainConverter.new.run
puts "=============== WordCounter ==============="
WordCounter.new.run
puts "=============== Completed! ==============="
