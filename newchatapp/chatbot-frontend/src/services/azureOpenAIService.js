// azureOpenAIService.js

// This module provides a service for interfacing with Azure OpenAI

const axios = require('axios');

// Function to make a request to the Azure OpenAI API
async function makeOpenAIRequest(input) {
  try {
    const response = await axios.post('https://api.openai.com/v1/chat/completions', {
      prompt: input,
      max_tokens: 50,
      temperature: 0.7,
    }, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_OPENAI_API_KEY',
      },
    });

    return response.data.choices[0].text.trim();
  } catch (error) {
    console.error('Error making request to Azure OpenAI:', error);
    throw error;
  }
}

module.exports = {
  makeOpenAIRequest,
};