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

// New: simple API endpoint for "Hello World"
app.get('/api/hello', (req, res) => {
  res.json({ message: 'Hello World' });
});

// New: minimal UI page with a "Hello World" button
app.get('/hello', (req, res) => {
  res.type('html').send(`
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Hello</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
  </head>
  <body style="font-family: system-ui, sans-serif; padding: 24px;">
    <button id="helloBtn" type="button" aria-label="Hello World">Hello World</button>
    <pre id="out" style="margin-top: 16px;"></pre>

    <script>
      const btn = document.getElementById('helloBtn');
      const out = document.getElementById('out');

      btn.addEventListener('click', async () => {
        out.textContent = 'Loading...';
        try {
          const r = await fetch('/api/hello');
          if (!r.ok) {
            throw new Error('Request failed');
          }
          const data = await r.json();
          out.textContent = data.message;
        } catch (error) {
          out.textContent = 'Error: ' + error.message;
        }
      });
    </script>
  </body>
</html>
  `.trim());
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
