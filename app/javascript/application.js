import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('DOMContentLoaded', function() {
  // Handle method="delete" links
  document.addEventListener('click', function(e) {
    const link = e.target.closest('a[data-method]');
    if (link && link.dataset.method === 'delete') {
      e.preventDefault();
      
      if (confirm('Are you sure?')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = link.href;
        
        const csrfToken = document.querySelector('[name="csrf-token"]').content;
        const methodInput = document.createElement('input');
        methodInput.type = 'hidden';
        methodInput.name = '_method';
        methodInput.value = 'delete';
        
        const tokenInput = document.createElement('input');
        tokenInput.type = 'hidden';
        tokenInput.name = 'authenticity_token';
        tokenInput.value = csrfToken;
        
        form.appendChild(methodInput);
        form.appendChild(tokenInput);
        document.body.appendChild(form);
        form.submit();
      }
    }
  });
});
console.log("Application JS loaded")