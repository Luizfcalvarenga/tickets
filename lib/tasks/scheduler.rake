desc "Heroku Scheduler"
task :check_payments => :environment do
  PaymentCheckerJob.perform_later
end
task :check_memberships => :environment do
  MembershipsFetcher.call
end
