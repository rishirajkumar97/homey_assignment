import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Add any authentication form enhancements
    console.log("Auth form connected")
  }

  async submitForm(event) {
    event.preventDefault()
    
    const formData = new FormData(this.element)
    const submitButton = this.element.querySelector('input[type="submit"]')
    
    // Disable submit button during request
    submitButton.disabled = true
    submitButton.value = 'Please wait...'
    
    try {
      const response = await fetch(this.element.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })
      
      const data = await response.json()
      
      if (response.ok && data.token) {
        // Store token and redirect
        localStorage.setItem('auth_token', data.token)
        window.location.href = '/projects'
      } else {
        // Handle errors
        this.displayErrors(data.errors || { general: ['Invalid credentials'] })
      }
    } catch (error) {
      console.error('Authentication error:', error)
      this.displayErrors({ general: ['Network error. Please try again.'] })
    } finally {
      // Re-enable submit button
      submitButton.disabled = false
      submitButton.value = submitButton.dataset.originalValue || 'Sign in'
    }
  }

  displayErrors(errors) {
    // Remove existing error messages
    this.element.querySelectorAll('.error-message').forEach(el => el.remove())
    
    // Display new errors
    Object.entries(errors).forEach(([field, messages]) => {
      const fieldElement = this.element.querySelector(`[name="${field}"]`) || 
                          this.element.querySelector('input[type="submit"]')
      
      if (fieldElement) {
        const errorDiv = document.createElement('div')
        errorDiv.className = 'error-message text-red-600 text-sm mt-1'
        errorDiv.textContent = messages.join(', ')
        fieldElement.parentNode.appendChild(errorDiv)
      }
    })
  }
}