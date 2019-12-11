require 'HTTParty'
require 'Nokogiri'
require active_record
require activerecord-import

# class Scraper

  # attr_accessor :parse_page

  def scraper
    doc = HTTParty.get("https://www.karriere.at/jobs")
    jobs = Array.new
    parse_page ||= Nokogiri::HTML(doc)
    datas =  parse_page.css('div.m-jobsListItem__dataContainer') #jobs
    page = 1
    per_page = datas.count
    total = parse_page.css('div.m-pagination').css('div.m-pagination__inner').css('span.m-pagination__meta').text.split(' ')[2].to_i * per_page
    last_page = (total.to_f / per_page.to_f).round
    while page <= last_page
      pagination_url = "https://www.karriere.at/jobs?page=#{page}"
      pagination_doc = HTTParty.get(pagination_url)
      pagination_parse_page ||= Nokogiri::HTML(pagination_doc)
      pagination_datas =  pagination_parse_page.css('div.m-jobsListItem__dataContainer')
      pagination_datas.each do |data|
        job_hash = {
                  job_title: data.css('h2.m-jobsListItem__title').text,
                  company: data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__company').text,
                  url: data.css('h2.m-jobsListItem__title').css('a')[0].attributes['href'].value,
                  location: data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__wrap').css('ul.m-jobsListItem__locations').css('li.m-jobsListItem__location').css('a')[0].attributes['data-location'].value,
                  date: data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__wrap').css('span.m-jobsListItem__date')[0].text,
                  content: data.css('p.m-jobsListItem__snippet').text
                }
        jobs << job_hash
      end
      page += 1
    end
  end
# end



