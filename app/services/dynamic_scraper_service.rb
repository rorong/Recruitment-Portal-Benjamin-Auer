class DynamicScraperService
  require 'nokogiri'
  require 'httparty'
  require 'webdrivers'
  require 'watir'
  require 'net/http'
  require 'date'

  class << self
    def dynamic_scrap(user_ids)
      begin
        if user_ids.present?
          user_ids.each do |id|
              designation = User.find_by(id: id).job_search.designation
              location = User.find_by(id: id).job_search.location
              jobs = Array.new
              browser = Watir::Browser.new :chrome
              browser.goto('https://jobs.derstandard.at/jobsuche')
              browser.text_field(:id => "jobSearchListInput").set designation
              browser.text_field(:id => "regionSearchListInput").set location
              browser.button(:value => 'Jobs suchen').click
              sleep 5
              parse_page ||= Nokogiri::HTML(browser.html)
              datas = parse_page.css('#resultWithPagingSection>ul>li').search('.resultListItemContent')
              page = 1
              per_page = datas.count
              total = parse_page.css('#jobSearchMenuSection').css('.page-list-count').text.split(' ')[2].to_i * per_page
              last_page = (total.to_f / per_page.to_f).round
              while page <= last_page
              pagination_url = "https://jobs.derstandard.at/jobsuche/#{page}"
              browser.goto(pagination_url)

              browser.text_field(:id => "jobSearchListInput").set designation
              browser.text_field(:id => "regionSearchListInput").set location
              browser.button(:value => 'Jobs suchen').click
              pagination_url = "https://jobs.derstandard.at/jobsuche/#{page}"
              browser.goto(pagination_url)

              pagination_parse_page = Nokogiri::HTML(browser.html)
              pagination_datas = pagination_parse_page.css('#resultWithPagingSection>ul>li').search('.resultListItemContent')
              pagination_datas.each do |data|
                if data.children.css('a').present? && data.attributes['title'].present?
                url = "jobs.derstandard.at"+ data.children.css('a')[0].attributes['href'].value
                get_date = find_date(data.attributes['title'].value.gsub('|',',').gsub(',',',').split(','))

                job_hash = {
                            title: data.attributes['title'].value.gsub('|',',').gsub(',',',').split(',').first.strip,
                            url: url,
                            location: data.css('span.jobadress').text,
                            company: data.css('span.company').text,
                            date: get_date,
                            content: data.css('p')[0].attributes['title'].value,
                            job_search_type: 0,
                            user_id: id
                           }

                job_hash = job_already_present job_hash
                jobs << job_hash if job_hash
              end
            end
              page += 1
          end
            parsed_job = jobs.map do |attrs|
              Job.new(attrs)
          end

            job_ids = Job.import(parsed_job)

           # if all_job.present?
           #   User.all.each do |user|
           #     JobMailer.job_email(user, all_job).deliver_now
           #    end
           # end
           rescue Exception => e
            puts e
        end
      end
    end
  end

    def job_already_present job_hash
      result = Job.pluck(:url).include?(job_hash[:url]) && Job.pluck(:user_id).include?(job_hash[:user_id])
      if result
        false
      else
        job_hash
      end
    end

    def find_date get_date
      d, m, y = get_date[3].strip.split '.' if get_date[3]
      d1, m1, y1 = get_date[4].split '.' if get_date[4]
      if(Date.valid_date? y.to_i, m.to_i, d.to_i)
        date = get_date[3].strip
      elsif (Date.valid_date? y1.to_i, m1.to_i, d1.to_i)
        date = get_date[4].strip
      else
        date = get_date.last.strip
      end
        date
    end
  end
end
