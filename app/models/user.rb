# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  
  # Validations
  validates :user_name, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true
  validates :role, presence: true
  
  # Enums
  enum role: { 
    admin: 'admin', 
    manager: 'manager', 
    member: 'member' 
  }
  
  # Polymorphic associations as creator
  has_many :created_projects, as: :creator, class_name: 'Project', dependent: :destroy
  has_many :created_activities, as: :creator, class_name: 'Activity', dependent: :destroy
  
  # Polymorphic associations as reference
  has_many :activity_references, as: :reference, class_name: 'ActivityReference', dependent: :destroy
  has_many :referenced_activities, through: :activity_references, source: :activity
  
  # Scopes
  scope :active, -> { where.not(role: nil) }
  scope :by_role, ->(role) { where(role: role) }
  
  # Instance methods
  def display_name
    full_name.present? ? full_name : user_name
  end
  
  def admin?
    role == 'admin'
  end
  
  def can_manage_projects?
    admin? || manager?
  end
  
  def mentioned_in_activities
    referenced_activities.includes(:project, :creator)
  end
  
  private
  
  # Normalize email and username before saving
  before_save :normalize_attributes
  
  def normalize_attributes
    self.email = email.downcase.strip if email.present?
    self.user_name = user_name.downcase.strip if user_name.present?
  end
end