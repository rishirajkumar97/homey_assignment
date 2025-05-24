require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'validations' do
    subject { build(:project) }
    
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:creator) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(255) }
  end

  describe 'associations' do
    it { should belong_to(:creator) }
    it { should have_many(:activities).dependent(:destroy) }
    it { should have_many(:comments) }
    it { should have_many(:audit_logs) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(
      draft: 0, active: 1, on_boarding: 2, on_hold: 3, rejected: 4, closed: 5
    ) }
  end

  describe 'instance methods' do
    let(:project) { create(:project) }

    describe '#status_color' do
      it 'returns correct color for draft status' do
        project.update!(status: 'draft')
        expect(project.status_color).to eq('bg-blue-100 text-blue-800')
      end

      it 'returns correct color for active status' do
        project.update!(status: 'active')
        expect(project.status_color).to eq('bg-green-100 text-green-800')
      end

      it 'returns correct color for on_boarding status' do
        project.update!(status: 'on_boarding')
        expect(project.status_color).to eq('bg-yellow-100 text-yellow-800')
      end

      it 'returns correct color for on_hold status' do
        project.update!(status: 'on_hold')
        expect(project.status_color).to eq('bg-orange-100 text-orange-800')
      end

      it 'returns correct color for rejected status' do
        project.update!(status: 'rejected')
        expect(project.status_color).to eq('bg-red-100 text-red-800')
      end

      it 'returns correct color for closed status' do
        project.update!(status: 'closed')
        expect(project.status_color).to eq('bg-gray-100 text-gray-800')
      end
    end

    describe '#status_display_name' do
      it 'returns "New" for draft status' do
        project.update!(status: 'draft')
        expect(project.status_display_name).to eq('New')
      end

      it 'returns "Active" for active status' do
        project.update!(status: 'active')
        expect(project.status_display_name).to eq('Active')
      end

      it 'returns "Onboarding" for on_boarding status' do
        project.update!(status: 'on_boarding')
        expect(project.status_display_name).to eq('Onboarding')
      end
    end

    describe '#can_be_edited_by?' do
      let(:admin) { create(:user, role: 'admin') }
      let(:manager) { create(:user, role: 'manager') }
      let(:member) { create(:user, role: 'member') }
      let(:creator) { create(:user, role: 'manager') }
      let(:project) { create(:project, creator: creator) }

      it 'allows admin to edit any project' do
        expect(project.can_be_edited_by?(admin)).to be true
      end

      it 'allows creator with management rights to edit their project' do
        expect(project.can_be_edited_by?(creator)).to be true
      end

      it 'does not allow members to edit projects' do
        expect(project.can_be_edited_by?(member)).to be false
      end
    end

    describe '#is_active?' do
      it 'returns true for draft projects' do
        project.update!(status: 'draft')
        expect(project.status).to eq 'draft'
      end

      it 'returns true for active projects' do
        project.update!(status: 'active')
        expect(project.is_active?).to be true
      end

      it 'returns true for on_boarding projects' do
        project.update!(status: 'on_boarding')
        expect(project.is_active?).to be true
      end

      it 'returns false for closed projects' do
        project.update!(status: 'closed')
        expect(project.is_active?).to be false
      end

      it 'returns false for rejected projects' do
        project.update!(status: 'rejected')
        expect(project.is_active?).to be false
      end
    end
  end

  describe 'callbacks' do
    let(:user) { create(:user) }

    it 'creates audit log on project creation' do
      expect {
        create(:project, creator: user)
      }.to change(Activity::AuditLog, :count).by(1)
      
      project = Project.last
      audit_log = Activity::AuditLog.last
      expect(audit_log.content).to include("Project '#{project.name}' was created")
      expect(audit_log.creator).to eq(user)
    end

    it 'creates audit log on status change' do
      project = create(:project, creator: user, status: 'draft')
      
      expect {
        project.update!(status: 'active')
      }.to change(Activity::AuditLog, :count).by(1)
      
      audit_log = Activity::AuditLog.last
      expect(audit_log.content).to include('Status changed from')
    end
  end
end