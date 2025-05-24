class ProjectsController < ApplicationController
  def index
    @projects = Project.includes(:creator)
    
    # Filter by status if provided - Updated to handle 'new' -> 'draft' mapping
    if params[:status].present? && params[:status] != 'all'
      # Map 'new' from URL to 'draft' in database
      status_param = params[:status] == 'new' ? 'draft' : params[:status]
      @projects = @projects.where(status: status_param) if Project.statuses.key?(status_param)
    end

    if params[:search].present?
      @projects = @projects.where("name like ?", "%#{params[:search]}%")
    end
    # ... rest of the method stays the same
    
    # Status counts for tabs - Updated to show 'new' in UI but count 'draft' in DB
    @status_counts = Project.group(:status).count
    @status_counts['new'] = @status_counts.delete('draft') || 0  # Show as 'new' in UI
    @status_counts['all'] = Project.count
    
    @current_status = params[:status] || 'all'
    
    respond_to do |format|
      format.html
      format.json { render json: { projects: @projects, meta: pagination_meta(@projects) } }
    end
  end
  
  def show
    @project = Project.find(params[:id])
    @activities = @project.activities
                           .includes(:creator, activity_references: :reference)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(20)
    
    respond_to do |format|
      format.html
      format.json { render json: { project: @project, activities: @activities, meta: pagination_meta(@activities) } }
    end
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = current_user.created_projects.build(project_params)
    
    if @project.save
      redirect_to @project, notice: 'Project created successfully!'
    else
      render :new
    end
  end
  
  def update_status
    @project = Project.find(params[:id])
    old_status = @project.status
    
    if @project.update(status: params[:status])
      # Create audit log -> via on_update in model level
      respond_to do |format|
        format.html { redirect_to @project, notice: 'Status updated successfully!' }
        format.json { render json: { success: true, project: @project } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @project, alert: 'Failed to update status' }
        format.json { render json: { success: false, errors: @project.errors } }
      end
    end
  end
  
  private
  
  def project_params
    params.require(:project).permit(:name, :description, :content, :status)
  end
  
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end
end