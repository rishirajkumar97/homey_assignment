require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:creator) }
    it { should validate_presence_of(:project) }
    it { should validate_inclusion_of(:type).in_array(%w[Activity::Comment Activity::AuditLog]) }
    it { should validate_length_of(:content).is_at_least(1).is_at_most(5000) }
  end

  describe 'associations' do
    it { should belong_to(:creator) }
    it { should belong_to(:project) }
    it { should have_many(:activity_references).dependent(:destroy) }
  end

  describe 'instance methods' do
    let(:activity) { create(:comment) }

    describe '#activity_type' do
      it 'returns humanized type' do
        expect(activity.type).to eq('Activity::Comment')
      end
    end

    describe '#creator_name' do
      it 'returns creator display name' do
        expect(activity.creator_name).to eq(activity.creator.display_name)
      end
    end

    describe '#has_mentions?' do
      it 'returns true when activity has references' do
        create(:activity_reference, activity: activity)
        expect(activity.has_mentions?).to be true
      end

      it 'returns false when activity has no references' do
        expect(activity.has_mentions?).to be false
      end
    end

    describe '#can_be_edited_by?' do
      let(:admin) { create(:user, :admin) }
      let(:creator) { activity.creator }
      let(:other_user) { create(:user) }

      it 'allows admin to edit comments' do
        expect(activity.can_be_edited_by?(admin)).to be true
      end

      it 'allows creator to edit their own comments' do
        expect(activity.can_be_edited_by?(creator)).to be true
      end

      it 'does not allow other users to edit comments' do
        expect(activity.can_be_edited_by?(other_user)).to be false
      end

      it 'does not allow editing of audit logs' do
        audit_log = create(:audit_log)
        expect(audit_log.can_be_edited_by?(admin)).to be false
      end
    end
  end

  describe 'scopes' do
    let!(:project) { create(:project, created_at: 3.hours.ago) }
    let!(:comment1) { create(:comment, project: project, created_at: 1.hour.ago) }
    let!(:comment2) { create(:comment, project: project, created_at: 2.hours.ago) }
    let!(:audit_log) { create(:audit_log, project: project, created_at: 30.minutes.ago) }

    describe '.recent_first' do
      it 'orders activities by created_at desc' do
        activities = Activity.recent_first
        expect(activities.second.id).to eq(audit_log.id)
        expect(activities.last.id).to eq(comment2.id)
      end
    end

    describe '.chronological' do
      it 'orders activities by created_at asc' do
        activities = Activity.chronological
        expect(activities.first.id).to eq(comment2.id)
        expect(activities[-2].id).to eq(audit_log.id)
      end
    end

    describe '.by_type' do
      it 'filters activities by type' do
        comments = Activity.by_type('Activity::Comment')
        expect(comments).to include(comment1, comment2)
        expect(comments).not_to include(audit_log)
      end
    end
  end
end