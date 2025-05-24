# Create default users
admin = User.create!(
  user_name: 'admin',
  password: 'password',
  password_confirmation: 'password',
  role: 'admin',
  full_name: 'System Administrator',
  email: 'admin@example.com'
)

manager = User.create!(
  user_name: 'jdoe',
  password: 'password',
  password_confirmation: 'password',
  role: 'manager',
  full_name: 'John Doe',
  email: 'john@example.com'
)

member = User.create!(
  user_name: 'asmith',
  password: 'password',
  password_confirmation: 'password',
  role: 'member',
  full_name: 'Alice Smith',
  email: 'alice@example.com'
)

# Create sample projects - Updated status values
project1 = Project.create!(
  name: 'Website Redesign',
  description: 'Complete overhaul of company website with modern design',
  content: 'This project involves redesigning the entire company website with modern UI/UX principles, responsive design, and improved user experience.',
  status: 'active',          # Still valid
  creator: manager
)

project2 = Project.create!(
  name: 'Mobile App Development',
  description: 'Native mobile app for iOS and Android platforms',
  content: 'Develop a native mobile application that complements our web platform and provides users with on-the-go access to key features.',
  status: 'draft',           # Changed from 'new' to 'draft'
  creator: admin
)

project3 = Project.create!(
  name: 'Database Migration',
  description: 'Migrate legacy database to new infrastructure',
  content: 'Plan and execute migration of legacy database systems to modern cloud infrastructure with minimal downtime.',
  status: 'on_boarding',     # Still valid
  creator: member
)

project4 = Project.create!(
  name: 'API Documentation',
  description: 'Comprehensive API documentation update',
  content: 'Update and improve API documentation with better examples and clearer explanations.',
  status: 'on_hold',         # Still valid
  creator: manager
)

project5 = Project.create!(
  name: 'Security Audit',
  description: 'Complete security audit of all systems',
  content: 'Comprehensive security review of infrastructure, applications, and processes.',
  status: 'closed',          # Still valid
  creator: admin
)

# Create sample activities
Activity::Comment.create!(
  project: project1,
  creator: manager,
  content: 'Starting the discovery phase for this project. @asmith please review the requirements and provide feedback.'
)

Activity::Comment.create!(
  project: project1,
  creator: member,
  content: 'Requirements look comprehensive. I have some suggestions for the user interface design. @jdoe let\'s schedule a meeting to discuss.'
)

Activity::AuditLog.create!(
  project: project1,
  creator: admin,
  content: 'Project status changed from draft to active'    # Updated from 'new'
)

Activity::Comment.create!(
  project: project2,
  creator: admin,
  content: 'Need to finalize the technical stack for mobile development. Considering React Native vs native solutions.'
)

Activity::AuditLog.create!(
  project: project3,
  creator: member,
  content: 'Project created and assigned to development team'
)

Activity::Comment.create!(
  project: project4,
  creator: manager,
  content: 'Documentation review is on hold pending stakeholder feedback. @admin please advise on timeline.'
)

# Create activity references for mentions
Activity.where(type: 'Comment').each do |activity|
  mentioned_usernames = activity.content.scan(/@(\w+)/).flatten
  mentioned_usernames.each do |username|
    user = User.find_by(user_name: username)
    if user && user != activity.creator
      ActivityReference.create!(
        activity: activity,
        reference: user
      )
    end
  end
end

puts "Created #{User.count} users, #{Project.count} projects, and #{Activity.count} activities"
puts "Login credentials:"
puts "- admin/password (Admin)"  
puts "- jdoe/password (Manager)"
puts "- asmith/password (Member)"
puts ""
puts "Project statuses:"
puts "- Draft: #{Project.draft.count} projects"
puts "- Active: #{Project.active.count} projects" 
puts "- Onboarding: #{Project.on_boarding.count} projects"
puts "- On Hold: #{Project.on_hold.count} projects"
puts "- Closed: #{Project.closed.count} projects"