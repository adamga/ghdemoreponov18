// app.js

// Import required modules
const express = require('express');
const path = require('path');
const apiRoutes = require('./routes/api');

// Create an Express application
const app = express();

// Set up middleware
app.use(express.static(path.join(__dirname, '../public')));

// Set up API routes
app.use('/api', apiRoutes);

// Set up default route
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Start the server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});