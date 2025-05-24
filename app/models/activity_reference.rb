class ActivityReference < ApplicationRecord
  # Polymorphic association
  belongs_to :reference, polymorphic: true, foreign_key: 'reference_id', foreign_type: 'reference_klass'
  belongs_to :activity
  
  # Validations
  validates :reference, presence: true
  validates :activity, presence: true
  validates :reference_id, uniqueness: { scope: [:activity_id, :reference_klass] }
  
  # Scopes
  scope :user_references, -> { where(reference_klass: 'User') }
  scope :other_references, -> { where.not(reference_klass: 'User')}
  scope :by_activity, ->(activity) { where(activity: activity) }
  scope :by_reference, ->(reference) { where(reference: reference) }
  
  # Instance methods
  def reference_name
    case reference
    when User
      reference.display_name
    else
      reference.to_s
    end
  end
  
  def reference_type
    reference_klass.underscore.humanize
  end
end