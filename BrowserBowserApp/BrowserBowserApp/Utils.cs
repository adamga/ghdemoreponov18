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

namespace BrowserBowserApp
{
    public partial class Form1 : MaterialForm
    {

        public class urlinfos
        {
            public string url { get; set; }
            public bool fullscreen { get; set; }
            public bool closerefresh { get; set; }
        }

        public class CombinedObject
        {
            public string UrlString { get; set; }
            public bool FullScreen { get; set; }
            public bool CloseRefresh { get; set; }
            public string Screen { get; set; }
            public string ScreenObject { get; set; }

        }

        public class ScreenInfos
        {
            public Screen screen { get; set; }
            public string screenname { get; set; }

        }

        //create a method that finds all the screens   attached to the system
        //and returns the screens as a list collection
        private List<Screen> GetScreens()
        {
            List<Screen> screens = new List<Screen>();
            foreach (Screen screen in Screen.AllScreens)
            {
                screens.Add(screen);
            }
            return screens;
        }

        private void CreateScreenForms()
        {
            //for each screen in the screenlist dictionary, create a new form object
            foreach (KeyValuePair<string, Screen> kvp in screenlist)
            {
                Form form = new Form();
                Screen screen = Screen.AllScreens.FirstOrDefault(s => s.DeviceName.Equals(kvp.Value.DeviceName, StringComparison.OrdinalIgnoreCase));
                if (screen != null)
                {

                    form.StartPosition = FormStartPosition.Manual;
                    form.Location = screen.Bounds.Location;

                }
                //set the form's top left  to the screen objects screen top left
                form.Left = kvp.Value.WorkingArea.Left + (kvp.Value.WorkingArea.Width / 2);
                form.Top = kvp.Value.WorkingArea.Top + (kvp.Value.WorkingArea.Height / 2);
                //set the form's width and height to the screen objects width and height
                form.Width = kvp.Value.WorkingArea.Width / 4;
                form.Height = kvp.Value.WorkingArea.Height / 4;
                //create a label on the form
                Label lbl = new Label();
                lbl.Dock = DockStyle.Fill;
                //set the label's text to the screen devicename, but only the last part of the device name after the \\
                lbl.Text=screen.DeviceName.Substring(screen.DeviceName.LastIndexOf("\\") + 1);





               // lbl.Text = kvp.Key;
                //lbl.Text = kvp.Value.DeviceName;
                lbl.Font = new Font("Arial", 24, FontStyle.Bold);
                //add the label to the form
                form.Controls.Add(lbl);
                //set the label's top left to the form's top left
                lbl.Left = 40;
                lbl.Top = 40;
                System.Windows.Forms.Timer timer2 = new System.Windows.Forms.Timer();
                timer2.Interval = 3000;
                timer2.Tick += (s, e) =>
                {
                    form.Hide();
                    timer2.Stop();
                };
                screenforms.Add(form, timer2);


            }
        }

        //show the forms in the screenforms list
        private void ShowScreens()
        {
            foreach (KeyValuePair<Form, System.Windows.Forms.Timer> kvp in screenforms)
            {
                Form form = kvp.Key;
                System.Windows.Forms.Timer timer = kvp.Value;
                form.Show();
                timer.Start();
            }
            //return focus to this app
            this.Focus();
        }

        //create a method that searches for all pcs on the current network
        //and returns a list of all the pcs found
        private async Task<Dictionary<string, string>> GetNetworkPCsAsync()
        {
            this.Cursor = Cursors.WaitCursor;



            Dictionary<string, string> pcList = new Dictionary<string, string>();
            string hostName = Dns.GetHostName();
            IPAddress[] ipAddresses = Dns.GetHostAddresses(hostName);

            List<Task> tasks = new List<Task>();

            foreach (IPAddress ip in ipAddresses)
            {
                if (ip.AddressFamily == AddressFamily.InterNetwork)
                {
                    string[] ipParts = ip.ToString().Split('.');
                    string subnet = $"{ipParts[0]}.{ipParts[1]}.{ipParts[2]}";
                    for (int i = 1; i < 255; i++)
                    {
                        string ipToCheck = $"{subnet}.{i}";
                        tasks.Add(Task.Run(async () =>
                        {
                            try
                            {
                                Ping ping = new Ping();
                                PingReply reply = await ping.SendPingAsync(ipToCheck, 100);
                                if (reply.Status == IPStatus.Success)
                                {
                                    try
                                    {
                                        IPHostEntry host = await Dns.GetHostEntryAsync(ipToCheck);
                                        if (host.HostName.Contains(".local"))
                                            host.HostName = host.HostName.Replace(".local", "");
                                        if (host.HostName.Contains(".docker"))
                                            host.HostName = host.HostName.Replace(".docker", "");
                                        if (host.HostName.Contains(".internal"))
                                            host.HostName = host.HostName.Replace(".internal", "");
                                        lock (pcList)
                                        {
                                            pcList.Add(ipToCheck, host.HostName);
                                        }
                                    }
                                    catch (SocketException)
                                    {
                                        lock (pcList)
                                        {
                                            pcList.Add(ipToCheck, "Unknown Host Name");
                                        }
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                LogError(ex);
                            }
                        }));
                    }
                }
            }

            await Task.WhenAll(tasks);
            //change the cursor back to default
            this.Cursor = Cursors.Default;
            return pcList;

        }

        private void LogError(Exception ex)
        {
            throw new NotImplementedException();
        }


    }
}
