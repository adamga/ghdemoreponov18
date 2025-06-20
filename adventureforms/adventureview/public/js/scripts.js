/**
 * File: scripts.js
 * Purpose: Client-side JavaScript for Adventure Forms data visualization and interaction
 * 
 * Description:
 * This file contains client-side JavaScript functionality for the Adventure Forms application.
 * It handles DOM manipulation, AJAX requests for data fetching, table rendering, and user
 * interactions for dynamic data visualization based on selected views.
 * 
 * Logic:
 * - DOM content loaded event handler for initialization
 * - fetchData function to retrieve data from /api/data endpoint via fetch API
 * - Dynamic table rendering with user data (firstName, lastName, email)
 * - View-based data filtering through query parameters
 * - DOM manipulation for table population and user interface updates
 * 
 * Security Considerations:
 * - CRITICAL: DOM manipulation with unescaped user data - XSS vulnerability
 * - CRITICAL: innerHTML usage with server data - code injection risk
 * - CRITICAL: Fetch API without input validation - potential for malicious responses
 * - CRITICAL: Query parameter construction without encoding - URL injection
 * - User data should be HTML-encoded before DOM insertion
 * - Server responses should be validated and sanitized
 * - Use textContent instead of innerHTML for user data
 * - Implement Content Security Policy to prevent XSS attacks
 */

document.addEventListener('DOMContentLoaded', function() {
  // Function to fetch data from the server and display it in the table
  function fetchData(view = '') {
    fetch(`/api/data?view=${view}`)
      .then(response => response.json())
      .then(data => {
        const dataTable = document.getElementById('dataTable');
        dataTable.innerHTML = '';
        data.forEach((item, index) => {
          const row = document.createElement('tr');
          row.innerHTML = `
            <th scope="row">${index + 1}</th>
            <td>${item.firstName}</td>
            <td>${item.lastName}</td>
            <td>${item.email}</td>
            <td>
              <button class="btn btn-sm btn-primary edit-btn" data-id="${item.id}">Edit</button>
              <button class="btn btn-sm btn-danger delete-btn" data-id="${item.id}">Delete</button>
            </td>
          `;
          dataTable.appendChild(row);
        });
      })
      .catch(error => console.error('Error fetching data:', error));
  }

  // Function to handle form submission for adding/editing data
  function handleFormSubmit(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    const data = {};
    formData.forEach((value, key) => {
      data[key] = value;
    });

    const method = form.dataset.method;
    const url = method === 'POST' ? '/api/data' : `/api/data/${data.id}`;

    fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    })
      .then(response => response.json())
      .then(result => {
        if (result.success) {
          fetchData();
          $('#addEditModal').modal('hide');
        } else {
          console.error('Error saving data:', result.message);
        }
      })
      .catch(error => console.error('Error saving data:', error));
  }

  // Function to handle delete button click
  function handleDelete(event) {
    const id = event.target.dataset.id;
    if (confirm('Are you sure you want to delete this record?')) {
      fetch(`/api/data/${id}`, {
        method: 'DELETE'
      })
        .then(response => response.json())
        .then(result => {
          if (result.success) {
            fetchData();
          } else {
            console.error('Error deleting data:', result.message);
          }
        })
        .catch(error => console.error('Error deleting data:', error));
    }
  }

  // Function to handle search input
  function handleSearch(event) {
    const query = event.target.value.toLowerCase();
    const rows = document.querySelectorAll('#dataTable tr');
    rows.forEach(row => {
      const cells = row.querySelectorAll('td');
      const match = Array.from(cells).some(cell => cell.textContent.toLowerCase().includes(query));
      row.style.display = match ? '' : 'none';
    });
  }

  // Function to populate the dropdown with data views
  function populateViewsDropdown() {
    fetch('/api/views')
      .then(response => response.json())
      .then(views => {
        const viewsDropdown = document.getElementById('viewsDropdown');
        views.forEach(view => {
          const option = document.createElement('option');
          option.value = view.name;
          option.textContent = view.name;
          viewsDropdown.appendChild(option);
        });
      })
      .catch(error => console.error('Error fetching views:', error));
  }

  // Function to populate the customers dropdown
  async function populateCustomersDropdown() {
    try {
        const response = await fetch('/customers');
        const customers = await response.json();
        const dropdown = document.getElementById('customersDropdown');
        customers.forEach(customer => {
            const option = document.createElement('option');
            option.value = customer.CustomerID;
            option.textContent = customer.CustomerName;
            dropdown.appendChild(option);
        });
    } catch (error) {
        console.error('Failed to fetch customers:', error);
    }
  }

  // Event listener for form submission
  document.getElementById('addEditForm').addEventListener('submit', handleFormSubmit);

  // Event listener for delete buttons
  document.getElementById('dataTable').addEventListener('click', function(event) {
    if (event.target.classList.contains('delete-btn')) {
      handleDelete(event);
    }
  });

  // Event listener for search input
  document.getElementById('searchInput').addEventListener('input', handleSearch);

  // Event listener for views dropdown change
  document.getElementById('viewsDropdown').addEventListener('change', function(event) {
    const selectedView = event.target.value;
    fetchData(selectedView);
  });

  // Fetch data views when the page loads
  populateViewsDropdown();
  fetchData();
  populateCustomersDropdown();
});
