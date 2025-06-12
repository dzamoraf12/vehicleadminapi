class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  enum :role, { admin: 0, tecnico: 1, chofer: 2 }

  def admin?
    role == "admin"
  end

  def technician?
    role == "tecnico"
  end

  def driver?
    role == "chofer"
  end
end
