/**
 * File: app.js (adventureforms/adventureview)
 * Purpose: Express.js application server for Adventure Forms data visualization and management
 * 
 * Description:
 * This file implements the main Express.js server for the Adventure Forms application,
 * providing API endpoints for data retrieval, view management, and database interactions.
 * It serves as the backend for a data visualization platform with dynamic view selection.
 * 
 * Logic:
 * - Configures Express server with middleware for logging, parsing, and static file serving
 * - Implements RESTful API endpoint (/api/data) for dynamic data retrieval
 * - Integrates with database module for data persistence and queries
 * - Handles query parameters for view selection and data filtering
 * - Provides error handling and JSON response formatting
 * 
 * Security Considerations:
 * - CRITICAL: Query parameter injection - 'view' parameter used directly in database queries
 * - CRITICAL: Database module integration - SQL injection risks if queries not parameterized
 * - CRITICAL: Body parser - vulnerable to JSON payload attacks and request size DoS
 * - CRITICAL: Static file serving - potential directory traversal vulnerabilities
 * - CRITICAL: Cookie parser - validate and sanitize all cookie data
 * - CRITICAL: Error handling - may expose database schema or connection information
 * - View parameter should be validated against allowed values
 * - Database queries must use parameterized statements
 * - Input validation required for all API endpoints
 */

const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const indexRouter = require('./routes/index');
const db = require('./db'); // Assuming you have a db module to interact with the database

const app = express();

app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);

// New route to fetch data based on the selected view
app.get('/api/data', async (req, res) => {
  const view = req.query.view || 'defaultView'; // Replace 'defaultView' with your default view name
  try {
    const data = await db.getData(view); // Assuming getData(view) fetches data for the specified view
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch data' });
  }
});

// catch 404 and forward to error handler
app.use((req, res, next) => {
  const err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use((err, req, res, next) => {
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
