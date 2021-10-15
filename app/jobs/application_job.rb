# Refer to https://kitt.lewagon.com/camps/444/lectures/06-Projects%2F03-Advanced-Admin#source

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
