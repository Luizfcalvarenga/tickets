class MembershipsFetcher < ApplicationService
  def call
    user_memberships = UserMembership.all
    user_memberships.find_each do |user_membership|
      UserMembershipFetcherJob.perform_later(user_membership)
    end
  end
end
