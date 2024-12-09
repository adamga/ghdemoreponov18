const express = require('express');
const app = require('./app');
const http = require('http');
const db = require('./db'); // Assuming you have a db module to interact with the database

const port = process.env.PORT || 3000;
app.set('port', port);

const server = http.createServer(app);

server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

server.on('error', (error) => {
  if (error.syscall !== 'listen') {
    throw error;
  }

  const bind = typeof port === 'string' ? 'Pipe ' + port : 'Port ' + port;

  // handle specific listen errors with friendly messages
  switch (error.code) {
    case 'EACCES':
      console.error(bind + ' requires elevated privileges');
      process.exit(1);
      break;
    case 'EADDRINUSE':
      console.error(bind + ' is already in use');
      process.exit(1);
      break;
    default:
      throw error;
  }
});

// New route to fetch data views
app.get('/api/views', async (req, res) => {
  try {
    const views = await db.getViews(); // Assuming getViews() fetches the list of views from the database
    res.json(views);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch views' });
  }
});