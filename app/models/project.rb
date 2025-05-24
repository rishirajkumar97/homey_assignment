class Project < ApplicationRecord
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :status, presence: true
  validates :creator, presence: true
  
  # Polymorphic association
  belongs_to :creator, polymorphic: true
  
  # Regular associations
  has_many :activities, dependent: :destroy
  has_many :comments, -> { where(type: 'Comment') }, class_name: 'Activity'
  has_many :audit_logs, -> { where(type: 'AuditLog') }, class_name: 'Activity'
  
  # Enums
  enum status: {
    draft: 0,
    active: 1,
    on_boarding: 2,
    on_hold: 3,
    rejected: 4,
    closed: 5
  }
  
  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_creator, ->(creator) { where(creator: creator) }
  scope :recent, -> { order(created_at: :desc) }
  scope :active_projects, -> { where(status: [:new, :active, :on_boarding]) }
  
  # Callbacks
  after_create :log_creation
  after_update :log_status_change, if: :saved_change_to_status?

  scope :search, ->(term) {
    joins(:creator).where(
      "projects.name ILIKE :term OR projects.description ILIKE :term OR users.full_name ILIKE :term",
      term: "%#{term}%"
    )
  }
  
  def activity_count
    activities.count
  end
  
  def recent_activity
    activities.order(:created_at).last
  end
  
  # Instance methods
  def status_color
    case status
    when 'draft' then 'bg-blue-100 text-blue-800'      # Changed from 'new'
    when 'active' then 'bg-green-100 text-green-800'
    when 'on_boarding' then 'bg-yellow-100 text-yellow-800'
    when 'on_hold' then 'bg-orange-100 text-orange-800'
    when 'rejected' then 'bg-red-100 text-red-800'
    when 'closed' then 'bg-gray-100 text-gray-800'
    else 'bg-gray-100 text-gray-800'
    end
  end
  
  def status_display_name
    case status
    when 'draft' then 'New'           # Display as 'New' in UI
    when 'active' then 'Active'
    when 'on_boarding' then 'Onboarding'
    when 'on_hold' then 'On Hold'
    when 'rejected' then 'Rejected'
    when 'closed' then 'Closed'
    else status.humanize
    end
  end
  
  def activity_count
    activities.count
  end
  
  def recent_activities(limit = 10)
    activities.includes(:creator).order(created_at: :desc).limit(limit)
  end
  
  def can_be_edited_by?(user)
    return true if user.admin?
    return true if creator == user && user.can_manage_projects?
    false
  end
  
  def is_active?
    ['new', 'active', 'on_boarding'].include?(status)
  end
  
  private
  
  def log_creation
    Activity::AuditLog.create!(
      project: self,
      creator: creator,
      content: "Project '#{name}' was created"
    )
  end
  
  def log_status_change
    old_status = saved_changes['status'][0]
    new_status = saved_changes['status'][1]
    
    Activity::AuditLog.create!(
      project: self,
      creator: creator, # You might want to track who changed it differently
      content: "Status changed from '#{old_status&.humanize || 'none'}' to '#{new_status&.humanize}'"
    )
  end
  
  # def log_project_updates
  #   changes = saved_changes.except('updated_at', 'status')
    
  #   if changes.any?
  #     change_descriptions = changes.map do |field, (old_val, new_val)|
  #       "#{field.humanize}: '#{old_val}' → '#{new_val}'"
  #     end.join(', ')
      
  #     Activity::AuditLog.create!(
  #       project: self,
  #       creator: creator,
  #       content: "Project updated: #{change_descriptions}"
  #     )
  #   end
  # end
end
