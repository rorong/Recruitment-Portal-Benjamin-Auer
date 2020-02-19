class DynamicScraperService
  require 'nokogiri'
  require 'httparty'
  require 'webdrivers'
  require 'watir'
  require 'net/http'
  require 'date'

  class << self
    def dynamic_scrap(designation,location)
      begin
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
            url = "jobs.derstandard.at"+ data.children.css('a')[0].attributes['href'].value
            browser.goto(url)
            parse_job_url ||= Nokogiri::HTML(browser.html)
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
                          elsif parse_job_url.css('.abstand-aussen').text.present?
                            parse_job_url.css('.abstand-aussen').text
                          elsif parse_job_url.css('.jobAd').text.present?
                            parse_job_url.css('.jobAd').text
                          elsif parse_job_url.css('#job_content_left').text.present?
                            parse_job_url.css('#job_content_left').text
                          elsif parse_job_url.css('#job-ims').css('.left').text.present?
                            parse_job_url.css('#job-ims').css('.left').text
                          elsif parse_job_url.css('#jobAd').css('.job-body').text.present?
                            parse_job_url.css('#jobAd').css('.job-body').text
                          elsif parse_job_url.css('#job-lindlpower').css('.row').text.present?
                            parse_job_url.css('#job-lindlpower').css('.row').text
                          elsif parse_job_url.css('#job-santander').css('.job__left-column').text.present?
                            parse_job_url.css('#job-santander').css('.job__left-column').text
                          elsif parse_job_url.css('.job-box').text.present?
                            parse_job_url.css('.job-box').text
                          elsif parse_job_url.css('.content>ul>li').text.present?
                            parse_job_url.css('.content>ul>li').text
                          elsif parse_job_url.css('#content-main').css('.content-container-inserat').css('.js-embed-container').css('#jobAd').text.present?
                            parse_job_url.css('#content-main').css('.content-container-inserat').css('.js-embed-container').css('#jobAd').text.delete!("\n").strip
                          elsif parse_job_url.css('#content-main').css('.content-container-inserat').css('.js-embed-container').text.present?
                            c = parse_job_url.css('#content-main').css('.content-container-inserat').css('.js-embed-container').text.delete!("\n").strip
                            coder = HTMLEntities.new
                            cnt = Nokogiri::HTML(coder.decode(c))
                            coder = HTMLEntities.new
                            content = Nokogiri::HTML(coder.decode(cnt.to_html))
                            html = content.to_html
                            doc = Nokogiri::HTML(html)
                            doc.xpath('//style').remove
                            doc.xpath('//img').remove
                            doc.text.delete!("\n")
                          elsif browser.iframe(:id, "iframe1").text.present?
                            browser.iframe(:id, "iframe1").text
                          else
                          end
            get_date = find_date(data.attributes['title'].value.gsub('|',',').gsub(',',',').split(','))

            job_hash = {
                        title: data.attributes['title'].value.gsub('|',',').gsub(',',',').split(',').first.strip,
                        url: url,
                        location: data.css('span.jobadress').text,
                        company: data.css('span.company').text,
                        date: get_date,
                        content: job_content
                       }
            job_hash = job_already_present job_hash
            jobs << job_hash if job_hash
          end
          page += 1
        end
        parsed_job = jobs.map do |attrs|
          Job.new(attrs)
        end
        job_ids = Job.import(parsed_job)
        all_job = Job.where(id: job_ids.ids)
        ids = all_job.select("MIN(id) as id").group(:title).collect(&:id)
        dup_jobs = all_job.where.not(id: ids)
        dup_jobs.destroy_all

        if all_job.present?
          User.all.each do |user|
            JobMailer.job_email(user, all_job).deliver_now
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
