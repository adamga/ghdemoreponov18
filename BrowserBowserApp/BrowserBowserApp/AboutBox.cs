/*
 * File: AboutBox.cs
 * Purpose: About dialog box for BrowserBowser application with license key management
 * 
 * Description:
 * This file implements the About dialog for the BrowserBowser application, providing
 * application information display and license key management functionality. It allows
 * users to view application details and save license keys to the local file system.
 * 
 * Logic:
 * - Inherits from Windows Forms Form class for dialog functionality
 * - Initializes UI components through InitializeComponent() method
 * - Handles license key save button click events
 * - Writes license key text to local "app.lic" file in application directory
 * - Provides user feedback through message boxes for success/error states
 * 
 * Security Considerations:
 * - CRITICAL: File I/O operations - license file written to application directory without validation
 * - CRITICAL: License key handling - stored in plain text, no encryption or validation
 * - CRITICAL: Path manipulation - using AppDomain.CurrentDomain.BaseDirectory could be exploited
 * - CRITICAL: User input - license key text not validated, could contain malicious content
 * - CRITICAL: Exception handling - error messages may expose sensitive file system information
 * - CRITICAL: File permissions - app.lic file may be readable by other applications
 * - License key should be encrypted before storage
 * - Input validation required for license key format and content
 * - File path should be validated to prevent directory traversal attacks
 */

using System;
using System.IO;
using System.Windows.Forms;

namespace BrowserBowserApp
{
    public partial class AboutBox : Form
    {
        public AboutBox()
        {
            InitializeComponent();
        }

        private void btnSaveLicense_Click(object sender, EventArgs e)
        {
            string licenseKey = txtLicenseKey.Text;
            string licenseFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "app.lic");

            try
            {
                File.WriteAllText(licenseFilePath, licenseKey);
                MessageBox.Show("License key saved successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to save license key: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}