# Chatbot Frontend

This project is a front-end chatbot that calls a .NET Core 5 API service, which interfaces with Azure OpenAI. The project also includes a Cosmos DB database to store query history.

## Project Structure

```
chatbot-frontend
├── public
│   ├── css
│   │   └── styles.css
│   ├── js
│   │   └── scripts.js
│   └── index.html
├── src
│   ├── app.js
│   ├── routes
│   │   └── api.js
│   └── services
│       └── azureOpenAIService.js
├── package.json
├── README.md
└── .env
```

## File Descriptions

- `public/css/styles.css`: This file contains the CSS styles for the chatbot frontend.

- `public/js/scripts.js`: This file contains the JavaScript code for the chatbot frontend.

- `public/index.html`: This file is the main HTML file for the chatbot frontend. It includes the necessary CSS and JavaScript files and provides the structure for the chatbot UI.

- `src/app.js`: This file is the entry point of the Node.js application. It sets up the server and handles the routing for the chatbot frontend.

- `src/routes/api.js`: This file exports a module that defines the API routes for the .NET Core 5 API service. It handles the communication between the chatbot frontend and the API service.

- `src/services/azureOpenAIService.js`: This file exports a module that provides a service for interfacing with Azure OpenAI. It contains functions for making requests to the Azure OpenAI API.

- `package.json`: This file is the configuration file for npm. It lists the dependencies and scripts for the project.

- `README.md`: This file contains the documentation for the project.

- `.env`: This file is used to store environment variables. It may contain configuration settings for connecting to the Cosmos DB database and other sensitive information.

## Getting Started

To run the chatbot frontend, follow these steps:

1. Clone the repository.

2. Install the dependencies by running `npm install`.

3. Set up the environment variables in the `.env` file.

4. Start the server by running `npm start`.

5. Open your browser and navigate to `http://localhost:3000` to access the chatbot frontend.

## Dependencies

The project uses the following dependencies:

- Bootstrap: A CSS framework for building responsive UI elements.

- Express: A fast, unopinionated web framework for Node.js.

- Axios: A promise-based HTTP client for making API requests.

- dotenv: A module for loading environment variables from a `.env` file.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more information.