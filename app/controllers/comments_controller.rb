class CommentsController < ApplicationController
  before_action :set_project
  
  def create
    @comment = @project.comments.build(comment_params)
    @comment.creator = current_user
    @comment.type = 'Activity::Comment'  # Explicitly set the STI type
    
    if @comment.save
      redirect_to @project, notice: 'Comment added successfully!'
    else
      redirect_to @project, alert: "Failed to add comment: #{@comment.errors.full_messages.join(', ')}"
    end
  end
  
  private
  
  def set_project
    @project = Project.find(params[:project_id])
  end
  
  def comment_params
    params.require(:activity_comment).permit(:content)
  end
end