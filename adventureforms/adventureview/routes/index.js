const express = require('express');
const router = express.Router();
const sql = require('mssql');

// Database configuration
const config = {
  user: 'adamga',
  password: 'Squire560!!!!!!',
  server: 'ghcpdemoserver.database.windows.net',
  database: 'adv',
  options: {
    encrypt: true, // Use encryption
    enableArithAbort: true
  }
};

// Function to handle errors
function handleError(res, error) {
  console.error(error);
  res.status(500).json({ success: false, message: 'An error occurred', error: error.message });
}

// Route to view data
router.get('/data', async (req, res) => {
  try {
    let pool = await sql.connect(config);
    let result = await pool.request().query('SELECT * FROM YourTable');
    res.json(result.recordset);
  } catch (error) {
    handleError(res, error);
  } finally {
    sql.close();
  }
});

// Route to add data
router.post('/data', async (req, res) => {
  try {
    const { firstName, lastName, email } = req.body;
    const query = `INSERT INTO YourTable (FirstName, LastName, Email) VALUES ('${firstName}', '${lastName}', '${email}')`;
    let pool = await sql.connect(config);
    await pool.request().query(query);
    res.json({ success: true, message: 'Data added successfully' });
  } catch (error) {
    handleError(res, error);
  } finally {
    sql.close();
  }
});

// Route to edit data
router.put('/data/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { firstName, lastName, email } = req.body;
    const query = `UPDATE YourTable SET FirstName = '${firstName}', LastName = '${lastName}', Email = '${email}' WHERE Id = ${id}`;
    let pool = await sql.connect(config);
    await pool.request().query(query);
    res.json({ success: true, message: 'Data updated successfully' });
  } catch (error) {
    handleError(res, error);
  } finally {
    sql.close();
  }
});

// Route to delete data
router.delete('/data/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const query = `DELETE FROM YourTable WHERE Id = ${id}`;
    let pool = await sql.connect(config);
    await pool.request().query(query);
    res.json({ success: true, message: 'Data deleted successfully' });
  } catch (error) {
    handleError(res, error);
  } finally {
    sql.close();
  }
});

// Route to search data
router.get('/data/search', async (req, res) => {
  try {
    const { query } = req.query;
    let pool = await sql.connect(config);
    let result = await pool.request().query(`SELECT * FROM YourTable WHERE FirstName LIKE '%${query}%' OR LastName LIKE '%${query}%' OR Email LIKE '%${query}%'`);
    res.json(result.recordset);
  } catch (error) {
    handleError(res, error);
  } finally {
    sql.close();
  }
});

module.exports = router;
