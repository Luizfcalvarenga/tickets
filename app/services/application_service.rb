# All services should inherit from ApplicationService
# Call your service directly from the Service class e.g. UserUpdaterService.call(params) or UserUpdaterService.(params)
# Do not return any values on your Service "call" method
# The Service "call" method returns true if operation was successful and false if unsuccessful
# If operation was unsuccessful, add the failure reasons to "errors" and raise an exception
# Services should have only one public method, named "call", which performs a single business operation
# Other methods should be private auxiliary methods

class ApplicationService
	attr_reader :errors
	
  def self.call(*args, &block)
    new(*args, &block).call
		return true
	rescue
		return false
  end

	def self.call!(*args, &block)
    new(*args, &block).call!
		return true
	rescue
		return false
  end
end
