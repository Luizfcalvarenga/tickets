desc "Heroku Scheduler"
task :check_payments => :environment do
  PaymentCheckerJob.perform_later
end
