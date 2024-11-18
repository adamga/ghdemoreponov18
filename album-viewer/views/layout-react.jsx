import React from 'react';
import './App.css';

const App = () => {
  const handleButtonClick = (url) => {
    window.open(url, '_blank');
  };

  return (
    <div className="ui container">
      <head>
        <meta
          http-equiv="Content-Security-Policy"
          content="default-src 'self'; script-src 'self'; style-src 'self' https://cdn.rtlcss.com; img-src 'self'; connect-src 'self'; font-src 'self'; frame-src 'none';"
        />
        <link
          rel="stylesheet"
          href="https://cdn.rtlcss.com/semantic-ui/2.4.1/semantic.rtl.min.css"
          integrity="sha384-<HASH>"
          crossorigin="anonymous"
        />
        <link rel="stylesheet" href="/stylesheets/style.css" />
        <script type="text/javascript" src="app.js"></script>
      </head>
      <body>
        <div className="ui container">
          <h2 className="ui center aligned icon block header">
            <i className="music icon"></i>
            <h1>Azure Container Apps Albums</h1>
          </h2>
          <div className="four ui buttons">
            <button
              className="ui button"
              onClick={() => handleButtonClick('https://aka.ms/aca-docs')}
            >
              Docs
            </button>
            <button
              className="ui button"
              onClick={() => handleButtonClick('https://aka.ms/aca-roadmap')}
            >
              Public Roadmap
            </button>
            <button
              className="ui button"
              onClick={() => handleButtonClick('https://aka.ms/containerapps-discord')}
            >
              Discord
            </button>
            <button
              className="ui button"
              onClick={() => handleButtonClick('https://aka.ms/aca-mailinglist')}
            >
              Mailing List
            </button>
          </div>
        </div>
      </body>
    </div>
  );
};

export default App;