class Activity::AuditLog < Activity
  # Validations specific to audit logs
  validates :content, presence: true
  
  # Scopes
  scope :project_logs, ->(project) { where(project: project) }
  scope :user_actions, ->(user) { where(creator: user) }
  
  def self.log_project_creation(project, user)
    create!(
      project: project,
      creator: user,
      content: "Project '#{project.name}' was created"
    )
  end
  
  def self.log_project_update(project, user, changes)
    change_descriptions = changes.map do |field, (old_val, new_val)|
      "#{field.humanize}: '#{old_val}' → '#{new_val}'"
    end.join(', ')
    
    create!(
      project: project,
      creator: user,
      content: "Project updated: #{change_descriptions}"
    )
  end
  
  
  # Instance methods
  def system_generated?
    # You can add logic here to determine if this was auto-generated
    content.include?('Status changed') || content.include?('Project updated')
  end
end