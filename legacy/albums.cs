using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;

/// <summary>
/// Represents an album with its details.
/// </summary>
public class Album
{
    /// <summary>
    /// Gets or sets the album ID.
    /// </summary>
    public int AlbumId { get; set; }

    /// <summary>
    /// Gets or sets the artist name.
    /// </summary>
    public string Artist { get; set; }

    /// <summary>
    /// Gets or sets the album title.
    /// </summary>
    public string Title { get; set; }

    /// <summary>
    /// Gets or sets the release date of the album.
    /// </summary>
    public DateTime ReleaseDate { get; set; }
}

/// <summary>
/// The main program class.
/// </summary>
public class Program
{
    /// <summary>
    /// The main entry point of the program.
    /// </summary>
    public static void Main()
    {
        string filePath = "ALBUMS.DAT";
        List<Album> albums = ReadAlbumsFromFile(filePath);
        Dictionary<int, int> monthCounts = CountAlbumsByMonth(albums);
        DisplayMonthCounts(monthCounts);
    }

    /// <summary>
    /// Reads albums from a file.
    /// </summary>
    /// <param name="filePath">The path to the file containing album data.</param>
    /// <returns>A list of albums.</returns>
    public static List<Album> ReadAlbumsFromFile(string filePath)
    {
        var albums = new List<Album>();
        foreach (var line in File.ReadLines(filePath))
        {
            var fields = line.Split(',');
            var album = new Album
            {
                AlbumId = int.TryParse(fields[0], out int albumId) ? albumId : 0,
                Artist = fields[1].Trim(),
                Title = fields[2].Trim(),
                ReleaseDate = DateTime.ParseExact(fields[3].Trim(), "yyyy-MM", CultureInfo.InvariantCulture)
            };
            albums.Add(album);
        }
        return albums;
    }

    /// <summary>
    /// Counts the number of albums released in each month.
    /// </summary>
    /// <param name="albums">The list of albums.</param>
    /// <returns>A dictionary with the month as the key and the count of albums as the value.</returns>
    public static Dictionary<int, int> CountAlbumsByMonth(List<Album> albums)
    {
        var monthCounts = new Dictionary<int, int>();
        foreach (var album in albums)
        {
            int month = album.ReleaseDate.Month;
            if (monthCounts.ContainsKey(month))
            {
                monthCounts[month]++;
            }
            else
            {
                monthCounts[month] = 1;
            }
        }
        return monthCounts;
    }

    /// <summary>
    /// Displays the count of albums released in each month.
    /// </summary>
    /// <param name="monthCounts">A dictionary with the month as the key and the count of albums as the value.</param>
    public static void DisplayMonthCounts(Dictionary<int, int> monthCounts)
    {
        Console.WriteLine("Albums released per month:");
        for (int month = 1; month <= 12; month++)
        {
            if (monthCounts.ContainsKey(month))
            {
                Console.WriteLine($"{CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month)}: {monthCounts[month]}");
            }
            else
            {
                Console.WriteLine($"{CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month)}: 0");
            }
        }
    }
}