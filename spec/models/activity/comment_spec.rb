require 'rails_helper'

RSpec.describe Activity::Comment, type: :model do
  it 'inherits from Activity' do
    expect(Activity::Comment.superclass).to eq(Activity)
  end

  describe 'validations' do
    it { should validate_length_of(:content).is_at_least(1).is_at_most(2000) }
  end

  describe 'callbacks' do
    let(:project) { create(:project) }
    let(:user) { create(:user) }
    let!(:mentioned_user) { create(:user, user_name: 'testuser') }
  end

  describe 'scopes' do
    let(:project) { create(:project) }
    let!(:old_comment) { create(:comment, project: project, created_at: 2.days.ago) }
    let!(:recent_comment) { create(:comment, project: project, created_at: 1.hour.ago) }

    describe '.recent_comments' do
      it 'returns recent comments first with limit' do
        comments = Activity::Comment.recent_comments
        expect(comments.first.id).to eq(recent_comment.id)
        expect(comments.size).to be <= 50
      end
    end

    describe '.by_project_and_recent' do
      it 'returns comments for specific project in recent order' do
        other_project = create(:project)
        other_comment = create(:comment, project: other_project)

        comments = Activity::Comment.by_project_and_recent(project).to_a
        expect(comments.pluck(:id)).to eq([recent_comment.id, old_comment.id])
        expect(comments.pluck(:id)).not_to include(other_comment.id)
        expect(comments.first.id).to eq(recent_comment.id)
      end
    end
  end
end