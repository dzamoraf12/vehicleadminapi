class MaintenanceReportPolicy < ApplicationPolicy
  def index?
    user.admin? || user.technician?
  end

  def show?
    user.admin? || user.technician?
  end

  def create?
    user.technician? || user.driver?
  end

  def update?
    user.admin? || user.technician?
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
