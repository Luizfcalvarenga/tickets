class ExampleJob < ApplicationJob
  queue_as :default

  def perform(arguments)
    puts "Performing job..."
    sleep 2
    puts "Done!"
  end
end
