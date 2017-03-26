require 'redcarpet'
require 'redcarpet/render_strip'
require 'faraday'
require 'pry'

class MdToPlainConverter
  def initialize
    @converter = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
  end

  def run
    paths = file_paths

    paths.each do |path|
      puts "[path: #{path}] processing"

      plain_text = convert(read(path))
      file_name = File.basename(path, 'md')
      dump(file_name, plain_text)

      puts "[path: #{path}] completed"
    end
  end

  def file_paths
    Dir.glob(File.expand_path('../../../out/readmes/*.md', __FILE__))
  end

  def read(path)
    File.open(path, 'r') { |f| f.read }
  end

  def convert(md)
    @converter.render(md)
  end

  def dump(file_name, plain_text)
    File.open(File.expand_path("../../../out/plain-texts/#{file_name}text", __FILE__), 'w') do |f|
      f.puts(plain_text)
    end
  end
end
