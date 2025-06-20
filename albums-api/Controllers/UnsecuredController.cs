/*
 * File: UnsecuredController.cs
 * Purpose: Deliberately insecure controller demonstrating common security vulnerabilities
 * 
 * Description:
 * This file contains intentionally vulnerable code that demonstrates various security
 * flaws commonly found in web applications. It serves as an example of what NOT to do
 * and can be used for security training, penetration testing, or vulnerability research.
 * 
 * Logic:
 * - ReadFile method reads arbitrary files based on user input without validation
 * - Uses direct file system access with user-controlled paths
 * - Implements potentially unsafe file reading patterns
 * - Demonstrates multiple security anti-patterns in a single controller
 * 
 * Security Considerations:
 * - CRITICAL: DIRECTORY TRAVERSAL - userInput parameter used directly in File.Open()
 * - CRITICAL: PATH INJECTION - no validation of file paths, allows access to any file
 * - CRITICAL: INFORMATION DISCLOSURE - file contents returned to user without access control
 * - CRITICAL: FILE SYSTEM ACCESS - unrestricted file system operations
 * - CRITICAL: BUFFER HANDLING - fixed buffer size may cause data truncation
 * - CRITICAL: ENCODING ISSUES - UTF8 encoding without proper error handling
 * - CRITICAL: RESOURCE LEAKS - potential file handle leaks in error conditions
 * - THIS CODE IS INTENTIONALLY VULNERABLE - DO NOT USE IN PRODUCTION
 * - For legitimate file access, implement proper path validation, authorization, and sandboxing
 */

using Microsoft.Data.SqlClient;
using System.Data;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;

namespace UnsecureApp.Controllers
{
    public class MyController
    {
        public string ReadFile(string userInput)
        {
            using (FileStream fs = File.Open(userInput, FileMode.Open))
            {
                byte[] b = new byte[1024];
                UTF8Encoding temp = new UTF8Encoding(true);

                while (fs.Read(b, 0, b.Length) > 0)
                {
                    return temp.GetString(b);
                }
            }

            return null;
        }

        public int GetProduct(string productName)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand sqlCommand = new SqlCommand()
                {
                    CommandText = "SELECT ProductId FROM Products WHERE ProductName = '" + productName + "'",
                    CommandType = CommandType.Text,
                };

                SqlDataReader reader = sqlCommand.ExecuteReader();
                return reader.GetInt32(0); 
            }
        }

        public void GetObject()
        {
            try
            {
                object o = null;
                o.ToString();
            }
            catch (Exception e)
            {
                this.Response.Write(e.ToString());
            }
        }

        private string connectionString = "";
    }
}