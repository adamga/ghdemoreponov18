namespace BrowserBowserApp
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            DataGridViewCellStyle dataGridViewCellStyle2 = new DataGridViewCellStyle();
            chkFullScreen = new CheckBox();
            btnAdd = new Button();
            dgTargets = new DataGridView();
            btnRemove = new Button();
            label1 = new Label();
            label2 = new Label();
            label4 = new Label();
            txtIPFilter = new TextBox();
            chkFilter = new CheckBox();
            dgHostList = new DataGridView();
            label5 = new Label();
            txtcompletion = new TextBox();
            btnpopurl = new Button();
            label6 = new Label();
            Search = new Button();
            lblIPerror = new Label();
            dgscreens = new DataGridView();
            txtURL = new TextBox();
            btnchangeiptarget = new Button();
            btnchangeippall = new Button();
            txtip = new TextBox();
            chkHttps = new CheckBox();
            btnShowScreens = new Button();
            panel1 = new Panel();
            panel2 = new Panel();
            btnclose = new Button();
            chkClose = new CheckBox();
            label8 = new Label();
            label7 = new Label();
            label3 = new Label();
            btnPopout = new Button();
            btnSaveSettings = new Button();
            btnLoadSettings = new Button();
            btntools = new Button();
            openFileDialog1 = new OpenFileDialog();
            saveFileDialog1 = new SaveFileDialog();
            Button btnAbout = new Button();
            ((System.ComponentModel.ISupportInitialize)dgTargets).BeginInit();
            ((System.ComponentModel.ISupportInitialize)dgHostList).BeginInit();
            ((System.ComponentModel.ISupportInitialize)dgscreens).BeginInit();
            panel1.SuspendLayout();
            panel2.SuspendLayout();
            SuspendLayout();
            // 
            // chkFullScreen
            // 
            chkFullScreen.AutoSize = true;
            chkFullScreen.Checked = true;
            chkFullScreen.CheckState = CheckState.Checked;
            chkFullScreen.Font = new Font("Segoe UI", 11F);
            chkFullScreen.Location = new Point(295, 474);
            chkFullScreen.Margin = new Padding(4, 5, 4, 5);
            chkFullScreen.Name = "chkFullScreen";
            chkFullScreen.Size = new Size(144, 34);
            chkFullScreen.TabIndex = 3;
            chkFullScreen.Text = "Full Screen";
            chkFullScreen.UseVisualStyleBackColor = true;
            // 
            // btnAdd
            // 
            btnAdd.FlatStyle = FlatStyle.System;
            btnAdd.Font = new Font("Segoe UI", 11F);
            btnAdd.Location = new Point(746, 258);
            btnAdd.Margin = new Padding(4, 5, 4, 5);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(194, 131);
            btnAdd.TabIndex = 4;
            btnAdd.Text = "Add >>";
            btnAdd.UseVisualStyleBackColor = true;
            btnAdd.Click += btnAdd_Click;
            // 
            // dgTargets
            // 
            dgTargets.AllowUserToAddRows = false;
            dgTargets.AllowUserToDeleteRows = false;
            dgTargets.BackgroundColor = SystemColors.Control;
            dgTargets.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgTargets.EditMode = DataGridViewEditMode.EditProgrammatically;
            dgTargets.Location = new Point(948, 123);
            dgTargets.Margin = new Padding(4, 5, 4, 5);
            dgTargets.MultiSelect = false;
            dgTargets.Name = "dgTargets";
            dgTargets.RowHeadersWidth = 62;
            dgTargets.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgTargets.Size = new Size(920, 396);
            dgTargets.TabIndex = 5;
            // 
            // btnRemove
            // 
            btnRemove.Font = new Font("Segoe UI", 11F);
            btnRemove.Location = new Point(1561, 529);
            btnRemove.Margin = new Padding(4, 5, 4, 5);
            btnRemove.Name = "btnRemove";
            btnRemove.Size = new Size(306, 78);
            btnRemove.TabIndex = 6;
            btnRemove.Text = "Remove Selected";
            btnRemove.UseVisualStyleBackColor = true;
            btnRemove.Click += btnRemove_Click;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI", 11F);
            label1.Location = new Point(63, 219);
            label1.Margin = new Padding(4, 0, 4, 0);
            label1.Name = "label1";
            label1.Size = new Size(500, 30);
            label1.TabIndex = 7;
            label1.Text = "URI Completion: {:PORT}/{youraddresscompletion}";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI", 11F);
            label2.Location = new Point(58, 208);
            label2.Margin = new Padding(4, 0, 4, 0);
            label2.Name = "label2";
            label2.Size = new Size(93, 30);
            label2.TabIndex = 8;
            label2.Text = "Screens:";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Segoe UI", 11F);
            label4.Location = new Point(948, 88);
            label4.Margin = new Padding(4, 0, 4, 0);
            label4.Name = "label4";
            label4.Size = new Size(163, 30);
            label4.TabIndex = 12;
            label4.Text = "Popout Targets:";
            // 
            // txtIPFilter
            // 
            txtIPFilter.Font = new Font("Segoe UI", 11F);
            txtIPFilter.Location = new Point(1197, 20);
            txtIPFilter.Margin = new Padding(4, 5, 4, 5);
            txtIPFilter.Name = "txtIPFilter";
            txtIPFilter.Size = new Size(472, 37);
            txtIPFilter.TabIndex = 13;
            txtIPFilter.Text = "192.168.1";
            txtIPFilter.WordWrap = false;
            // 
            // chkFilter
            // 
            chkFilter.AutoSize = true;
            chkFilter.Checked = true;
            chkFilter.CheckState = CheckState.Checked;
            chkFilter.Font = new Font("Segoe UI", 11F);
            chkFilter.Location = new Point(948, 30);
            chkFilter.Margin = new Padding(4, 5, 4, 5);
            chkFilter.Name = "chkFilter";
            chkFilter.Size = new Size(155, 34);
            chkFilter.TabIndex = 14;
            chkFilter.Text = "Filter IPs by:";
            chkFilter.UseVisualStyleBackColor = true;
            // 
            // dgHostList
            // 
            dgHostList.AllowUserToAddRows = false;
            dgHostList.AllowUserToDeleteRows = false;
            dgHostList.BackgroundColor = SystemColors.Control;
            dgHostList.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dataGridViewCellStyle2.Alignment = DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = SystemColors.Window;
            dataGridViewCellStyle2.Font = new Font("Segoe UI", 11F);
            dataGridViewCellStyle2.ForeColor = SystemColors.ControlText;
            dataGridViewCellStyle2.SelectionBackColor = SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = DataGridViewTriState.False;
            dgHostList.DefaultCellStyle = dataGridViewCellStyle2;
            dgHostList.Location = new Point(948, 85);
            dgHostList.Margin = new Padding(4, 5, 4, 5);
            dgHostList.MultiSelect = false;
            dgHostList.Name = "dgHostList";
            dgHostList.RowHeadersWidth = 62;
            dgHostList.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgHostList.Size = new Size(920, 263);
            dgHostList.TabIndex = 15;
            dgHostList.CellContentClick += dgHostList_CellContentDoubleClick;
            dgHostList.CellContentDoubleClick += dgHostList_CellContentDoubleClick;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Segoe UI", 11F);
            label5.Location = new Point(63, 29);
            label5.Margin = new Padding(4, 0, 4, 0);
            label5.Name = "label5";
            label5.Size = new Size(182, 30);
            label5.TabIndex = 17;
            label5.Text = "Target IP Address";
            // 
            // txtcompletion
            // 
            txtcompletion.Font = new Font("Segoe UI", 12F);
            txtcompletion.Location = new Point(66, 278);
            txtcompletion.Margin = new Padding(4, 5, 4, 5);
            txtcompletion.Name = "txtcompletion";
            txtcompletion.Size = new Size(673, 39);
            txtcompletion.TabIndex = 18;
            // 
            // btnpopurl
            // 
            btnpopurl.Font = new Font("Segoe UI", 11F);
            btnpopurl.Location = new Point(518, 348);
            btnpopurl.Margin = new Padding(4, 5, 4, 5);
            btnpopurl.Name = "btnpopurl";
            btnpopurl.Size = new Size(224, 52);
            btnpopurl.TabIndex = 19;
            btnpopurl.Text = "Populate URL";
            btnpopurl.UseVisualStyleBackColor = true;
            btnpopurl.Click += btnpopurl_Click;
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Segoe UI", 11F);
            label6.Location = new Point(58, 85);
            label6.Margin = new Padding(4, 0, 4, 0);
            label6.Name = "label6";
            label6.Size = new Size(56, 30);
            label6.TabIndex = 20;
            label6.Text = "URL:";
            // 
            // Search
            // 
            Search.Font = new Font("Segoe UI", 11F);
            Search.Location = new Point(1700, 24);
            Search.Margin = new Padding(4, 5, 4, 5);
            Search.Name = "Search";
            Search.Size = new Size(168, 52);
            Search.TabIndex = 21;
            Search.Text = "Find PCs";
            Search.UseVisualStyleBackColor = true;
            Search.Click += Search_Click;
            // 
            // lblIPerror
            // 
            lblIPerror.AutoSize = true;
            lblIPerror.Location = new Point(964, 353);
            lblIPerror.Margin = new Padding(4, 0, 4, 0);
            lblIPerror.Name = "lblIPerror";
            lblIPerror.Size = new Size(0, 38);
            lblIPerror.TabIndex = 22;
            // 
            // dgscreens
            // 
            dgscreens.AllowUserToAddRows = false;
            dgscreens.AllowUserToDeleteRows = false;
            dgscreens.BackgroundColor = SystemColors.Control;
            dgscreens.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgscreens.Location = new Point(58, 243);
            dgscreens.Margin = new Padding(4, 5, 4, 5);
            dgscreens.MultiSelect = false;
            dgscreens.Name = "dgscreens";
            dgscreens.RowHeadersWidth = 62;
            dgscreens.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgscreens.Size = new Size(674, 213);
            dgscreens.TabIndex = 23;
            // 
            // txtURL
            // 
            txtURL.Font = new Font("Segoe UI", 12F);
            txtURL.Location = new Point(58, 120);
            txtURL.Margin = new Padding(4, 5, 4, 5);
            txtURL.Name = "txtURL";
            txtURL.Size = new Size(680, 39);
            txtURL.TabIndex = 24;
            // 
            // btnchangeiptarget
            // 
            btnchangeiptarget.Font = new Font("Segoe UI", 11F);
            btnchangeiptarget.Location = new Point(948, 353);
            btnchangeiptarget.Margin = new Padding(4, 5, 4, 5);
            btnchangeiptarget.Name = "btnchangeiptarget";
            btnchangeiptarget.Size = new Size(339, 59);
            btnchangeiptarget.TabIndex = 26;
            btnchangeiptarget.Text = "Change IP for Target";
            btnchangeiptarget.UseVisualStyleBackColor = true;
            btnchangeiptarget.Click += btnchangeiptarget_Click;
            // 
            // btnchangeippall
            // 
            btnchangeippall.Font = new Font("Segoe UI", 11F);
            btnchangeippall.Location = new Point(1443, 350);
            btnchangeippall.Margin = new Padding(4, 5, 4, 5);
            btnchangeippall.Name = "btnchangeippall";
            btnchangeippall.Size = new Size(424, 65);
            btnchangeippall.TabIndex = 27;
            btnchangeippall.Text = "Change IP for All Targets";
            btnchangeippall.UseVisualStyleBackColor = true;
            btnchangeippall.Click += btnchangeippall_Click;
            // 
            // txtip
            // 
            txtip.Font = new Font("Segoe UI", 12F);
            txtip.Location = new Point(63, 85);
            txtip.Margin = new Padding(4, 5, 4, 5);
            txtip.Name = "txtip";
            txtip.Size = new Size(676, 39);
            txtip.TabIndex = 28;
            // 
            // chkHttps
            // 
            chkHttps.AutoSize = true;
            chkHttps.Font = new Font("Segoe UI", 11F);
            chkHttps.Location = new Point(66, 347);
            chkHttps.Margin = new Padding(4, 5, 4, 5);
            chkHttps.Name = "chkHttps";
            chkHttps.Size = new Size(142, 34);
            chkHttps.TabIndex = 29;
            chkHttps.Text = "use HTTPS";
            chkHttps.UseVisualStyleBackColor = true;
            // 
            // btnShowScreens
            // 
            btnShowScreens.Font = new Font("Segoe UI", 11F);
            btnShowScreens.Location = new Point(512, 539);
            btnShowScreens.Margin = new Padding(4, 5, 4, 5);
            btnShowScreens.Name = "btnShowScreens";
            btnShowScreens.Size = new Size(220, 58);
            btnShowScreens.TabIndex = 30;
            btnShowScreens.Text = "Show Screens";
            btnShowScreens.UseVisualStyleBackColor = true;
            btnShowScreens.Click += btnShowScreens_Click;
            // 
            // panel1
            // 
            panel1.BorderStyle = BorderStyle.Fixed3D;
            panel1.Controls.Add(chkHttps);
            panel1.Controls.Add(txtip);
            panel1.Controls.Add(btnchangeippall);
            panel1.Controls.Add(btnchangeiptarget);
            panel1.Controls.Add(lblIPerror);
            panel1.Controls.Add(Search);
            panel1.Controls.Add(btnpopurl);
            panel1.Controls.Add(txtcompletion);
            panel1.Controls.Add(label5);
            panel1.Controls.Add(dgHostList);
            panel1.Controls.Add(chkFilter);
            panel1.Controls.Add(txtIPFilter);
            panel1.Controls.Add(label1);
            panel1.Location = new Point(0, 0);
            panel1.Margin = new Padding(4, 5, 4, 5);
            panel1.Name = "panel1";
            panel1.Size = new Size(1915, 425);
            panel1.TabIndex = 31;
            panel1.Visible = false;
            // 
            // panel2
            // 
            panel2.BorderStyle = BorderStyle.Fixed3D;
            panel2.Controls.Add(btnclose);
            panel2.Controls.Add(chkClose);
            panel2.Controls.Add(label8);
            panel2.Controls.Add(label7);
            panel2.Controls.Add(label3);
            panel2.Controls.Add(btnPopout);
            panel2.Controls.Add(btnSaveSettings);
            panel2.Controls.Add(btnLoadSettings);
            panel2.Controls.Add(btntools);
            panel2.Controls.Add(btnShowScreens);
            panel2.Controls.Add(txtURL);
            panel2.Controls.Add(dgscreens);
            panel2.Controls.Add(label6);
            panel2.Controls.Add(label4);
            panel2.Controls.Add(label2);
            panel2.Controls.Add(btnRemove);
            panel2.Controls.Add(dgTargets);
            panel2.Controls.Add(btnAdd);
            panel2.Controls.Add(chkFullScreen);
            panel2.Location = new Point(0, 427);
            panel2.Margin = new Padding(4, 5, 4, 5);
            panel2.Name = "panel2";
            panel2.Size = new Size(1915, 755);
            panel2.TabIndex = 32;
            // 
            // btnclose
            // 
            btnclose.Font = new Font("Segoe UI", 26F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnclose.Location = new Point(34, 503);
            btnclose.Name = "btnclose";
            btnclose.Size = new Size(138, 115);
            btnclose.TabIndex = 42;
            btnclose.Text = "X";
            btnclose.UseVisualStyleBackColor = true;
            btnclose.Click += btnclose_Click;
            // 
            // chkClose
            // 
            chkClose.AutoSize = true;
            chkClose.Checked = true;
            chkClose.CheckState = CheckState.Checked;
            chkClose.Font = new Font("Segoe UI", 11F);
            chkClose.Location = new Point(483, 474);
            chkClose.Name = "chkClose";
            chkClose.Size = new Size(249, 34);
            chkClose.TabIndex = 41;
            chkClose.Text = "Include Close/Refresh";
            chkClose.UseVisualStyleBackColor = true;
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Location = new Point(1090, 20);
            label8.Name = "label8";
            label8.Size = new Size(0, 38);
            label8.TabIndex = 40;
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Location = new Point(948, 20);
            label7.Name = "label7";
            label7.Size = new Size(103, 38);
            label7.TabIndex = 39;
            label7.Text = "Profile:";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Location = new Point(1250, 688);
            label3.Margin = new Padding(4, 0, 4, 0);
            label3.Name = "label3";
            label3.Size = new Size(115, 38);
            label3.TabIndex = 36;
            label3.Text = "Profiles:";
            // 
            // btnPopout
            // 
            btnPopout.Font = new Font("Segoe UI", 12F);
            btnPopout.Location = new Point(24, 638);
            btnPopout.Margin = new Padding(4, 5, 4, 5);
            btnPopout.Name = "btnPopout";
            btnPopout.Size = new Size(993, 88);
            btnPopout.TabIndex = 37;
            btnPopout.Text = "POP OUT!";
            btnPopout.UseVisualStyleBackColor = true;
            btnPopout.Click += button2_Click_1;
            // 
            // btnSaveSettings
            // 
            btnSaveSettings.Location = new Point(1549, 681);
            btnSaveSettings.Margin = new Padding(4, 5, 4, 5);
            btnSaveSettings.Name = "btnSaveSettings";
            btnSaveSettings.Size = new Size(168, 52);
            btnSaveSettings.TabIndex = 35;
            btnSaveSettings.Text = "Save As...";
            btnSaveSettings.UseVisualStyleBackColor = true;
            btnSaveSettings.Click += btnSaveSettings_Click_1;
            // 
            // btnLoadSettings
            // 
            btnLoadSettings.Location = new Point(1373, 681);
            btnLoadSettings.Margin = new Padding(4, 5, 4, 5);
            btnLoadSettings.Name = "btnLoadSettings";
            btnLoadSettings.Size = new Size(168, 52);
            btnLoadSettings.TabIndex = 34;
            btnLoadSettings.Text = "Load";
            btnLoadSettings.UseVisualStyleBackColor = true;
            btnLoadSettings.Click += btnLoadSettings_Click_1;
            // 
            // btntools
            // 
            btntools.Font = new Font("Segoe UI", 11F);
            btntools.Location = new Point(58, 6);
            btntools.Margin = new Padding(4, 5, 4, 5);
            btntools.Name = "btntools";
            btntools.Size = new Size(290, 52);
            btntools.TabIndex = 33;
            btntools.Text = "Show Address Tools";
            btntools.UseVisualStyleBackColor = true;
            btntools.Click += btntools_Click;
            // 
            // btnAbout
            // 
            btnAbout.Font = new Font("Segoe UI", 11F);
            btnAbout.Location = new Point(20, 20);
            btnAbout.Name = "btnAbout";
            btnAbout.Size = new Size(120, 40);
            btnAbout.Text = "About";
            btnAbout.UseVisualStyleBackColor = true;
            btnAbout.Click += (sender, e) => {
                AboutBox aboutBox = new AboutBox();
                aboutBox.ShowDialog();
            };
            Controls.Add(btnAbout);
            // 
            // openFileDialog1
            // 
            openFileDialog1.FileName = "openFileDialog1";
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(15F, 38F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1917, 1187);
            Controls.Add(panel2);
            Controls.Add(panel1);
            Font = new Font("Segoe UI", 14F);
            Margin = new Padding(4, 5, 4, 5);
            Name = "Form1";
            Text = "Web Intrument Views (beta)";
            ((System.ComponentModel.ISupportInitialize)dgTargets).EndInit();
            ((System.ComponentModel.ISupportInitialize)dgHostList).EndInit();
            ((System.ComponentModel.ISupportInitialize)dgscreens).EndInit();
            panel1.ResumeLayout(false);
            panel1.PerformLayout();
            panel2.ResumeLayout(false);
            panel2.PerformLayout();
            ResumeLayout(false);
        }

        #endregion
        private CheckBox chkFullScreen;
        private Button btnAdd;
        private DataGridView dgTargets;
        private Button btnRemove;
        private Label label1;
        private Label label2;
        private Label label4;
        private TextBox txtIPFilter;
        private CheckBox chkFilter;
        private DataGridView dgHostList;
        private Label label5;
        private TextBox txtcompletion;
        private Button btnpopurl;
        private Label label6;
        private Button Search;
        private Label lblIPerror;
        private DataGridView dgscreens;
        private TextBox txtURL;
        private Button btnchangeiptarget;
        private Button btnchangeippall;
        private TextBox txtip;
        private CheckBox chkHttps;
        private Button btnShowScreens;
        private Panel panel1;
        private Panel panel2;
        private Button btntools;
        private Label label3;
        private Button btnPopout;
        private Button btnSaveSettings;
        private Button btnLoadSettings;
        private Label label8;
        private Label label7;
        private OpenFileDialog openFileDialog1;
        private SaveFileDialog saveFileDialog1;
        private CheckBox chkClose;
        private Button btnclose;
    }
}
