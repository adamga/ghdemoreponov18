using System;
using System.IO;

internal static class Program
{
    // Fixed-width layout from the COBOL FD:
    // AlbumId(7) Artist(8) Title(20) Year(4) Month(2) Day(2) Genre(10) = 53 chars
    private const int RecordLength = 53;

    private static readonly string[] Months =
    {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    };

    private static int Main(string[] args)
    {
        var counts = new int[12];

        // Match COBOL: SELECT AlbumFile ASSIGN TO "ALBUMS.DAT"
        // Prefer executable folder; fall back to current directory.
        var baseDirPath = Path.Combine(AppContext.BaseDirectory, "ALBUMS.DAT");
        var cwdPath = Path.Combine(Environment.CurrentDirectory, "ALBUMS.DAT");
        var filePath = File.Exists(baseDirPath) ? baseDirPath : cwdPath;

        if (!File.Exists(filePath))
        {
            Console.Error.WriteLine($"ALBUMS.DAT not found. Looked in:\n  {baseDirPath}\n  {cwdPath}");
            return 1;
        }

        foreach (var lineRaw in File.ReadLines(filePath))
        {
            var line = lineRaw ?? string.Empty;
            if (line.Length < RecordLength)
            {
                // Skip malformed/short lines (COBOL would still READ a record; here we guard).
                continue;
            }

            // Offsets based on fixed-width fields
            // 0..6   AlbumId
            // 7..14  Artist
            // 15..34 Title
            // 35..38 Year
            // 39..40 Month
            // 41..42 Day
            // 43..52 Genre
            var moText = line.Substring(39, 2);

            if (!int.TryParse(moText, out var month) || month < 1 || month > 12)
                continue;

            counts[month - 1]++;
        }

        Console.WriteLine(" Month    AlbumCount");
        for (var i = 0; i < 12; i++)
        {
            // COBOL used PIC X(9) for month names
            Console.WriteLine($"{Months[i].PadRight(9)} {counts[i]}");
        }

        return 0;
    }
}