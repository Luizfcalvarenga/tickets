class Admin::PartnerPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

    def show?
      false
    end

    def create?
      false
    end

    def update?
      false
    end

    def edit
      false
    end
end
