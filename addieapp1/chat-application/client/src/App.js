import React, { useState } from 'react';
import ChatComponent from './components/ChatComponent';

function App() {
    const [messages, setMessages] = useState([]);

    const addMessage = (message) => {
        setMessages((prevMessages) => [...prevMessages, message]);
    };

    return (
        <div className="App">
            <h1>Chat Application</h1>
            <ChatComponent messages={messages} addMessage={addMessage} />
        </div>
    );
}

export default App;