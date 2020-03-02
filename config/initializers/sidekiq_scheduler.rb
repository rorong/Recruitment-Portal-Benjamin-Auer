# require 'sidekiq/scheduler'


# Sidekiq.configure_server do |config|

#     config.on(:startup) do
#       Sidekiq::Scheduler.dynamic = true
 
#     Sidekiq.set_schedule('daily_email_worker',{
#           cron: "0 0 0 * * *",
#           class: DailyEmailWorker
#         })
    
#     Sidekiq.set_schedule('weekly_email_worker',{
#         every: ["1s"]<<first_mail,
#         class: WeeklyEmailWorker
#       })

#     Sidekiq.set_schedule('two_week_email_worker',{
#           every: ["2w"]<<first_mail,
#           class: TwoWeekEmailWorker
#           })

#     Sidekiq.set_schedule('monthly_email_worker',{
#       every: ["4w"]<<first_mail,
#         class: MonthlyEmailWorker
#       })

#     Sidekiq.set_schedule('yearly_email_worker',{
#         every: ["52w"]<<first_mail,
#         class: YearlyEmailWorker
#       })
#   end
# end


#   def first_mail
#     date  = DateTime.parse("Monday")
#     delta = date > DateTime.now ? 0 : 7
#     e=date + delta
#     g=((e-DateTime.now)*24*60).to_i
#     {first_in: g.to_s+"m"}
#   end
#     Sidekiq.set_schedule(weekly_email_worker:{
#         every: ["1w"]<<first_mail,
#         class: WeeklyEmailWorker
#       })

#     Sidekiq.set_schedule(two_week_email_worker:{
#           every: ["2w"]<<first_mail,
#           class: TwoWeekEmailWorker
#           })

#     Sidekiq.set_schedule(monthly_email_worker:{
#       every: ["4w"]<<first_mail,
#         class: MonthlyEmailWorker
#       })

#     Sidekiq.set_schedule(yearly_email_worker:{
#         every: ["52w"]<<first_mail,
#         class: YearlyEmailWorker
#       })
#   end


# end

