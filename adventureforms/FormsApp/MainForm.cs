using System;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace FormsApp
{
    public partial class MainForm : Form
    {
        private SqlDataAdapter dataAdapter;
        private DataTable dataTable;
        private BindingSource bindingSource;

        public MainForm()
        {
            InitializeComponent();
            InitializeBindingSource();
            InitializeDataGridView();
            LoadViews();
            viewComboBox.SelectedIndexChanged += viewComboBox_SelectedIndexChanged;
        }

        private void InitializeDataGridView()
        {
            dataGridView.DataSource = bindingSource;
            dataGridView.AutoGenerateColumns = true;
            dataGridView.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dataGridView.MultiSelect = false;
        }

        private void InitializeBindingSource()
        {
            bindingSource = new BindingSource();
        }

        private void LoadData(string query)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["AdventureWorks2014"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                dataAdapter = new SqlDataAdapter(query, connection);
                SqlCommandBuilder commandBuilder = new SqlCommandBuilder(dataAdapter);

                dataTable = new DataTable();
                dataAdapter.Fill(dataTable);
                bindingSource.DataSource = dataTable;
            }
        }

        private void LoadViews()
        {
            DataAccess dataAccess = new DataAccess();
            DataTable viewsTable = dataAccess.GetData("SELECT TABLE_SCHEMA + '.' + TABLE_NAME AS FullViewName FROM INFORMATION_SCHEMA.VIEWS");

            viewComboBox.Items.Clear();
            foreach (DataRow row in viewsTable.Rows)
            {
                viewComboBox.Items.Add(row["FullViewName"].ToString());
            }

            if (viewComboBox.Items.Count > 0)
            {
                viewComboBox.SelectedIndex = 0;
            }
        }

        private void SaveData()
        {
            try
            {
                bindingSource.EndEdit();
                dataAdapter.Update((DataTable)bindingSource.DataSource);
            }
            catch (Exception ex)
            {
                // Log the exception (you can replace this with your logging mechanism)
                Console.WriteLine($"Error saving data: {ex.Message}");
                throw;
            }
        }

        private void addButton_Click(object sender, EventArgs e)
        {
            DataRow newRow = dataTable.NewRow();
            // Populate newRow with data from input controls
            dataTable.Rows.Add(newRow);
        }

        private void editButton_Click(object sender, EventArgs e)
        {
            if (dataGridView.SelectedRows.Count > 0)
            {
                DataRow row = ((DataRowView)dataGridView.SelectedRows[0].DataBoundItem).Row;
                // Populate input controls with data from row
            }
        }

        private void deleteButton_Click(object sender, EventArgs e)
        {
            if (dataGridView.SelectedRows.Count > 0)
            {
                DataRow row = ((DataRowView)dataGridView.SelectedRows[0].DataBoundItem).Row;
                row.Delete();
            }
        }

        private void saveButton_Click(object sender, EventArgs e)
        {
            dataTable.AcceptChanges();
            SaveData();
        }

        private void cancelButton_Click(object sender, EventArgs e)
        {
            dataTable.RejectChanges();
        }

        private void searchButton_Click(object sender, EventArgs e)
        {
            string filter = searchTextBox.Text;
            bindingSource.Filter = $"LastName LIKE '%{filter}%'"; // Example filter
        }

        private void viewComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selectedView = viewComboBox.SelectedItem.ToString();
            LoadData($"SELECT * FROM {selectedView}");
        }
    }
}
