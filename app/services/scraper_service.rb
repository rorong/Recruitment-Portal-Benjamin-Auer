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

        # previous_temp_jobs_count = TempJob.count
        # if previous_temp_jobs_count > 0
        #   TempJob.in_batches(of: previous_temp_jobs_count).delete_all
        # end

        uniq_desiginations = JobSearch.pluck(:designation).uniq
        unless uniq_desiginations.blank?
          parsed_job = []
          uniq_desiginations.each do |designation|
            uniq_locations = JobSearch.where(designation: designation).pluck(:location).uniq
            unless uniq_locations.blank?
              uniq_locations.each do |location|
                formatted_location = location.gsub(" ","")
                formatted_designation = designation.gsub(" ","")
                #Job Parsing based on unique location and desigination
                parse_page = Nokogiri::HTML(open("https://www.karriere.at/jobs/#{formatted_designation}/#{formatted_location}"))
                jobs = Array.new

                datas =  parse_page.css('div.m-jobsListItem__dataContainer')
                if parse_page.css('div.m-jobsListItem__dataContainer').present?
                  page = 1
                  per_page = datas.count
                  total = parse_page.css('div.m-pagination').css('div.m-pagination__inner').css('span.m-pagination__meta').text.split(' ')[2].to_i * per_page

                  last_page = (total.to_f / per_page.to_f).round

                  while page <= last_page
                    pagination_url = page > 1 ? "https://www.karriere.at/jobs/#{formatted_designation}/#{formatted_location}?page=#{page}" : "https://www.karriere.at/jobs/#{formatted_designation}/#{formatted_location}"
                    pagination_parse_page = Nokogiri::HTML(open(pagination_url))
                    pagination_datas =  pagination_parse_page.css('div.m-jobsListItem__dataContainer')
                    pagination_datas.each do |data|
                      url = data.css('h2.m-jobsListItem__title').css('a')[0].attributes['href'].value
                      job_url = HTTParty.get(url)

                      job_hash = {
                                title: data.css('h2.m-jobsListItem__title').text.strip,
                                company: data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__company').text.strip,
                                url: data.css('h2.m-jobsListItem__title').css('a')[0].attributes['href'].value.strip,
                                location:  (data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__wrap').css('ul.m-jobsListItem__locations').css('li.m-jobsListItem__location').css('a')[0].text.strip.downcase rescue nil),
                                date: data.css('div.m-jobsListItem__meta').css('div.m-jobsListItem__wrap').css('span.m-jobsListItem__date')[0].text.gsub("am","").strip,
                                content: data.css('p.m-jobsListItem__snippet').text.strip,
                                job_search_type: 1
                          }
                      puts ">>>>>>>>>>>>> #{job_hash}"
                      #job_hash = job_already_present job_hash
                      jobs << job_hash if job_hash
                    end
                    page += 1
                    puts ">>>>>>>>>>>>>>>>  #{page}"
                  end
                  # Seeding jobs for users
                  user_job_searches = JobSearch.where("location = ? AND designation = ?", location, designation)
                  uniq_user_ids = user_job_searches.pluck(:user_id).uniq
                  uniq_user_ids.each do |user_id|
                    parsed_job << jobs.map do |attrs|
                      user_jobs = Job.where(user_id: user_id).pluck(:url)
                      if !user_jobs.include?(attrs[:url])
                        attrs.merge!(user_id: user_id)
                        Job.new(attrs)
                      end
                    end
                  end
                end
              end
            end
          end
          if parsed_job.count > 0
            parsed_job.flatten!
            Job.import(parsed_job)
          end
        end

      rescue Exception
      end
    end

    # def job_already_present job_hash
    #   result = Job.pluck(:url).include?(job_hash[:url]) && Job.pluck(:user_id).include?(job_hash[:user_id])
    #   if result
    #     false
    #   else
    #     job_hash
    #   end
    # end
  end
end
