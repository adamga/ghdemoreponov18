/**
 * File: index.js (routes)
 * Purpose: Express.js router handling album data retrieval and display via Dapr service mesh
 * 
 * Description:
 * This file implements the main routing logic for the album viewer application. It handles
 * HTTP requests to fetch album data from a backend service through Dapr (Distributed Application Runtime)
 * and renders the results using Pug templates.
 * 
 * Logic:
 * - Configures environment variables for Dapr service communication
 * - Defines GET route handler for home page ("/")
 * - Makes HTTP requests to album-api service via Dapr sidecar
 * - Processes response data and renders index template with album information
 * - Implements error handling with Express error middleware
 * 
 * Security Considerations:
 * - CRITICAL: HTTP requests to localhost services - validate all URLs and ports
 * - CRITICAL: Environment variable injection - sanitize all environment inputs
 * - CRITICAL: Axios HTTP client - vulnerable to SSRF, request smuggling, and injection attacks
 * - CRITICAL: Response data rendering - potential XSS if album data contains malicious content
 * - CRITICAL: Error handling may expose sensitive information in error messages
 * - Dapr service mesh communication should use authentication and authorization
 * - Hardcoded localhost URLs may be vulnerable to DNS rebinding attacks
 * - Template rendering with unvalidated data poses XSS risks
 */

var express = require("express");
var router = express.Router();
require("dotenv").config();
const axios = require("axios");

const DaprHttpPort = process.env.DAPR_HTTP_PORT || "3500";
const AlbumService = process.env.ALBUM_API_NAME || "album-api";
const Background = process.env.BACKGROUND_COLOR || "black";

/* GET home page. */
router.get("/", async function (req, res, next) {
  try {
    const url = `http://127.0.0.1:${DaprHttpPort}/v1.0/invoke/${AlbumService}/method/albums`;
    console.log("Invoking album-api via dapr: " + url);
    axios.headers = { "Content-Type": "application/json" };
    var response = await axios.get(url);
    data = response.data || [];
    console.log("Response from backend albums api: ", data);
    res.render("index", {
      albums: data,
      background_color: Background,
    });
  } catch (err) {
    console.log("Error: ", err);
    next(err);
  }
});

module.exports = router;
