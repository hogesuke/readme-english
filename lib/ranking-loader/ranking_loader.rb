require 'faraday'
require 'nokogiri'
require 'yaml'
require 'pry'

class RankingLoader
  def run(max_ranking)
    @con = connection
    @repos = []

    per = 10  # 10 repositories in a page
    max_page = (max_ranking / per) + (max_ranking % per > 0 ? 1 : 0)

    max_page.times do |i|
      puts "[page: #{i + 1}] processing"
      body  = load_ranking_page(i + 1)
      @repos.concat(pluck_repos(body))
      puts "[page: #{i + 1}] completed"
      sleep(5)
    end

    dump
  end

  private

  def connection
    Faraday.new(:url => 'https://github.com') do |builder|
      builder.request  :url_encoded
      # builder.response :logger
      builder.adapter  :net_http
    end
  end

  def load_ranking_page(page_num)
    retry_limit = 5
    req_count = 0
    res = nil

    loop do
      req_count += 1
      res = @con.get '/search', { p: page_num, q: 'stars:>1', s: 'stars', type: 'Repositories' }
      puts "status = #{res.status}"
      break if res.status == 200 || retry_limit <= req_count
      sleep(5)
    end

    res.body
  end

  def pluck_repos(body)
    repos = []

    doc = Nokogiri::HTML.parse(body)
    puts "counts = #{doc.css('a.v-align-middle').size}"
    doc.css('a.v-align-middle').each do |node|
      repos << { name: node.inner_text, path: node.attribute('href').value }
    end

    repos
  end

  def dump
    file = File.open(File.expand_path('../../../out/repositories.yaml', __FILE__), 'w')
    YAML.dump({ repositories: @repos }, file)
    file.close
  end
end
