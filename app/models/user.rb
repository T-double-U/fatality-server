class User < ApplicationRecord
  connects_to database: { writing: :primary, reading: :primary }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  inheritance_column = nil
  has_many :personal_items
  has_many :contests_users
  has_many :moder_contests_users
  has_one :refund

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: [:user, :superadmin, :moderator]

  validates_uniqueness_of :steamID
  validates_uniqueness_of :email

  def admin?
    %w(superadmin moderator).include? role
  end
end
