import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["commentModal", "statusModal", "commentForm", "statusForm"]
  static values = { projectId: Number }

  openCommentModal() {
    this.commentModalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  closeCommentModal() {
    this.commentModalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    this.clearCommentForm()
  }

  openStatusModal() {
    this.statusModalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  closeStatusModal() {
    this.statusModalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  clearCommentForm() {
    const textarea = this.commentFormTarget.querySelector('textarea')
    if (textarea) textarea.value = ''
  }

  // Handle form submissions via AJAX if needed
  async submitComment(event) {
    event.preventDefault()
    
    const formData = new FormData(this.commentFormTarget)
    
    try {
      const response = await fetch(this.commentFormTarget.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })
      
      const data = await response.json()
      
      if (data.success) {
        this.closeCommentModal()
        // Reload the page to show new comment
        window.location.reload()
      } else {
        // Handle errors
        console.error('Failed to add comment:', data.errors)
      }
    } catch (error) {
      console.error('Error submitting comment:', error)
    }
  }

  async submitStatus(event) {
    event.preventDefault()
    
    const formData = new FormData(this.statusFormTarget)
    
    try {
      const response = await fetch(this.statusFormTarget.action, {
        method: 'PATCH',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })
      
      const data = await response.json()
      
      if (data.success) {
        this.closeStatusModal()
        // Reload the page to show status change
        window.location.reload()
      } else {
        console.error('Failed to update status:', data.errors)
      }
    } catch (error) {
      console.error('Error updating status:', error)
    }
  }
}