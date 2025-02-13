using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System;
using System.Windows.Threading;
using System.Runtime.InteropServices;

namespace PMDG_NG3_CDU_Test
{
    public partial class MainWindow : Window
    {
        // Add SDK constants
        private const uint THIRD_PARTY_EVENT_ID_MIN = 0x00011000;
        private const uint EVT_OH_ELEC_BATTERY_SWITCH = THIRD_PARTY_EVENT_ID_MIN + 1;
        private const uint EVT_OH_ELEC_BATTERY_GUARD = THIRD_PARTY_EVENT_ID_MIN + 2;

        private IntPtr hSimConnect;
        private DispatcherTimer timer;
        private CDURenderer cduRenderer;
        private PMDG_NG3_CDU_Screen screen;

        private void cbSwitchBattery(int switch_id, int dir)
        {
            if (gSwitch[switch_id].closed)
            {
                // If guard is closed, open it
                SimConnect.SimConnect_TransmitClientEvent(
                    hSimConnect,
                    0,
                    EVT_OH_ELEC_BATTERY_GUARD,
                    0,
                    SIMCONNECT_GROUP_PRIORITY.HIGHEST,
                    SIMCONNECT_EVENT_FLAG.GROUPID_IS_PRIORITY);
                return;
            }

            // Toggle battery switch
            SimConnect.SimConnect_TransmitClientEvent(
                hSimConnect,
                0,
                EVT_OH_ELEC_BATTERY_SWITCH,
                (uint)(dir > 0 ? 1 : 0),
                SIMCONNECT_GROUP_PRIORITY.HIGHEST,
                SIMCONNECT_EVENT_FLAG.GROUPID_IS_PRIORITY);
        }

        public MainWindow()
        {
            InitializeComponent();
            
            cduRenderer = new CDURenderer(CDUCanvas);
            InitializeSimConnect();
            
            timer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(100)
            };
            timer.Tick += Timer_Tick;
            timer.Start();
            
            Closed += MainWindow_Closed;
        }
    }
}