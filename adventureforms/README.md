# AdventureForms

## Detailed Explanation

AdventureForms is a Windows Forms application that connects to the AdventureWorks2014 database. The application allows users to view, edit, add, and delete data from the database. It provides a user-friendly interface to interact with the data stored in the AdventureWorks2014 database.

### Purpose

The purpose of AdventureForms is to provide a simple and intuitive way for users to manage data in the AdventureWorks2014 database. It is designed to be used by individuals who need to perform CRUD (Create, Read, Update, Delete) operations on the database without having to write SQL queries manually.

### Functionality

- **View Data**: Users can view data from the AdventureWorks2014 database in a DataGridView.
- **Add Data**: Users can add new records to the database.
- **Edit Data**: Users can edit existing records in the database.
- **Delete Data**: Users can delete records from the database.
- **Search Data**: Users can search for specific records in the database.

## Instructions on How to Run the App

### Prerequisites

1. **Visual Studio**: Ensure you have Visual Studio installed on your machine. You can download it from [Visual Studio Downloads](https://visualstudio.microsoft.com/downloads/).
2. **SQL Server**: Ensure you have SQL Server installed and running on your machine. You can download it from [SQL Server Downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads).
3. **AdventureWorks2014 Database**: Ensure you have the AdventureWorks2014 database installed on your SQL Server instance. You can download the database from [AdventureWorks Sample Databases](https://github.com/microsoft/sql-server-samples/releases/tag/adventureworks).

### Steps to Run the App

1. **Clone the Repository**: Clone the repository to your local machine using the following command:
   ```sh
   git clone https://github.com/adamga/adventureforms.git
   ```

2. **Open the Solution**: Open the `AdventureForms.sln` file in Visual Studio.

3. **Update Connection String**: Update the connection string in the `app.config` file located in the `FormsApp` project. Replace `YOUR_SERVER_NAME` with the name of your SQL Server instance.
   ```xml
   <connectionStrings configProtectionProvider="DataProtectionConfigurationProvider">
     <add name="AdventureWorks2014" connectionString="Data Source=YOUR_SERVER_NAME;Initial Catalog=AdventureWorks2014;Integrated Security=True" providerName="System.Data.SqlClient" />
   </connectionStrings>
   ```

4. **Build the Solution**: Build the solution in Visual Studio by clicking on `Build` > `Build Solution` or by pressing `Ctrl+Shift+B`.

5. **Run the App**: Run the application by clicking on `Debug` > `Start Debugging` or by pressing `F5`.

6. **Use the App**: Once the application is running, you can use the various features to view, add, edit, delete, and search data in the AdventureWorks2014 database.

### Troubleshooting

- **Connection Issues**: If you encounter connection issues, ensure that your SQL Server instance is running and that the connection string in the `app.config` file is correct.
- **Missing Database**: If the AdventureWorks2014 database is not installed, download and install it from the [AdventureWorks Sample Databases](https://github.com/microsoft/sql-server-samples/releases/tag/adventureworks).

# AdventureView

## Detailed Explanation

AdventureView is a web front end application that connects to the AdventureWorks2014 database. The application allows users to view, edit, add, and delete data from the database through a web interface. It provides a user-friendly interface to interact with the data stored in the AdventureWorks2014 database using Bootstrap for styling and Node.js for server-side logic.

### Purpose

The purpose of AdventureView is to provide a simple and intuitive way for users to manage data in the AdventureWorks2014 database through a web interface. It is designed to be used by individuals who need to perform CRUD (Create, Read, Update, Delete) operations on the database without having to write SQL queries manually.

### Functionality

- **View Data**: Users can view data from the AdventureWorks2014 database in a table format.
- **Add Data**: Users can add new records to the database through a form.
- **Edit Data**: Users can edit existing records in the database through an intuitive interface.
- **Delete Data**: Users can delete records from the database with confirmation prompts to prevent accidental deletions.
- **Search Data**: Users can search for specific records in the database based on various criteria.
- **Responsive Design**: The web front end is responsive and works well on different devices, including desktops, tablets, and mobile phones.
- **Error Handling**: The application implements error handling to display user-friendly error messages when something goes wrong.
- **Data Validation**: The application validates user input to ensure data integrity and prevent invalid data from being submitted.
- **Pagination**: The application implements pagination for large datasets to improve performance and user experience.
- **Sorting and Filtering**: Users can sort and filter data based on different columns or criteria.
- **User Authentication**: The application implements user authentication to restrict access to certain features based on user roles.
- **Bootstrap Integration**: The application uses Bootstrap for styling and layout to create a modern and visually appealing interface.
- **Node.js Backend**: The application uses Node.js to handle server-side logic and interact with the database.

## Instructions on How to Run the App

### Prerequisites

1. **Node.js**: Ensure you have Node.js installed on your machine. You can download it from [Node.js Downloads](https://nodejs.org/en/download/).
2. **SQL Server**: Ensure you have SQL Server installed and running on your machine. You can download it from [SQL Server Downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads).
3. **AdventureWorks2014 Database**: Ensure you have the AdventureWorks2014 database installed on your SQL Server instance. You can download the database from [AdventureWorks Sample Databases](https://github.com/microsoft/sql-server-samples/releases/tag/adventureworks).

### Steps to Run the App

1. **Clone the Repository**: Clone the repository to your local machine using the following command:
   ```sh
   git clone https://github.com/adamga/adventureforms.git
   ```

2. **Navigate to the AdventureView Folder**: Navigate to the `adventureview` folder within the `adventureforms` directory.
   ```sh
   cd adventureforms/adventureview
   ```

3. **Install Dependencies**: Install the necessary dependencies using npm.
   ```sh
   npm install
   ```

4. **Update Database Connection**: Update the database connection settings in the `app.js` file to match your SQL Server instance and AdventureWorks2014 database.

5. **Start the Application**: Start the application using npm.
   ```sh
   npm start
   ```

6. **Access the Application**: Open your web browser and navigate to `http://localhost:3000` to access the AdventureView application.

### Troubleshooting

- **Connection Issues**: If you encounter connection issues, ensure that your SQL Server instance is running and that the database connection settings in the `app.js` file are correct.
- **Missing Database**: If the AdventureWorks2014 database is not installed, download and install it from the [AdventureWorks Sample Databases](https://github.com/microsoft/sql-server-samples/releases/tag/adventureworks).
