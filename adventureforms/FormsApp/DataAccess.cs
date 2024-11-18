using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace FormsApp
{
    public class DataAccess
    {
        private string connectionString;

        public DataAccess()
        {
            connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["AdventureWorks2014"].ConnectionString;
        }

        public DataTable GetData(string query)
        {
            if (!query.Contains("."))
            {
                //throw new ArgumentException("Query must include the schema name.");
            }

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    SqlDataAdapter dataAdapter = new SqlDataAdapter(query, connection);
                    DataTable dataTable = new DataTable();
                    dataAdapter.Fill(dataTable);
                    return dataTable;
                }
            }
            catch (SqlException ex)
            {
                // Log the exception (you can replace this with your logging mechanism)
                Console.WriteLine($"SQL Error: {ex.Message}");
                throw;
            }
        }

        public void UpdateData(string query, DataTable dataTable)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    SqlDataAdapter dataAdapter = new SqlDataAdapter(query, connection);
                    SqlCommandBuilder commandBuilder = new SqlCommandBuilder(dataAdapter);
                    dataAdapter.Update(dataTable);
                }
            }
            catch (SqlException ex)
            {
                // Log the exception (you can replace this with your logging mechanism)
                Console.WriteLine($"SQL Error: {ex.Message}");
                throw;
            }
        }

        public void InsertData(string query, DataTable dataTable)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlDataAdapter dataAdapter = new SqlDataAdapter(query, connection);
                SqlCommandBuilder commandBuilder = new SqlCommandBuilder(dataAdapter);
                dataAdapter.Update(dataTable);
            }
        }

        public void DeleteData(string query, DataTable dataTable)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlDataAdapter dataAdapter = new SqlDataAdapter(query, connection);
                SqlCommandBuilder commandBuilder = new SqlCommandBuilder(dataAdapter);
                dataAdapter.Update(dataTable);
            }
        }

        public bool ValidateData(DataRow dataRow, string[] requiredFields, int[] maxLengths, string[] dataTypes)
        {
            foreach (string field in requiredFields)
            {
                if (dataRow[field] == DBNull.Value || string.IsNullOrEmpty(dataRow[field].ToString()))
                {
                    return false;
                }
            }

            for (int i = 0; i < maxLengths.Length; i++)
            {
                if (dataRow[requiredFields[i]].ToString().Length > maxLengths[i])
                {
                    return false;
                }
            }

            for (int i = 0; i < dataTypes.Length; i++)
            {
                if (dataTypes[i] == "int" && !int.TryParse(dataRow[requiredFields[i]].ToString(), out _))
                {
                    return false;
                }
                else if (dataTypes[i] == "datetime" && !DateTime.TryParse(dataRow[requiredFields[i]].ToString(), out _))
                {
                    return false;
                }
            }

            return true;
        }

        public List<string> GetViews()
        {
            List<string> views = new List<string>();
            string query = "SELECT TABLE_SCHEMA + '.' + TABLE_NAME AS FullViewName FROM INFORMATION_SCHEMA.VIEWS";

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    SqlCommand command = new SqlCommand(query, connection);
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        views.Add(reader["FullViewName"].ToString());
                    }
                }
            }
            catch (SqlException ex)
            {
                // Log the exception (you can replace this with your logging mechanism)
                Console.WriteLine($"SQL Error: {ex.Message}");
                throw;
            }

            return views;
        }
    }
}
