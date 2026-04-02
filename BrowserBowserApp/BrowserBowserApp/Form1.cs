using Microsoft.Web.WebView2.WinForms;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Net;
using System.Windows.Forms;
using System.Text.RegularExpressions;
using System.ComponentModel;
using Newtonsoft.Json;
using MaterialSkin;
using MaterialSkin.Controls;
using Newtonsoft.Json.Linq;
using static System.Windows.Forms.DataFormats;
using System.Net.Mail;
using System.Security.Cryptography;

namespace BrowserBowserApp
{




    public partial class Form1 : MaterialForm
    {
        Dictionary<urlinfos, Screen> targetlist = new Dictionary<urlinfos, Screen>();
        Dictionary<string, Screen> screenlist = new Dictionary<string, Screen>();
        public int colofinterest = 0;
        BindingList<CombinedObject> bindingList = new BindingList<CombinedObject>();
        Dictionary<Form, System.Windows.Forms.Timer> screenforms = new Dictionary<Form, System.Windows.Forms.Timer>();


        public Form1()
        {
            InitializeComponent();
            this.Load += new System.EventHandler(this.Form1_Load);
        }

        private async void Form1_Load(object sender, EventArgs e)
        {



            btntools.Text = "\u23EB" + " Show Address Tools " + "\u23EB";


            //await webView21.EnsureCoreWebView2Async(null);
            //webView21.CoreWebView2.Navigate("https://www.microsoft.com");

            panel1.Visible = false;
            //move panel2 to 20 pixels below the top of the form
            panel2.Top = 70;
            //resize the form to the height of panel2
            this.Height = panel2.Height + 70;

            //load the settings file by calling the btnLoadSettings_Click method
            btnLoadSettings_Click_1(null, null);

            foreach (Screen screen in Screen.AllScreens)
            {
                screenlist.Add(screen.DeviceName, screen);


            }


            List<ScreenInfos> screeninfos = new List<ScreenInfos>();
            //for each screen in Screen,AallScreens, add the screen to the screeninfos list, along with the display name of the screen, but only the last part, after the \s 

            foreach (Screen screen in Screen.AllScreens)
            {
                ScreenInfos si = new ScreenInfos();
                si.screen = screen;
                si.screenname = screen.DeviceName.Substring(screen.DeviceName.LastIndexOf("\\") + 1);
                screeninfos.Add(si);


            }


            //bind the dgscreens to the Screens on the pc
            dgscreens.DataSource = Screen.AllScreens;

            //bind the dgscreens to the screeninfos list, and set the column screenname to visible
            dgscreens.DataSource = screeninfos;
            dgscreens.Columns[1].Visible = true;
            //hide the screen column
            dgscreens.Columns[0].Visible = false;


            dgscreens.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            //don't display any headers
            dgscreens.ColumnHeadersVisible = false;
            //dgscreens.Columns[0].HeaderText = "Screens";

            //for all of the bound columns, hide them unless the column name is Device_Foo
            foreach (DataGridViewColumn col in dgscreens.Columns)
            {
                if (col.HeaderText != "screenname")
                    col.Visible = false;
                colofinterest = col.Index;
            }

            // Position the form on the left side of the primary screen
            Screen primaryScreen = Screen.PrimaryScreen;
            this.Left = primaryScreen.WorkingArea.Left;

            this.Width = primaryScreen.WorkingArea.Width;

        }

        //create a methof that takes a screen and creates a new form window 100x100 pixels with a webview control in it on that screen
        private void CreateFormOnScreen(Screen screen)
        {
            Form form = new Form();
            form.Left = screen.WorkingArea.Left;
            form.Top = screen.WorkingArea.Top;
            form.Width = 100;
            form.Height = 100;
            form.StartPosition = FormStartPosition.Manual;
            form.Show();
            WebView2 webView = new WebView2();
            form.Controls.Add(webView);
            webView.Dock = DockStyle.Fill;
            webView.Source = new Uri("https://www.microsoft.com");
        }

        private void btnpopurl_Click(object sender, EventArgs e)
        {
            string ippart;
            string uripart;
            string urlselected;
            //if txtip is empty, return from the method
            if (txtip.Text == "")
            {
                return;
            }

            string prefix = "http://";
            //if chkssl is checked, set the prefix to https://
            if (chkHttps.Checked)
            {
                prefix = "https://";
            }



            //set the ippart variable to the contents of the combobox
            ippart = txtip.Text;

            //get the uri part from the textbox
            uripart = txtcompletion.Text;

            urlselected = prefix + ippart + uripart;

            //check if the urlselected is a valid url
            if (Uri.IsWellFormedUriString(urlselected, UriKind.Absolute))
            {
                txtURL.Text = urlselected;
            }
            else
            {
                //if it is not, display an error message
                MessageBox.Show("Invalid URL:  " + urlselected, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }


        }

        private async void Search_Click(object sender, EventArgs e)
        {
            //clear the contents of the datagrid view
            dgHostList.DataSource = null;
            dgHostList.Rows.Clear();
            dgHostList.Refresh();
            dgHostList.Columns.Clear();


            Dictionary<string, string> pcList = new Dictionary<string, string>();
            string ipfilter = "";
            if (chkFilter.Checked)
            {
                ipfilter = txtIPFilter.Text;

                //validate the IP address stored in the ipfilter variable is the first three octests of an IP address
                //if it is not, display an error message and return from the method
                if (!Regex.IsMatch(ipfilter, @"^\d{1,3}\.\d{1,3}\.\d{1,3}$"))
                {
                    lblIPerror.Text = "Invalid IP Address.Only Enter the first three octets, no trailing .";
                    ipfilter = "";
                    chkFilter.Checked = false;
                    return;

                }
                else
                {
                    lblIPerror.Text = "";

                }
            }
            else
            {
                ipfilter = "";
            }




            try
            {
                pcList = await GetNetworkPCsAsync();

                foreach (KeyValuePair<string, string> kvp in pcList)
                {
                    // if the checkbox5 is checked, only show the ip addresses that start with the contents of textbox7 
                    if (chkFilter.Checked)
                    {
                        if (!kvp.Key.ToString().StartsWith(ipfilter))
                        {
                            pcList.Remove(kvp.Key);
                        }
                    }
                }

                dgHostList.DataSource = pcList.ToList();
                dgHostList.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.AllCells;
                //set the header text for the first column to "IP Address"
                dgHostList.Columns[0].HeaderText = "IP Address";
                //set the header text for the second column to "Host Name"
                dgHostList.Columns[1].HeaderText = "Host Name";
                //set the datagrid to fill the available space with the columns
                dgHostList.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred while populating the DataGridView: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                LogError(ex);
            }



        }

        private void dgHostList_CellContentDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            //get the contents of the cell that was double clicked
            string ip = dgHostList.Rows[e.RowIndex].Cells[0].Value.ToString();

            txtip.Text = ip;


        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            //if the txtURL textbox is empty, return from the method
            if (txtURL.Text == "")
            {
                return;
            }


            //if there's no rows in the dgscreens datagridview, return from the method
            if (dgscreens.Rows.Count == 0)
            {
                return;
            }





            //if no row is selected in the dgscreens datagridview, select the first row
            if (dgscreens.SelectedRows.Count == 0)
            {
                dgscreens.Rows[0].Selected = true;
            }


            //retrieve the select item from the lsturls listbox
            string url = txtURL.Text;

            //from the selected row in dgScreens, get the value of the cell with the header DeviceName
            foreach (DataGridViewColumn column in dgscreens.Columns)
            {
                if (column.HeaderText == "screenname")
                {
                    string screenval = dgscreens.SelectedRows[0].Cells[column.Index].Value.ToString();

                    ScreenInfos screeninfo = new ScreenInfos();
                    //find the screeninfo object whose screen.DeviceName property ends in the same string as the screenval variable
                    foreach (ScreenInfos si in dgscreens.DataSource as List<ScreenInfos>)
                    {
                        if (si.screenname == screenval)
                        {
                            screeninfo = si;
                        }
                    }


                    //find the screen object in the screenlist dictionary that has the same value as the screenval variable
                    Screen screentoAdd = screeninfo.screen;
                    urlinfos newinfo = new urlinfos();
                    newinfo.url = url;
                    //if the chkFullScreen checkbox is checked, set the fullscreen property to true
                    if (chkFullScreen.Checked)
                    {
                        newinfo.fullscreen = true;
                    }
                    else
                    {
                        newinfo.fullscreen = false;
                    }
                    //if the chkCloseRefresh checkbox is checked, set the closerefresh property to true
                    if (chkClose.Checked)
                    {
                        newinfo.closerefresh = true;
                    }
                    else
                    {
                        newinfo.closerefresh = false;
                    }



                    //newinfo.fullscreen = chkFullScreen.Checked;
                    targetlist.Add(newinfo, screentoAdd);
                }
            }

            foreach (var kvp in targetlist)
            {
                bindingList.Add(new CombinedObject
                {
                    UrlString = kvp.Key.url,
                    FullScreen = kvp.Key.fullscreen,
                    CloseRefresh = kvp.Key.closerefresh,
                    Screen = kvp.Value.DeviceName.Substring(kvp.Value.DeviceName.LastIndexOf("\\") + 1),
                    ScreenObject = kvp.Value.DeviceName

                });
            }

            dgTargets.DataSource = null;
            dgTargets.DataSource = bindingList;


            txtURL.Text = "";
            targetlist.Clear();




        }



        private void btnRemove_Click(object sender, EventArgs e)
        {
            //if the dgTargets datagridview has no rows, return from the method
            if (dgTargets.Rows.Count == 0)
            {
                return;
            }
            //if no row is selected in the dgTargets datagridview, return from the method

            if (dgTargets.SelectedRows.Count == 0)
            {
                return;
            }


            //get the selected row from the dgTargets datagridview
            DataGridViewRow row = dgTargets.SelectedRows[0];
            bindingList.RemoveAt(row.Index);
            //remove the row from the datagridview
            // dgTargets.Rows.Remove(row);
            //remove the row from the binding list using the dgTargets selected row index as the item
            //



            dgTargets.DataSource = null;
            dgTargets.DataSource = bindingList;


        }

        private void btnchangeiptarget_Click(object sender, EventArgs e)
        {
            //if the dghostlist is empty, return from the method
            if (dgHostList.Rows.Count == 0)
            {
                return;
            }

            //if the dgtargets datagridview is empty, return from the method
            if (dgTargets.Rows.Count == 0)
            {
                return;
            }

            //get the selected item from dghostlist 
            string ip = dgHostList.SelectedRows[0].Cells[0].Value.ToString();

            //get the selected item from dgtargets
            string url = dgTargets.SelectedRows[0].Cells[0].Value.ToString();
            //replace the ip address in the url with the selected ip address
            //string newurl = url.Replace("http://", "http://" + ip + "/");
            string oldIpPattern = @"http://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}";
            string newurl = Regex.Replace(url, oldIpPattern, "http://" + ip);

        }

        private void btnchangeippall_Click(object sender, EventArgs e)
        {
            //if the dghostlist is empty, return from the method
            if (dgHostList.Rows.Count == 0)
            {
                return;
            }

            //if the dgtargets datagridview is empty, return from the method
            if (dgTargets.Rows.Count == 0)
            {
                return;
            }

            //for each row in the dgtargets datagridview, replace the ipaddress in the url with the selected ip address
            foreach (DataGridViewRow row in dgTargets.Rows)
            {
                string ip = dgHostList.SelectedRows[0].Cells[0].Value.ToString();
                string url = row.Cells[0].Value.ToString();
                // string newurl = url.Replace("http://", "http://" + ip + "/");
                string oldIpPattern = @"http://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}";
                string newurl = Regex.Replace(url, oldIpPattern, "http://" + ip);

                row.Cells[0].Value = newurl;
            }

        }


        private void btnShowScreens_Click(object sender, EventArgs e)
        {

            //create the screen forms
            CreateScreenForms();
            //show the screen forms
            ShowScreens();

        }




        private void btntools_Click(object sender, EventArgs e)
        {
            // Get the working area of the primary screen
            Screen primaryScreen = Screen.PrimaryScreen;
            Rectangle workingArea = primaryScreen.WorkingArea;

            if (btntools.Text == "Show Tools")
            {
                // Calculate the new height of the form
                int newHeight = this.Height + panel1.Height;

                // Check if the new height exceeds the working area height
                if (newHeight > workingArea.Height)
                {
                    // Adjust the form's top position to accommodate the new height
                    this.Top = workingArea.Top-70;
                    this.Height = workingArea.Height;
                }
                else
                {
                    // Set the new height and position of the form
                    this.Height = newHeight;
                    panel1.Top = 70;
                    panel2.Top = panel1.Bottom + 1;
                }

                panel1.Visible = true;
                btntools.Text = "Hide Tools";
            }
            else
            {
                // Hide the tools and resize the form to the height of panel2
                panel1.Visible = false;
                this.Height = panel2.Height + 70;
                panel2.Top = 70;
                btntools.Text = "Show Tools";
            }
        }



        private void button2_Click_1(object sender, EventArgs e)
        {
            CombinedObject co = new CombinedObject();


            foreach (DataGridViewRow row in dgTargets.Rows)
            {
                co.UrlString = row.Cells[0].Value.ToString();
                co.FullScreen = (bool)row.Cells[1].Value;
                co.CloseRefresh = (bool)row.Cells[2].Value;
                co.Screen = row.Cells[3].Value.ToString();
                co.ScreenObject = row.Cells[4].Value.ToString();

                Form form = new Form();
                Screen screen = Screen.AllScreens.FirstOrDefault(s => s.DeviceName.Equals(co.ScreenObject, StringComparison.OrdinalIgnoreCase));
                if (screen != null)
                {

                    form.StartPosition = FormStartPosition.Manual;
                    form.Location = screen.Bounds.Location;
                    form.Show();
                }




                //set the form's top left  to the screen objects screen top left
                form.Left = screenlist[co.ScreenObject].WorkingArea.Left;
                form.Top = screenlist[co.ScreenObject].WorkingArea.Top;
                //set the form's width and height to the screen objects width and height
                form.Width = screenlist[co.ScreenObject].WorkingArea.Width;
                form.Height = screenlist[co.ScreenObject].WorkingArea.Height;
                //add a webview control to the form
                WebView2 webView = new WebView2();
                form.Controls.Add(webView);
                //dock the webview control to the form
                webView.Dock = DockStyle.Fill;
                //navigate the webview control to the url string
                webView.Source = new Uri(co.UrlString);


                //if the fullscreen property is true, set the form's window state to maximized
                if (co.FullScreen)
                {
                    form.WindowState = FormWindowState.Maximized;
                }
                //if the closerefresh property is true, create a two new buttons on the form
                Button btnClose = new Button();
                btnClose.Text = "X";
                btnClose.Click += (s, ev) => { form.Close(); };
                //put the button in the top left corner of the form
                btnClose.Left = 0;
                btnClose.Top = 0;
                //set the button's width and height to 20 pixels
                btnClose.Width = 60;
                btnClose.Height = 60;
                //set the font of the button to bold and 14 point
                btnClose.Font = new Font("Arial", 14, FontStyle.Bold);

                Button btnRefresh = new Button();
                btnRefresh.Text = "но";
                btnRefresh.Click += (s, ev) => { webView.Reload(); };
                //put the button in the top left corner of the form, beside the close button, 20 pixels to the right
                btnRefresh.Left = btnClose.Right + 10;
                btnRefresh.Top = 0;
                //set the button's width and height to 20 pixels
                btnRefresh.Width = 60;
                btnRefresh.Height = 60;
                //set the font of the button to bold and 14 point
                btnRefresh.Font = new Font("Arial Unicode MS", 14, FontStyle.Bold);


                //add the buttons to the form
                form.Controls.Add(btnClose);
                form.Controls.Add(btnRefresh);
                //make sure the buttons stay on top of the webview control
                btnClose.BringToFront();
                btnRefresh.BringToFront();






                //show the form
                form.Show();


            }


        }

        private void btnLoadSettings_Click_1(object sender, EventArgs e)
        {
            //show the openfiledialog and set the filter to json files in the current directory
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "PROFILE Files|*.poprofile";
            ofd.Title = "Select a Profile file";
            ofd.InitialDirectory = Application.StartupPath;
            ofd.ShowDialog();

            //if the filename is empty, return from the method
            if (ofd.FileName == "")
            {
                return;
            }
            //load the contents of the file into the binding list
            string json = File.ReadAllText(ofd.FileName);
            bindingList = JsonConvert.DeserializeObject<BindingList<CombinedObject>>(json);
            dgTargets.DataSource = bindingList;
            //set the label8 to the file name with extension, but omit the path
            string tempfilename = ofd.FileName;
            label8.Text = tempfilename.Substring(tempfilename.LastIndexOf("\\") + 1);







            //label8.Text = ofd.FileName;


        }

        private void btnSaveSettings_Click_1(object sender, EventArgs e)
        {
            //show the savefiledialog and set the filter to poprofile files in the current directory
            SaveFileDialog sfd = new SaveFileDialog();
            sfd.Filter = "PROFILE Files|*.poprofile";
            sfd.Title = "Save a Profile file";
            sfd.InitialDirectory = Application.StartupPath;
            sfd.ShowDialog();

            //if the filename is empty, return from the method
            if (sfd.FileName == "")
            {
                return;
            }

            //save the contents for the binding list to a file
            string json = JsonConvert.SerializeObject(bindingList);
            File.WriteAllText(sfd.FileName, json);

            //set the label8 to the file name with extension, but omit the path
            string tempfilename = sfd.FileName;
            label8.Text = tempfilename.Substring(tempfilename.LastIndexOf("\\") + 1);


        }

        private void btnclose_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }
    }



}


