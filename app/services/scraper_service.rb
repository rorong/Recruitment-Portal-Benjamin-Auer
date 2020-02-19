class ScraperService
  require 'httparty'
  require 'nokogiri'
  require 'open-uri'

  class << self
    def scrap_job(designation,location)
      begin
        parse_page = Nokogiri::HTML(open("https://www.karriere.at/jobs/#{designation}/#{location}"))
        jobs = Array.new
        datas =  parse_page.css('div.m-jobsListItem__dataContainer') #jobs
        page = 1
        per_page = datas.count
        total = parse_page.css('div.m-pagination').css('div.m-pagination__inner').css('span.m-pagination__meta').text.split(' ')[2].to_i * per_page
        last_page = (total.to_f / per_page.to_f).round
        while page <= last_page
          pagination_url = page > 1 ? "https://www.karriere.at/jobs/#{designation}/#{location}?page=#{page}" : "https://www.karriere.at/jobs/#{designation}/#{location}"
          # pagination_doc = HTTParty.get(pagination_url)
          pagination_parse_page = Nokogiri::HTML(open(pagination_url))

          # pagination_parse_page ||= Nokogiri::HTML(pagination_doc)
          pagination_datas =  pagination_parse_page.css('div.m-jobsListItem__dataContainer')
          pagination_datas.each do |data|
            url = data.css('h2.m-jobsListItem__title').css('a')[0].attributes['href'].value
            job_url = HTTParty.get(url)
            parse_job_url ||= Nokogiri::HTML(job_url)
            job_content = parse_job_url.css('div.l-master__content').css('div.c-jobDetail').css('div.m-jobDetailContent').css('div.m-jobDetailContent__inner').css('div.m-jobContent').css('div.m-jobContent__jobDetail').text
            job_hash = {
                      title: data.css('h2.m-jobsListItem__title').text.strip,
                      company: data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__company').text.strip,
                      url: data.css('h2.m-jobsListItem__title').css('a')[0].attributes['href'].value.strip,
                      location:  (data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__wrap').css('ul.m-jobsListItem__locations').css('li.m-jobsListItem__location').css('a')[0].attributes['data-location'].value.strip rescue nil),
                      date: data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__wrap').css('span.m-jobsListItem__date')[0].text.gsub("am","").strip,
                      content: job_content.strip
                    }
            job_hash = job_already_present job_hash
            jobs << job_hash if job_hash
          end
          page += 1
        end
        parsed_job = jobs.map do |attrs|
          Job.new(attrs)
        end
        Job.import(parsed_job)
        if parsed_job.present?
          User.all.each do |user|
            JobMailer.job_email(user, parsed_job).deliver_now
          end
        end
      rescue Exception
        sleep(2)
        retry
      end
    end

    def job_already_present job_hash
      result = Job.pluck(:url).include? job_hash[:url]
      if result
        false
      else
        job_hash
      end
    end
  end
end
