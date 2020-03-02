class ScraperService
  require 'httparty'
  require 'nokogiri'
  require 'open-uri'

  class << self
    def scrap_job
      begin
        #designation = User.find_by(id: id).job_search.designation.gsub(" ","-")
        #location= User.find_by(id: id).job_search.location
        #puts ">>>>>>>>>>>>>>>location: #{location}"
        # if location.present?
        #   puts ">>>>>>>>>>>>>>>location present"
        #   parse_page = Nokogiri::HTML(open("https://www.karriere.at/jobs/#{designation}/#{location}"))
        # else
        #   puts ">>>>>>>>>>>>>>>location not present"
        #   parse_page = Nokogiri::HTML(open("https://www.karriere.at/jobs/project-manager/wien"))
        # end
        parse_page = Nokogiri::HTML(open("https://www.karriere.at/jobs/"))
        jobs = Array.new

        datas =  parse_page.css('div.m-jobsListItem__dataContainer')
        if parse_page.css('div.m-jobsListItem__dataContainer').present?
          page = 1
          per_page = datas.count
          total = parse_page.css('div.m-pagination').css('div.m-pagination__inner').css('span.m-pagination__meta').text.split(' ')[2].to_i * per_page

          last_page = (total.to_f / per_page.to_f).round

          while page <= last_page
            pagination_url = page > 1 ? "https://www.karriere.at/jobs?page=#{page}" : "https://www.karriere.at/jobs/"
            pagination_parse_page = Nokogiri::HTML(open(pagination_url))
            pagination_datas =  pagination_parse_page.css('div.m-jobsListItem__dataContainer')
            pagination_datas.each do |data|
              url = data.css('h2.m-jobsListItem__title').css('a')[0].attributes['href'].value
              job_url = HTTParty.get(url)
              job_hash = {
                        title: data.css('h2.m-jobsListItem__title').text.strip,
                        company: data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__company').text.strip,
                        url: data.css('h2.m-jobsListItem__title').css('a')[0].attributes['href'].value.strip,
                        location:  (data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__wrap').css('ul.m-jobsListItem__locations').css('li.m-jobsListItem__location').css('a')[0].attributes['data-location'].value.strip.downcase rescue nil),
                        date: data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__wrap').css('span.m-jobsListItem__date')[0].text.gsub("am","").strip,
                        content: data.css('p.m-jobsListItem__snippet').text.strip,
                        job_search_type: 1,
                        }
              puts ">>>>>>>>>>>>> #{job_hash}"
              job_hash = job_already_present job_hash
              jobs << job_hash if job_hash
            end
            page += 1
            puts ">>>>>>>>>>>>>>>>  #{page}"
          end
        end
        parsed_job = jobs.map do |attrs|
          TempJob.new(attrs)
        end
        TempJob.import(parsed_job)
        User.all.each do |u|

          #relevent_jobs = TempJob.where(location: u.job_search.location)
          relevent_jobs = TempJob.where(location: u.job_search.location).select{|x| x.title.downcase.include?(u.job_search.designation)}
          relevent_jobs.each do |rj|
            u.jobs.create(title: rj.title, company: rj.company, url: rj.url, location: rj.location, date: rj.date, content: rj.content, user_id: u.id, job_search_type: 1)
          end
        end
        #Job.import(parsed_job)
      rescue Exception
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
