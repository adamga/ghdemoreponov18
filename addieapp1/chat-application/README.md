# Chat Application

This project is a chat application built with Node.js for the client-side and a C# .NET Core API for the backend. The application utilizes Azure OpenAI services to respond to user inquiries in a chat format.

## Project Structure

```
chat-application
├── api
│   ├── Controllers
│   │   └── ChatController.cs
│   ├── Models
│   │   └── ChatRequest.cs
│   ├── Services
│   │   └── OpenAIService.cs
│   ├── Program.cs
│   ├── Startup.cs
│   ├── appsettings.json
│   └── ChatApplication.csproj
├── client
│   ├── public
│   │   └── index.html
│   ├── src
│   │   ├── App.js
│   │   ├── index.js
│   │   └── components
│   │       └── ChatComponent.js
│   ├── package.json
│   └── webpack.config.js
└── .gitignore
```

## Setup Instructions

### API Setup

1. Navigate to the `api` directory.
2. Restore the dependencies using the command:
   ```
   dotnet restore
   ```
3. Configure your Azure OpenAI service credentials in `appsettings.json`.
4. Run the API using the command:
   ```
   dotnet run
   ```

### Client Setup

1. Navigate to the `client` directory.
2. Install the dependencies using npm:
   ```
   npm install
   ```
3. Start the client application:
   ```
   npm start
   ```

## Usage

- Open your browser and navigate to `http://localhost:3000` to access the chat interface.
- Type your inquiries in the chat input and receive responses powered by Azure OpenAI services.

## Contributing

Feel free to submit issues or pull requests for improvements and bug fixes.

## License

This project is licensed under the MIT License.