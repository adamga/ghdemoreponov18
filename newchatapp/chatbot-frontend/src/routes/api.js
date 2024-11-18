const express = require('express');
const router = express.Router();

// Import the necessary modules for calling the .NET Core 5 API service and interfacing with Azure OpenAI
const dotnetApiService = require('../services/dotnetApiService');
const azureOpenAIService = require('../services/azureOpenAIService');

// Define the API routes
router.get('/query', async (req, res) => {
  try {
    // Get the query from the request parameters
    const query = req.query.query;

    // Call the .NET Core 5 API service to process the query
    const dotnetApiResponse = await dotnetApiService.processQuery(query);

    // Get the response from the .NET Core 5 API service
    const response = dotnetApiResponse.data;

    // Use Azure OpenAI to generate a chatbot response based on the query
    const chatbotResponse = await azureOpenAIService.generateResponse(query);

    // Send the response back to the client
    res.json({ response, chatbotResponse });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'An error occurred' });
  }
});

module.exports = router;