# app/helpers/projects_helper.rb
module ProjectsHelper
  def status_options_for_select
    [
      ['New', 'draft'],
      ['Active', 'active'],
      ['Onboarding', 'on_boarding'],
      ['On Hold', 'on_hold'],
      ['Rejected', 'rejected'],
      ['Closed', 'closed']
    ]
  end
  
  def status_color_class(status)
    case status.to_s
    when 'draft' then 'bg-blue-100 text-blue-800'
    when 'active' then 'bg-green-100 text-green-800'
    when 'on_boarding' then 'bg-yellow-100 text-yellow-800'
    when 'on_hold' then 'bg-orange-100 text-orange-800'
    when 'rejected' then 'bg-red-100 text-red-800'
    when 'closed' then 'bg-gray-100 text-gray-800'
    else 'bg-gray-100 text-gray-800'
    end
  end
  
  def status_display_name(status)
    case status.to_s
    when 'draft' then 'New'
    when 'active' then 'Active'
    when 'on_boarding' then 'Onboarding'
    when 'on_hold' then 'On Hold'
    when 'rejected' then 'Rejected'
    when 'closed' then 'Closed'
    else status.to_s.humanize
    end
  end
end