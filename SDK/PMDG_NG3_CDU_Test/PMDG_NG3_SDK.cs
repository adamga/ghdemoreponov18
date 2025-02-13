using System.Runtime.InteropServices;

namespace PMDG_NG3_CDU_Test
{
    public static class PMDG_NG3_SDK
    {
        public const int CDU_ROWS = 14;
        public const int CDU_COLUMNS = 24;
        public const string PMDG_NG3_CDU_0_NAME = "PMDG_NG3_CDU_0";
        public const uint PMDG_NG3_CDU_0_ID = 0x4E474433;
        public const uint PMDG_NG3_CDU_0_DEFINITION = 0;

        public static class PMDG_NG3_CDU_FLAG
        {
            public const byte SMALL_FONT = 0x01;
            public const byte REVERSE = 0x02;
            public const byte UNUSED = 0x04;
        }

        public static class PMDG_NG3_CDU_COLOR
        {
            public const byte WHITE = 0;
            public const byte GREEN = 1;
            public const byte CYAN = 2;
            public const byte MAGENTA = 3;
            public const byte AMBER = 4;
            public const byte RED = 5;
        }
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct PMDG_NG3_CDU_Cell
    {
        public byte Symbol;
        public byte Color;
        public byte Flags;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct PMDG_NG3_CDU_Screen
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = PMDG_NG3_SDK.CDU_ROWS * PMDG_NG3_SDK.CDU_COLUMNS)]
        public PMDG_NG3_CDU_Cell[] Cells;
    }
}