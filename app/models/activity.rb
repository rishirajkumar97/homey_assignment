class Activity < ApplicationRecord
  # Polymorphic association
  belongs_to :creator, polymorphic: true
  belongs_to :project
  
  # Regular associations
  has_many :activity_references, dependent: :destroy
  has_many :user_references, -> { where(reference_klass: 'User') }, 
           class_name: 'ActivityReference'
  has_many :referenced_users, through: :user_references, 
           source: :reference, source_type: 'User'
  
  # Validations
  validates :type, presence: true, inclusion: { in: %w[Activity::Comment Activity::AuditLog] }
  validates :content, presence: true, length: { minimum: 1, maximum: 5000 }
  validates :creator, presence: true
  validates :project, presence: true
  
  # Scopes
  scope :recent_first, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }
  scope :by_type, ->(type) { where(type: type) }
  scope :by_creator, ->(creator) { where(creator: creator) }
  scope :by_project, ->(project) { where(project: project) }
  scope :with_mentions, -> { joins(:activity_references).distinct }
  
  # Instance methods
  def activity_type
    type.underscore.humanize
  end
  
  def icon_class
    case type
    when 'Activity::Comment'
      'chat-bubble-left'
    when 'Activity::AuditLog'
      'clock'
    else
      'document-text'
    end
  end
  
  def creator_name
    case creator
    when User
      creator.display_name
    else
      creator.to_s
    end
  end
  
  def has_mentions?
    activity_references.exists?
  end
  
  def mentioned_users
    referenced_users
  end
  
  def can_be_edited_by?(user)
    return false if type == 'Activity::AuditLog' # Audit logs shouldn't be editable
    return true if user.admin?
    creator == user
  end
end