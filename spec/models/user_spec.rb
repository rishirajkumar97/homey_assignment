require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:user_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:role) }
    it { should have_secure_password }

    it 'validates uniqueness of user_name' do
      create(:user, user_name: 'testuser')
      user = build(:user, user_name: 'testuser')
      expect(user).not_to be_valid
      expect(user.errors[:user_name]).to include('has already been taken')
    end

    it 'validates uniqueness of email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'validates email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end
  end

  describe 'associations' do
    it { should have_many(:created_projects).class_name('Project') }
    it { should have_many(:created_activities).class_name('Activity') }
    it { should have_many(:activity_references) }
  end

  describe 'instance methods' do
    let(:user) { create(:user, full_name: 'John Doe', user_name: 'johndoe') }

    describe '#display_name' do
      it 'returns full_name when present' do
        expect(user.display_name).to eq('John Doe')
      end

      it 'returns user_name when full_name is blank' do
        user.full_name = ''
        expect(user.display_name).to eq('johndoe')
      end
    end

    describe '#admin?' do
      it 'returns true for admin users' do
        admin = create(:user, :admin)
        expect(admin.admin?).to be true
      end

      it 'returns false for non-admin users' do
        expect(user.admin?).to be false
      end
    end

    describe '#can_manage_projects?' do
      it 'returns true for admin users' do
        admin = create(:user, :admin)
        expect(admin.can_manage_projects?).to be true
      end

      it 'returns true for manager users' do
        manager = create(:user, :manager)
        expect(manager.can_manage_projects?).to be true
      end

      it 'returns false for member users' do
        member = create(:user, :member)
        expect(member.can_manage_projects?).to be false
      end
    end
  end

  describe 'callbacks' do
    it 'normalizes email and username before saving' do
      user = create(:user, email: 'TEST@EXAMPLE.COM', user_name: 'TestUser')
      expect(user.email).to eq('test@example.com')
      expect(user.user_name).to eq('testuser')
    end
  end
end