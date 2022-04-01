desc "Heroku Scheduler"
task :check_payments => :environment do
  PaymentCheckerJob.new.call
end
