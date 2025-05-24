class Activity::Comment < Activity
  # Callbacks
  after_create :create_user_mentions
  after_update :update_user_mentions, if: :saved_change_to_content?
  
  # Validations specific to comments
  validates :content, length: { minimum: 1, maximum: 2000 }
  
  # Scopes
  scope :recent_comments, -> { recent_first.limit(50) }
  scope :by_project_and_recent, ->(project) { where(project: project).recent_first }
  
  private
  
  def create_user_mentions
    extract_and_create_mentions
  end
  
  def update_user_mentions
    # Remove existing mentions and recreate
    activity_references.destroy_all
    extract_and_create_mentions
  end
  
  def extract_and_create_mentions
    # Extract @username mentions from content
    mentioned_usernames = content.scan(/@(\w+)/).flatten.uniq
    
    mentioned_usernames.each do |username|
      user = User.find_by(user_name: username.downcase)
      if user && user != creator # Don't mention yourself
        activity_references.create!(
          reference: user
        )
      end
    end
  end
end
