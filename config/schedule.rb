set :environment, "development"
set :output, {:error => "log/cron_error_log.log", :standard => "log/cron_log.log"}

every :weekday, :at => '9:25 am' do
  rake "attendance_bot:run"
end