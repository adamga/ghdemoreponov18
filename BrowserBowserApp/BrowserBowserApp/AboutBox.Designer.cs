namespace BrowserBowserApp
{
    partial class AboutBox
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.txtLicenseKey = new System.Windows.Forms.TextBox();
            this.btnSaveLicense = new System.Windows.Forms.Button();
            this.lblLicenseKey = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // txtLicenseKey
            // 
            this.txtLicenseKey.Location = new System.Drawing.Point(12, 29);
            this.txtLicenseKey.Name = "txtLicenseKey";
            this.txtLicenseKey.Size = new System.Drawing.Size(260, 20);
            this.txtLicenseKey.TabIndex = 0;
            // 
            // btnSaveLicense
            // 
            this.btnSaveLicense.Location = new System.Drawing.Point(197, 55);
            this.btnSaveLicense.Name = "btnSaveLicense";
            this.btnSaveLicense.Size = new System.Drawing.Size(75, 23);
            this.btnSaveLicense.TabIndex = 1;
            this.btnSaveLicense.Text = "Save";
            this.btnSaveLicense.UseVisualStyleBackColor = true;
            this.btnSaveLicense.Click += new System.EventHandler(this.btnSaveLicense_Click);
            // 
            // lblLicenseKey
            // 
            this.lblLicenseKey.AutoSize = true;
            this.lblLicenseKey.Location = new System.Drawing.Point(12, 9);
            this.lblLicenseKey.Name = "lblLicenseKey";
            this.lblLicenseKey.Size = new System.Drawing.Size(68, 13);
            this.lblLicenseKey.TabIndex = 2;
            this.lblLicenseKey.Text = "License Key:";
            // 
            // AboutBox
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(284, 91);
            this.Controls.Add(this.lblLicenseKey);
            this.Controls.Add(this.btnSaveLicense);
            this.Controls.Add(this.txtLicenseKey);
            this.Name = "AboutBox";
            this.Text = "About";
            this.ResumeLayout(false);
            this.PerformLayout();
        }

        private System.Windows.Forms.TextBox txtLicenseKey;
        private System.Windows.Forms.Button btnSaveLicense;
        private System.Windows.Forms.Label lblLicenseKey;
    }
}