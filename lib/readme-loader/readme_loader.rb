require 'faraday'
require 'nokogiri'
require 'yaml'
require 'logger'
require 'pry'

class ReadmeLoader
  def initialize
    @logger = Logger.new(File.expand_path("../../../log/readme_loader-#{Time.now.strftime('%Y%m%d%H%M%S')}.log", __FILE__))
  end

  def run
    @con = connection
    @con_raw = connection_for_raw
    @repos = repositories

    @repos.each do |repo|
      puts "[repo: #{repo[:name]}] processing"
      page = load_page(repo[:path])

      continue if page.nil?

      file_name = pluck_readme_file_name(page)
      raw = load_raw("#{repo[:path]}/master/#{file_name}")

      continue if raw.nil?

      dump(repo[:name], raw)
      puts "[repo: #{repo[:name]}] completed"
      sleep(1)
    end
  end

  private

  def repositories
    yaml = YAML.load_file(File.expand_path('../../../out/repositories.yaml', __FILE__))
    yaml[:repositories]
  end

  def connection
    Faraday.new(:url => 'https://github.com') do |builder|
      builder.request  :url_encoded
      # builder.response :logger
      builder.adapter  :net_http
    end
  end

  def connection_for_raw
    Faraday.new(:url => 'https://raw.githubusercontent.com') do |builder|
      builder.request  :url_encoded
      # builder.response :logger
      builder.adapter  :net_http
    end
  end

  def request(req)
    retry_limit = 5
    req_count = 0
    res = nil

    loop do
      req_count += 1
      res = req.call
      break if res.status == 200 || retry_limit <= req_count
      sleep(5)
    end

    res.status == 200 ? res.body : nil
  end

  def load_page(path)
    body = request(lambda { @con.get path })

    if body.nil?
      @logger.error "Loading page error. path=#{path}"
    end

    body
  end

  def load_raw(path)
    body = request(lambda { @con_raw.get path })

    if body.nil?
      @logger.error "Loading raw page error. path=#{path}"
    end

    body
  end

  def pluck_readme_file_name(body)
    doc = Nokogiri::HTML.parse(body)
    doc.css('#readme > h3').inner_text.strip
  end

  def dump(repo_name, body)
    file_name = repo_name.gsub('/', '_')
    File.open(File.expand_path("../../../out/readmes/#{file_name}.md", __FILE__), 'w') do |f|
      f.puts(body)
    end
  end
end

ReadmeLoader.new.run