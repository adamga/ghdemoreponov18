/**
 * File: app.js
 * Purpose: Main Express.js application server for the album viewer web application
 * 
 * Description:
 * This file sets up and configures the Express.js web server for the album viewer application.
 * It handles middleware configuration, view engine setup, routing, and error handling for
 * a web application that displays and manages album information.
 * 
 * Logic:
 * - Creates Express application instance with middleware stack
 * - Configures Pug templating engine for view rendering
 * - Sets up static file serving from public directory
 * - Configures request logging, JSON parsing, and cookie handling
 * - Routes requests to appropriate handlers via indexRouter
 * - Implements error handling for 404 and server errors
 * 
 * Security Considerations:
 * - CRITICAL: Express server exposed to network - ensure proper input validation
 * - CRITICAL: Static file serving - potential for directory traversal attacks
 * - CRITICAL: Cookie parser - validate and sanitize all cookie data
 * - CRITICAL: JSON parsing - vulnerable to JSON injection and large payload DoS
 * - CRITICAL: Morgan logger may log sensitive information in requests
 * - CRITICAL: Error handling may expose stack traces in production
 * - Pug templating engine requires careful handling to prevent XSS
 * - Environment variable access should be validated and sanitized
 */

var createError = require("http-errors");
var express = require("express");
var path = require("path");
var cookieParser = require("cookie-parser");
var logger = require("morgan");

var indexRouter = require("./routes/index");

var app = express();

app.set("env", process.env.NODE_ENV);

app.use(express.static(path.join(__dirname, "public")));

// view engine setup
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "pug");

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

app.use("/", indexRouter);

// catch 404 and forward to error handler
app.use((req, res, next) => {
  next(createError(404));
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = process.env.NODE_ENV === "development" ? err : {};

  if (err.status === 404) {
    res.status(404).render("error", {
      title: "The path " + req.path + " does not exist on this site",
      error: err,
      message: err.message,
      color: "yellow",
    });
  } else if (err.response) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx
    res.status(403).render("error", {
      title:
        "Server responded with an error when trying to access " +
        err.config.url,
      error: err,
      message: err.message,
      color: "red",
    });
  } else if (err.request) {
    // The request was made but no response was received
    res.status(503).render("error", {
      title: "Unable to communicate with server",
      error: err,
      message: err.message,
      color: "red",
    });
  } else {
    // Something happened in setting up the request that triggered an Error
    res.status(500).render("error", {
      title: "An unexpected error occurred",
      error: err,
      message: err.message,
      color: "red",
    });
  }
});

module.exports = app;
