namespace PMDG_NG3_CDU_Test
{
    public enum SIMCONNECT_GROUP_PRIORITY : uint
    {
        HIGHEST = 1,
        HIGHEST_MASKABLE = 10000000,
        STANDARD = 2000000000,
        DEFAULT = 2000000000,
        LOWEST = 4000000000
    }

    public enum SIMCONNECT_EVENT_FLAG : uint
    {
        GROUPID_IS_PRIORITY = 1
    }
}