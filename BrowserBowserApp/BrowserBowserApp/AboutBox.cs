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