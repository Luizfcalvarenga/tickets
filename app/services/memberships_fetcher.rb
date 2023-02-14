class MembershipsFetcher < ApplicationService
  def call
    return if Time.current.day % 7 != 0 # Run every 7 days

    user_memberships = UserMembership.active
    user_memberships.find_each do |user_membership|
      UserMembershipFetcherJob.perform_later(user_membership)
    end
  end
end
