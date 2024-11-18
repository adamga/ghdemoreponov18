const express = require('express');
const router = express.Router();
const DataAccess = require('../../FormsApp/DataAccess');

// Function to handle errors
function handleError(res, error) {
  console.error(error);
  res.status(500).json({ success: false, message: 'An error occurred', error: error.message });
}

// Route to view data
router.get('/data', async (req, res) => {
  try {
    const dataAccess = new DataAccess();
    const data = await dataAccess.GetData('SELECT * FROM YourTable');
    res.json(data);
  } catch (error) {
    handleError(res, error);
  }
});

// Route to add data
router.post('/data', async (req, res) => {
  try {
    const dataAccess = new DataAccess();
    const { firstName, lastName, email } = req.body;
    const query = `INSERT INTO YourTable (FirstName, LastName, Email) VALUES ('${firstName}', '${lastName}', '${email}')`;
    await dataAccess.InsertData(query);
    res.json({ success: true, message: 'Data added successfully' });
  } catch (error) {
    handleError(res, error);
  }
});

// Route to edit data
router.put('/data/:id', async (req, res) => {
  try {
    const dataAccess = new DataAccess();
    const { id } = req.params;
    const { firstName, lastName, email } = req.body;
    const query = `UPDATE YourTable SET FirstName = '${firstName}', LastName = '${lastName}', Email = '${email}' WHERE Id = ${id}`;
    await dataAccess.UpdateData(query);
    res.json({ success: true, message: 'Data updated successfully' });
  } catch (error) {
    handleError(res, error);
  }
});

// Route to delete data
router.delete('/data/:id', async (req, res) => {
  try {
    const dataAccess = new DataAccess();
    const { id } = req.params;
    const query = `DELETE FROM YourTable WHERE Id = ${id}`;
    await dataAccess.DeleteData(query);
    res.json({ success: true, message: 'Data deleted successfully' });
  } catch (error) {
    handleError(res, error);
  }
});

// Route to search data
router.get('/data/search', async (req, res) => {
  try {
    const dataAccess = new DataAccess();
    const { query } = req.query;
    const data = await dataAccess.GetData(`SELECT * FROM YourTable WHERE FirstName LIKE '%${query}%' OR LastName LIKE '%${query}%' OR Email LIKE '%${query}%'`);
    res.json(data);
  } catch (error) {
    handleError(res, error);
  }
});

module.exports = router;
