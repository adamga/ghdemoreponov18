# FILE: ADV_DB/test_HumanResources.vEmployee.View.sql

import pyodbc
import pytest

@pytest.fixture(scope="module")
def db_connection():
    conn = pyodbc.connect('DRIVER={SQL Server};SERVER=your_server;DATABASE=AdventureWorks2014;UID=your_username;PWD=your_password')
    yield conn
    conn.close()

def test_vEmployee_view(db_connection):
    cursor = db_connection.cursor()
    
    # Create a test database and copy schema and data
    cursor.execute("CREATE DATABASE TestDB")
    cursor.execute("USE TestDB")
    cursor.execute("EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all'")
    cursor.execute("EXEC sp_MSforeachtable 'DROP TABLE ?'")
    cursor.execute("EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT all'")
    cursor.execute("USE AdventureWorks2014")
    cursor.execute("EXEC sp_MSforeachtable 'SELECT * INTO TestDB.? FROM ?'")
    cursor.execute("USE TestDB")
    
    # Execute the view
    cursor.execute("SELECT * FROM HumanResources.vEmployee")
    rows = cursor.fetchall()
    
    # Validate the results
    assert len(rows) > 0, "No data returned from the view"
    
    for row in rows:
        assert row.BusinessEntityID is not None
        assert row.FirstName is not None
        assert row.LastName is not None
        assert row.JobTitle is not None
    
    # Clean up the test database
    cursor.execute("USE master")
    cursor.execute("DROP DATABASE TestDB")