import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.performSearch()
    }, 300) // Debounce search
  }

  performSearch() {
    const form = this.element.closest('form')
    if (form) {
      // Submit form automatically
      form.requestSubmit()
    }
  }
}