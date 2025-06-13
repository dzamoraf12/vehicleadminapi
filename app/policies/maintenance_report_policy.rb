class MaintenanceReportPolicy < ApplicationPolicy
  def index?
    false
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

  class Scope < Scope
    def resolve
      if user.admin? || user.technician?
        scope.all
      else
        scope.none
      end
    end
  end
end
