class DynamicScraperService
  require 'nokogiri'
  require 'httparty'
  require 'webdrivers'
  require 'watir'
  require 'net/http'
  require 'date'


  def self.dynamic_scrap
    # begin
      jobs = Array.new
       browser = Watir::Browser.new :chrome
       browser.goto('https://jobs.derstandard.at/jobsuche')
       browser.text_field(:id => "jobSearchListInput").set "project manager"
       browser.text_field(:id => "regionSearchListInput").set "wien"
       browser.button(:value => 'Jobs suchen').click
       sleep 5
       parse_page ||= Nokogiri::HTML(browser.html)
       datas = parse_page.css('#resultWithPagingSection>ul>li').search('.resultListItemContent')
       page = 1
       per_page = datas.count
       total = parse_page.css('#jobSearchMenuSection').css('.page-list-count').text.split(' ')[2].to_i * per_page
       last_page = (total.to_f / per_page.to_f).round
       while page <= 2
         pagination_url = "https://jobs.derstandard.at/jobsuche/#{page}"
         browser.goto(pagination_url)
         pagination_parse_page ||= Nokogiri::HTML(browser.html)
         pagination_datas = pagination_parse_page.css('#resultWithPagingSection>ul>li').search('.resultListItemContent')
         pagination_datas.each do |data|
          url = "jobs.derstandard.at"+ data.children.css('a')[0].attributes['href'].value
          browser.goto(url)
          parse_job_url ||= Nokogiri::HTML(browser.html)
          # job_content =  find_job_description(parse_job_url, browser)
          # job_content = (parse_job_url.css('#content-main').css('.content').text.present? || parse_job_url.css('#job-eblinger').text.present?) ? (parse_job_url.css('#content-main').css('.content').text || parse_job_url.css('#job-eblinger').text) : parse_job_url.css('#content-main').css('.content-container-inserat').css('.js-embed-container').css('.js-embed-output').css('.jobAd').css('.companyDescription').text.strip
          job_content = if parse_job_url.css('#content-main').css('.content').text.present?
                          parse_job_url.css('#content-main').css('.content').text
                        elsif parse_job_url.css('#job-eblinger').text.present?
                          parse_job_url.css('#job-eblinger').text
                        elsif parse_job_url.css('#content-main').css('.content-container-inserat').css('.js-embed-container').css('.js-embed-output').css('.jobAd').css('.companyDescription').text.present?
                          parse_job_url.css('#content-main').css('.content-container-inserat').css('.js-embed-container').css('.js-embed-output').css('.jobAd').css('.companyDescription').text.strip
                        elsif parse_job_url.css('#content-main').css('.content-container-inserat').css('#job-eblinger').present?
                           parse_job_url.css('#content-main').css('.content-container-inserat').css('#job-eblinger').text
                        elsif parse_job_url.css('#content-main').css('.content-container-inserat').css('#job-eblinger').present?
                          parse_job_url.css('#content-main').css('.content-container-inserat').css('#job-eblinger').text
                        elsif parse_job_url.css('.jobAd').css('.jobAdContent').text.present?
                          parse_job_url.css('.jobAd').css('.jobAdContent').text
                        elsif parse_job_url.css('#jobad').css('.jobad-main-container').text.present?
                           parse_job_url.css('#jobad').css('.jobad-main-container').text
                        elsif parse_job_url.css('.inhalt').text.present?
                          parse_job_url.css('.inhalt').text
                        elsif browser.iframe(:id, "iframe1").text.present?
                          browser.iframe(:id, "iframe1").text
                        end
          get_date = find_date(data.attributes['title'].value.gsub('|',',').gsub(',',',').split(','))

          job_hash = {
                      title: data.attributes['title'].value.gsub('|',',').gsub(',',',').split(',').first.strip,
                      url: url,
                      company: data.attributes['title'].value.gsub('|',',').gsub(',',',').split(',').third.strip,
                      location: data.attributes['title'].value.gsub('|',',').gsub(',',',').split(',').second.strip,
                      date: get_date,
                      content: job_content
                     }
            jobs << job_hash
         end
          page += 1
       end
       parsed_job = jobs.map do |attrs|
        Job.new(attrs)
       end
       Job.import(parsed_job)
       # rescue Exception => e
    # end
  end

    # def self.find_job_description(parse_job_url, browser)
    #   if parse_job_url.css('#content-main').css('.content').text.present?
    #     parse_job_url.css('#content-main').css('.content').text

    #   elsif parse_job_url.css('#content-main').css('.content-container-inserat').css('.js-embed-container').css('.js-embed-output').css('.jobAd').css('.companyDescription').present?

    #     parse_job_url.css('#content-main').css('.content-container-inserat').css('.js-embed-container').css('.js-embed-output').css('.jobAd').css('.companyDescription').text

    #   elsif browser.iframe(id: "iframe1").text.present?
    #     browser.iframe(id: "iframe1").text

    #   elsif parse_job_url.css('#content-main').css('.content-container-inserat').css('#job-eblinger').present?
    #     parse_job_url.css('#content-main').css('.content-container-inserat').css('#job-eblinger').text
    #   end
    # end

    def self.find_date get_date
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
