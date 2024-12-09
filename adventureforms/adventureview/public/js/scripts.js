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
});
