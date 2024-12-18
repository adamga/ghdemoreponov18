### ****Introduction to GitHub Copilot for Data Analysts and Developers****

### **1. Introduction to GitHub Copilot**
- **Overview of GitHub Copilot**: What it is and how it works.
- **Key Features**: Code completion, code suggestions, and contextual help.

### **2. Using GitHub Copilot for Database Development**
- **SQL Code Assistance**: How Copilot can help write and optimize SQL queries.
- **Database Schema Design**: Generating database schema and table definitions.
- **Data Modeling**: Assisting in creating ER diagrams and data models.

### **3. Enhancing Productivity with Copilot**
- **Code Review and Refactoring**: Using Copilot to review and refactor existing code.
- **Debugging Assistance**: Helping identify and fix database-related issues.
- **Automating Repetitive Tasks**: Streamlining common database tasks with Copilot.

### **4. Using GitHub Copilot with Business Intelligence Tools**
- **Data Extraction and Transformation**: Using Copilot to assist with ETL processes.
- **Creating Reports and Dashboards**: Generating SQL queries for BI tools like Power BI and Tableau.
- **Data Analysis**: Assisting in writing complex analytical queries.

### **5. Solving database-related problems**
- **Practical Scenarios**: Real-world scenarios where participants can use Copilot to solve database-related problems.






# **Using GitHub Copilot for Database Development**

## **Task 1: Writing SQL Queries**

### **Step-by-Step Instructions**
1. **Open Visual Studio Code (VS Code)**:
   - Launch VS Code and open the project folder where you cloned the GitHub repository.
2. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `queries.sql` in your project folder.
3. **Connect to the Database**:
   - If you haven't already, install the `SQLTools` extension for VS Code.
   - Click on the SQLTools icon in the activity bar on the left side of the screen.
   - Configure a new connection by providing the database details (e.g., SQLite, MySQL).
4. **Write SQL Queries Using GitHub Copilot**:
   - **Select Query**: Start typing a comment to describe what you want. For example:
     ```sql
     -- Retrieve all records from the 'employees' table
     SELECT * FROM employees;
     ```
   - **Join Query**: Describe the join you want to perform. For example:
     ```sql
     -- Join 'employees' and 'departments' on the 'department_id' column
     SELECT e.name, d.department_name
     FROM employees e
     JOIN departments d ON e.department_id = d.id;
     ```
   - **Aggregate Query**: Explain the aggregation you need. For example:
     ```sql
     -- Calculate the average salary of employees
     SELECT AVG(salary) AS average_salary
     FROM employees;
     ```
5. **Use GitHub Copilot**:
   - As you type, GitHub Copilot will suggest code snippets. Accept the suggestions that fit your requirements by pressing `Tab`.
6. **Run and Validate the Queries**:
   - Execute the queries using SQLTools or your preferred method to ensure they work as expected.

## **Task 2: Designing a Database Schema**

### **Step-by-Step Instructions**
1. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `schema.sql` in your project folder.
2. **Use GitHub Copilot to Generate Schema**:
   - **Table Definitions**: Describe the tables you want to create. For example:
     ```sql
     -- Create 'employees' table with columns
     CREATE TABLE employees (
         id INT PRIMARY KEY,
         name VARCHAR(50),
         department_id INT,
         salary DECIMAL(10, 2)
     );
     ```
   - **Foreign Keys**: Set up relationships between tables. For example:
     ```sql
     -- Create 'departments' table and establish foreign key relationship
     CREATE TABLE departments (
         id INT PRIMARY KEY,
         department_name VARCHAR(50)
     );

     ALTER TABLE employees
     ADD CONSTRAINT fk_department
     FOREIGN KEY (department_id) REFERENCES departments(id);
     ```
3. **Use GitHub Copilot**:
   - As you type, GitHub Copilot will provide code suggestions. Accept the relevant suggestions by pressing `Tab`.
4. **Validate Schema**:
   - Execute the schema script to create the database structure. You can use SQLTools or another method to run the script.
5. **Review and Adjust**:
   - Check the generated schema and make any necessary adjustments to ensure it meets your requirements.

## **Task 3: Data Analysis and Reporting**

### **Step-by-Step Instructions**
1. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `report.sql` in your project folder.
2. **Use GitHub Copilot for Data Analysis**:
   - **Extract Data**: Describe the data you want to retrieve. For example:
     ```sql
     -- Retrieve employee names and salaries from the 'employees' table
     SELECT name, salary
     FROM employees;
     ```
   - **Transform Data**: Use functions to manipulate data. For example:
     ```sql
     -- Calculate the total salary expenditure per department
     SELECT d.department_name, SUM(e.salary) AS total_salary
     FROM employees e
     JOIN departments d ON e.department_id = d.id
     GROUP BY d.department_name;
     ```
   - **Generate Reports**: Create queries to produce meaningful reports. For example:
     ```sql
     -- Generate a report of average salary by department
     SELECT d.department_name, AVG(e.salary) AS average_salary
     FROM employees e
     JOIN departments d ON e.department_id = d.id
     GROUP BY d.department_name;
     ```
3. **Use GitHub Copilot**:
   - As you type, GitHub Copilot will suggest code snippets. Accept the suggestions that fit your requirements by pressing `Tab`.
4. **Export Reports**:
   - Save the results of the queries to a file (e.g., CSV). You can use the `OUTPUT` clause or export the results using your database management tool.
   - For example, in MySQL:
     ```sql
     SELECT d.department_name, AVG(e.salary) AS average_salary
     INTO OUTFILE '/path/to/output.csv'
     FIELDS TERMINATED BY ','
     LINES TERMINATED BY '\n'
     FROM employees e
     JOIN departments d ON e.department_id = d.id
     GROUP BY d.department_name;
     ```
5. **Review and Discuss**:
   - Review the generated reports and discuss any insights or potential improvements with your partner.




 

# **Using GitHub Copilot with Business Intelligence Tools**

### **Lab Overview**
In this lab, participants will explore how GitHub Copilot and GitHub Copilot Chat can assist with ETL (Extract, Transform, Load) processes, generating SQL queries for BI tools like Power BI and Tableau, and writing complex analytical queries.

### **Prerequisites**
- GitHub account
- Visual Studio Code (VS Code) installed with GitHub Copilot and GitHub Copilot Chat extensions
- Sample database (e.g., SQLite or MySQL)
- Power BI Desktop and/or Tableau Desktop installed

### **Lab Setup**
1. **Create a GitHub Repository**:
   - Create a new repository on GitHub for the lab exercises.
   - Clone the repository to your local machine.

2. **Install Required Tools**:
   - Install Visual Studio Code.
   - Install the GitHub Copilot and GitHub Copilot Chat extensions in VS Code.
   - Ensure Power BI Desktop and/or Tableau Desktop are installed.

### **Task 1: Data Extraction and Transformation**

### **Step-by-Step Instructions**
1. **Open Visual Studio Code (VS Code)**:
   - Launch VS Code and open the project folder where you cloned the GitHub repository.
2. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `etl_process.sql` in your project folder.
3. **Connect to the Database**:
   - If you haven't already, install the `SQLTools` extension for VS Code.
   - Click on the SQLTools icon in the activity bar on the left side of the screen.
   - Configure a new connection by providing the database details (e.g., SQLite, MySQL).
4. **Data Extraction Using GitHub Copilot**:
   - **Extract Data**: Start typing a comment to describe the data extraction. For example:
     ```sql
     -- Retrieve employee records from the 'employees' table
     SELECT * FROM employees WHERE hire_date > '2020-01-01';
     ```
   - **Transform Data**: Describe the transformations needed. For example:
     ```sql
     -- Calculate the yearly salary for each employee
     SELECT id, name, salary * 12 AS yearly_salary
     FROM employees;
     ```
   - **Load Data**: Describe how to load the data into a new table. For example:
     ```sql
     -- Load transformed data into 'employee_yearly_salaries' table
     CREATE TABLE employee_yearly_salaries AS
     SELECT id, name, salary * 12 AS yearly_salary
     FROM employees;
     ```
5. **Use GitHub Copilot**:
   - As you type, GitHub Copilot will suggest code snippets. Accept the suggestions that fit your requirements by pressing `Tab`.
6. **Run and Validate the ETL Process**:
   - Execute the queries to ensure they work as expected and validate the data in the new table.

### **Task 2: Creating Reports and Dashboards**

### **Step-by-Step Instructions**
1. **Open Power BI Desktop or Tableau Desktop**:
   - Launch Power BI Desktop or Tableau Desktop on your machine.
2. **Connect to the Database**:
   - In Power BI, click on `Home` > `Get Data` > `SQL Server` (or your database type) and connect to your database.
   - In Tableau, click on `Data` > `Connect to Data` > `SQL Server` (or your database type) and connect to your database.
3. **Create SQL Queries Using GitHub Copilot**:
   - **Generate SQL Queries**: Start typing a comment to describe the data you need for your report. For example:
     ```sql
     -- Generate a report of average salary by department
     SELECT d.department_name, AVG(e.salary) AS average_salary
     FROM employees e
     JOIN departments d ON e.department_id = d.id
     GROUP BY d.department_name;
     ```
4. **Use GitHub Copilot**:
   - As you type, GitHub Copilot will suggest SQL code snippets. Accept the suggestions that fit your requirements by pressing `Tab`.
5. **Load Data into Power BI/Tableau**:
   - In Power BI, use the `SQL Server` connector to load the data using the generated SQL queries.
   - In Tableau, use the `SQL Server` connector to load the data using the generated SQL queries.
6. **Create Visualizations**:
   - In Power BI, use the data to create various visualizations such as charts, tables, and graphs.
   - In Tableau, use the data to create visualizations by dragging and dropping fields onto the canvas.
7. **Design Dashboards**:
   - In Power BI, design a dashboard by pinning the visualizations to a dashboard.
   - In Tableau, design a dashboard by combining multiple visualizations into a single view.
8. **Review and Adjust**:
   - Review the generated reports and dashboards and make any necessary adjustments to improve clarity and insights.

### **Task 3: Data Analysis**

### **Step-by-Step Instructions**
1. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `data_analysis.sql` in your project folder.
2. **Use GitHub Copilot for Data Analysis**:
   - **Complex Queries**: Describe the complex analytical queries you need. For example:
     ```sql
     -- Calculate the retention rate of employees by department
     SELECT d.department_name, COUNT(e.id) AS total_employees,
     SUM(CASE WHEN e.termination_date IS NULL THEN 1 ELSE 0 END) AS retained_employees,
     (SUM(CASE WHEN e.termination_date IS NULL THEN 1 ELSE 0 END) / COUNT(e.id)) * 100 AS retention_rate
     FROM employees e
     JOIN departments d ON e.department_id = d.id
     GROUP BY d.department_name;
     ```
   - **Use GitHub Copilot**:
     - As you type, GitHub Copilot will suggest SQL code snippets. Accept the suggestions that fit your requirements by pressing `Tab`.
3. **Run and Validate the Queries**:
   - Execute the queries using SQLTools or your preferred method to ensure they work as expected and provide the needed insights.
4. **Export Results**:
   - Save the results of the queries to a file (e.g., CSV). For example, in MySQL:
     ```sql
     SELECT d.department_name, COUNT(e.id) AS total_employees,
     SUM(CASE WHEN e.termination_date IS NULL THEN 1 ELSE 0 END) AS retained_employees,
     (SUM(CASE WHEN e.termination_date IS NULL THEN 1 ELSE 0 END) / COUNT(e.id)) * 100 AS retention_rate
     INTO OUTFILE '/path/to/retention_rate.csv'
     FIELDS TERMINATED BY ','
     LINES TERMINATED BY '\n'
     FROM employees e
     JOIN departments d ON e.department_id = d.id
     GROUP BY d.department_name;
     ```
5. **Analyze Results**:
   - Review the exported results and analyze the data to gain insights and inform decision-making.
6. **Discuss and Report Findings**:
   - Discuss the findings with your partner and create a report summarizing the key insights.

### **Task 4: Using GitHub Copilot Chat for Assistance**

### **Step-by-Step Instructions**
1. **Enable GitHub Copilot Chat**:
   - Ensure that the GitHub Copilot Chat extension is installed and enabled in VS Code.
2. **Initiate a Chat**:
   - Open the GitHub Copilot Chat panel in VS Code.
3. **Ask Questions**:
   - Use GitHub Copilot Chat to ask for assistance on various tasks. For example:
     ```text
     How do I write a SQL query to calculate the average salary by department?
     ```
4. **Follow Suggestions**:
   - Review and follow the suggestions provided by GitHub Copilot Chat.
5. **Iterate and Refine**:
   - Use the chat to iteratively refine your queries and scripts. For example:
     ```text
     Can you help me optimize this query for better performance?
     ```
6. **Document Insights**:
   - Document the insights and learnings from using GitHub Copilot Chat in a separate file (e.g., `copilot_chat_insights.md`).

### **Task 5: Automating Workflows with GitHub Actions**

### **Step-by-Step Instructions**
1. **Create a GitHub Actions Workflow**:
   - In your GitHub repository, create a new directory named `.github/workflows`.
   - Create a new file named `etl_workflow.yml`.
2. **Define the Workflow**:
   - Use GitHub Copilot to help write the YAML configuration for the workflow. For example:
     ```yaml
     name: ETL Workflow

     on:
       schedule:
         - cron: '0 2 * * *'

     jobs:
       etl:
         runs-on: ubuntu-latest
         steps:
           - name: Checkout repository
             uses: actions/checkout@v2
           - name: Run ETL script
             run: |
               mysql -h ${{ secrets.DB_HOST }} -u ${{ secrets.DB_USER }} -p${{ secrets.DB_PASSWORD }} < etl_process.sql
     ```
3. **Configure Secrets**:
   - In your GitHub repository, go to `Settings` > `Secrets` and add the necessary database connection details as secrets (e.g., `DB_HOST`, `DB_USER`, `DB_PASSWORD`).
4. **Commit and Push the Workflow**:
   -



# **Solving database-related problems.**

## **Exercise 1: Query Optimization**

### **Scenario**
You are a database developer tasked with optimizing a slow-performing query in an e-commerce database. The query retrieves all orders placed by customers in the last year, along with the total order amount.

### **Steps**

1. **Open Visual Studio Code (VS Code)**:
   - Launch VS Code and open the project folder where you cloned the GitHub repository.

2. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `query_optimization.sql` in your project folder.

3. **Connect to the Database**:
   - If you haven't already, install the `SQLTools` extension for VS Code.
   - Click on the SQLTools icon in the activity bar on the left side of the screen.
   - Configure a new connection by providing the database details (e.g., SQLite, MySQL).

4. **Original Query**:
   - Start with the original slow-performing query. For example:
     ```sql
     -- Retrieve orders placed by customers in the last year
     SELECT o.order_id, o.order_date, c.customer_name, SUM(oi.quantity * oi.unit_price) AS total_amount
     FROM orders o
     JOIN order_items oi ON o.order_id = oi.order_id
     JOIN customers c ON o.customer_id = c.customer_id
     WHERE o.order_date > DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
     GROUP BY o.order_id, o.order_date, c.customer_name;
     ```

5. **Use GitHub Copilot**:
   - Ask GitHub Copilot to help optimize the query. Start typing a comment like:
     ```sql
     -- Optimize the query for better performance
     ```

6. **Use GitHub Copilot Chat**:
   - Open GitHub Copilot Chat and ask for optimization tips:
     ```text
     How can I optimize this query to improve performance?
     ```

7. **Review and Apply Suggestions**:
   - Review the suggestions provided by Copilot and Copilot Chat. Implement the optimized query. For example:
     ```sql
     -- Add indexes to improve join and where clause performance
     CREATE INDEX idx_order_date ON orders(order_date);
     CREATE INDEX idx_customer_id ON orders(customer_id);
     CREATE INDEX idx_order_id ON order_items(order_id);

     -- Optimized Query
     SELECT o.order_id, o.order_date, c.customer_name, SUM(oi.quantity * oi.unit_price) AS total_amount
     FROM orders o
     JOIN order_items oi ON o.order_id = oi.order_id
     JOIN customers c ON o.customer_id = c.customer_id
     WHERE o.order_date > DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
     GROUP BY o.order_id, o.order_date, c.customer_name
     ORDER BY o.order_date DESC;
     ```

8. **Test and Validate**:
   - Execute the optimized query and compare its performance with the original query.

9. **Document Findings**:
   - Document the optimization steps and performance improvements in a file named `query_optimization_report.md`.

## **Exercise 2: Database Schema Design**

### **Scenario**
You are working on a new project that requires designing a database schema for a library management system. The system should track books, authors, members, and loans.

### **Steps**

1. **Open Visual Studio Code (VS Code)**:
   - Launch VS Code and open the project folder where you cloned the GitHub repository.

2. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `library_schema.sql` in your project folder.

3. **Define Requirements**:
   - List the requirements for the database schema. For example:
     ```sql
     -- Library Management System Requirements
     -- Track books, authors, members, and loans
     ```

4. **Use GitHub Copilot**:
   - Ask GitHub Copilot to help design the schema. Start typing a comment like:
     ```sql
     -- Create table definitions
     ```

5. **Use GitHub Copilot Chat**:
   - Open GitHub Copilot Chat and ask for help with schema design:
     ```text
     How should I design a database schema for a library management system?
     ```

6. **Review and Apply Suggestions**:
   - Review the suggestions provided by Copilot and Copilot Chat. Implement the schema design. For example:
     ```sql
     -- Create tables for library management system
     CREATE TABLE authors (
         author_id INT PRIMARY KEY,
         name VARCHAR(100),
         birthdate DATE
     );

     CREATE TABLE books (
         book_id INT PRIMARY KEY,
         title VARCHAR(100),
         author_id INT,
         genre VARCHAR(50),
         published_date DATE,
         FOREIGN KEY (author_id) REFERENCES authors(author_id)
     );

     CREATE TABLE members (
         member_id INT PRIMARY KEY,
         name VARCHAR(100),
         join_date DATE
     );

     CREATE TABLE loans (
         loan_id INT PRIMARY KEY,
         book_id INT,
         member_id INT,
         loan_date DATE,
         return_date DATE,
         FOREIGN KEY (book_id) REFERENCES books(book_id),
         FOREIGN KEY (member_id) REFERENCES members(member_id)
     );
     ```

7. **Validate Schema**:
   - Execute the schema script to create the database structure and ensure it meets the requirements.

8. **Document Schema Design**:
   - Document the schema design and any decisions made in a file named `library_schema_design.md`.

## **Exercise 3: Data Analysis and Reporting**

### **Scenario**
You are a business analyst tasked with creating a report that shows the monthly sales performance for different product categories in an online store.

### **Steps**

1. **Open Visual Studio Code (VS Code)**:
   - Launch VS Code and open the project folder where you cloned the GitHub repository.

2. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `sales_report.sql` in your project folder.

3. **Connect to the Database**:
   - If you haven't already, install the `SQLTools` extension for VS Code.
   - Click on the SQLTools icon in the activity bar on the left side of the screen.
   - Configure a new connection by providing the database details (e.g., SQLite, MySQL).

4. **Define Reporting Requirements**:
   - List the requirements for the sales report. For example:
     ```sql
     -- Sales Report Requirements
     -- Show monthly sales performance for different product categories
     ```

5. **Use GitHub Copilot**:
   - Ask GitHub Copilot to help generate the report. Start typing a comment like:
     ```sql
     -- Generate monthly sales report for product categories
     ```

6. **Use GitHub Copilot Chat**:
   - Open GitHub Copilot Chat and ask for help with data analysis:
     ```text
     How do I create a SQL query to generate a monthly sales report for product categories?
     ```

7. **Review and Apply Suggestions**:
   - Review the suggestions provided by Copilot and Copilot Chat. Implement the report query. For example:
     ```sql
     -- Monthly sales report for product categories
     SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month, p.category, SUM(oi.quantity * oi.unit_price) AS total_sales
     FROM orders o
     JOIN order_items oi ON o.order_id = oi.order_id
     JOIN products p ON oi.product_id = p.product_id
     WHERE o.order_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 12 MONTH) AND CURDATE()
     GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), p.category
     ORDER BY month, p.category;
     ```

8. **Run and Validate Report**:
   - Execute the report query and validate the results.

9. **Export Report**:
   - Save the report results to a file (e.g., CSV). For example, in MySQL:
     ```sql
     SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month, p.category, SUM(oi.quantity * oi.unit_price) AS total_sales
     INTO OUTFILE '/path/to/monthly_sales_report.csv'
     FIELDS TERMINATED BY ','
     LINES TERMINATED BY '\n'
     FROM orders o
     JOIN order_items oi ON o.order_id = oi.order_id
     JOIN products p ON oi.product_id = p.product_id
     WHERE o.order_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 12 MONTH) AND CURDATE()
     GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), p.category
     ORDER BY month, p.category;
     ```

10. **Create Visualizations**:
    - Load the report results into Power BI or Tableau and create visualizations such as line charts or bar graphs.

11. **Design Dashboard**:
    - Design a dashboard in Power BI or Tableau to showcase the monthly sales performance.

12. **Document Report and Insights**:
    - Document the report generation process and insights gained in a file named `sales_report_insights.md`.

## **Exercise 4: Automating Data Pipelines with GitHub Actions**

### **Scenario**
You need to automate the data extraction and transformation process to run daily and generate a report automatically.

### **Steps**

1. **Create a GitHub Actions Workflow**:
   - In your GitHub repository, create a new directory named `.github/workflows`.
   - Create a new file named `data_pipeline.yml`.

2. **Define the Workflow**:




# **Data Modeling and Database Design**

## **Lab 1: Creating and Interpreting Entity-Relationship Diagrams (ERDs)**

### **Scenario**
You are tasked with designing an Entity-Relationship Diagram (ERD) for a university database system that manages students, courses, instructors, and enrollments.

### **Steps**

1. **Open Visual Studio Code (VS Code)**:
   - Launch VS Code and open the project folder where you cloned the GitHub repository.

2. **Create a New File for ERD**:
   - Click on `File` > `New File` and save it as `university_erd.drawio` in your project folder.

3. **Define Entities and Relationships**:
   - List the entities and their relationships. For example:
     ```text
     Entities:
     - Student
     - Course
     - Instructor
     - Enrollment

     Relationships:
     - A student can enroll in multiple courses.
     - A course can have multiple students.
     - An instructor can teach multiple courses.
     - A course can be taught by one instructor.
     ```

4. **Use GitHub Copilot Chat**:
   - Open GitHub Copilot Chat and ask for help with creating the ERD:
     ```text
     How do I create an ERD for a university database system that includes students, courses, instructors, and enrollments?
     ```

5. **Use a Diagram Tool**:
   - Use a diagram tool like Draw.io (integrated with VS Code) to create the ERD based on the entities and relationships defined.

6. **Draw Entities and Relationships**:
   - Create entities (rectangles) for Student, Course, Instructor, and Enrollment.
   - Draw relationships (lines) between entities, including cardinality (1-to-many, many-to-many).

7. **Add Attributes to Entities**:
   - Add attributes (columns) to each entity. For example:
     - **Student**: student_id, name, email, enrollment_date
     - **Course**: course_id, title, description, credits
     - **Instructor**: instructor_id, name, email, department
     - **Enrollment**: enrollment_id, student_id, course_id, enrollment_date

8. **Review and Save ERD**:
   - Review the ERD to ensure it accurately represents the data model.
   - Save the ERD as `university_erd.drawio`.

9. **Document ERD**:
   - Document the ERD creation process and interpretation in a file named `university_erd_documentation.md`.

## **Lab 2: Normalization and Denormalization Techniques**

### **Scenario**
You need to normalize and denormalize a database schema for a customer orders system to optimize data integrity and performance.

### **Steps**

1. **Open Visual Studio Code (VS Code)**:
   - Launch VS Code and open the project folder where you cloned the GitHub repository.

2. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `normalization.sql` in your project folder.

3. **Define Initial Schema**:
   - Start with an unnormalized schema. For example:
     ```sql
     -- Unnormalized Schema
     CREATE TABLE orders (
         order_id INT,
         customer_name VARCHAR(100),
         customer_address VARCHAR(200),
         product_name VARCHAR(100),
         quantity INT,
         unit_price DECIMAL(10, 2),
         order_date DATE
     );
     ```

4. **Use GitHub Copilot**:
   - Ask GitHub Copilot to help normalize the schema. Start typing a comment like:
     ```sql
     -- Normalize the schema to 3NF
     ```

5. **Use GitHub Copilot Chat**:
   - Open GitHub Copilot Chat and ask for help with normalization:
     ```text
     How do I normalize a database schema for a customer orders system to 3NF?
     ```

6. **Apply Normalization**:
   - Implement the normalization steps to achieve 3NF. For example:
     ```sql
     -- 1NF: Remove repeating groups
     CREATE TABLE customers (
         customer_id INT PRIMARY KEY,
         customer_name VARCHAR(100),
         customer_address VARCHAR(200)
     );

     CREATE TABLE products (
         product_id INT PRIMARY KEY,
         product_name VARCHAR(100),
         unit_price DECIMAL(10, 2)
     );

     CREATE TABLE orders (
         order_id INT PRIMARY KEY,
         customer_id INT,
         order_date DATE,
         FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
     );

     CREATE TABLE order_items (
         order_item_id INT PRIMARY KEY,
         order_id INT,
         product_id INT,
         quantity INT,
         FOREIGN KEY (order_id) REFERENCES orders(order_id),
         FOREIGN KEY (product_id) REFERENCES products(product_id)
     );

     -- 2NF and 3NF: Ensure all non-key attributes depend only on the primary key
     ```

7. **Denormalization for Performance**:
   - Ask GitHub Copilot to help denormalize the schema. Start typing a comment like:
     ```sql
     -- Denormalize the schema for performance optimization
     ```

8. **Review and Apply Suggestions**:
   - Review the suggestions provided by Copilot and Copilot Chat. Implement denormalization steps if necessary. For example:
     ```sql
     -- Denormalized Schema
     CREATE TABLE order_summary (
         order_id INT PRIMARY KEY,
         customer_name VARCHAR(100),
         order_date DATE,
         total_amount DECIMAL(10, 2)
     );
     ```

9. **Validate Schema**:
   - Execute the normalization and denormalization scripts to ensure they work as expected.

10. **Document Normalization and Denormalization**:
    - Document the normalization and denormalization process in a file named `normalization_documentation.md`.

## **Lab 3: Database Design Patterns**

### **Scenario**
You are designing a database for an e-commerce platform and need to implement common database design patterns to ensure scalability and maintainability.

### **Steps**

1. **Open Visual Studio Code (VS Code)**:
   - Launch VS Code and open the project folder where you cloned the GitHub repository.

2. **Create a New SQL File**:
   - Click on `File` > `New File` and save it as `design_patterns.sql` in your project folder.

3. **Define Requirements**:
   - List the requirements for the e-commerce platform database. For example:
     ```text
     Requirements:
     - Track products, categories, customers, orders, and order items.
     - Support scalability and maintainability.
     ```

4. **Use GitHub Copilot**:
   - Ask GitHub Copilot to help implement common design patterns. Start typing a comment like:
     ```sql
     -- Implement common database design patterns
     ```

5. **Use GitHub Copilot Chat**:
   - Open GitHub Copilot Chat and ask for help with database design patterns:
     ```text
     What are some common database design patterns for an e-commerce platform?
     ```

6. **Implement Design Patterns**:
   - Implement common design patterns based on the requirements. For example:
     - **One-to-Many Relationship**:
       ```sql
       -- One-to-Many Relationship: Product and Category
       CREATE TABLE categories (
           category_id INT PRIMARY KEY,
           category_name VARCHAR(100)
       );

       CREATE TABLE products (
           product_id INT PRIMARY KEY,
           product_name VARCHAR(100),
           category_id INT,
           FOREIGN KEY (category_id) REFERENCES categories(category_id)
       );
       ```
     - **Many-to-Many Relationship**:
       ```sql
       -- Many-to-Many Relationship: Orders and Products
       CREATE TABLE orders (
           order_id INT PRIMARY KEY,
           customer_id INT,
           order_date DATE,
           FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
       );

       CREATE TABLE order_items (
           order_item_id INT PRIMARY KEY,
           order_id INT,
           product_id INT,
           quantity INT,
           FOREIGN KEY (order_id) REFERENCES orders(order_id),
           FOREIGN KEY (product_id) REFERENCES products(product_id)
       );
       ```

7. **Review and Apply Suggestions**:
   - Review the suggestions provided by Copilot and Copilot Chat. Implement the design patterns that fit the requirements.

8. **Validate Schema**:
   - Execute the schema script to create the database structure and ensure it meets the requirements.

9. **Document Design Patterns**:
   - Document the design patterns and their implementation in a file named `design_patterns_documentation.md`.

These detailed hands-on labs should help participants gain a comprehensive understanding of data modeling and database design using GitHub Copilot and GitHub Copilot Chat. If you need further assistance or adjustments, feel free to let me know!



