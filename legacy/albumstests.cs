using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;

[TestFixture]
public class AlbumTests
{
    private const string TestFilePath = "test_albums.dat";

    [SetUp]
    public void SetUp()
    {
        var testData = new List<string>
        {
            "1,Artist1,Title1,2022-01",
            "2,Artist2,Title2,2022-02",
            "3,Artist3,Title3,2022-01",
            "4,Artist4,Title4,2022-03"
        };
        File.WriteAllLines(TestFilePath, testData);
    }

    [TearDown]
    public void TearDown()
    {
        if (File.Exists(TestFilePath))
        {
            File.Delete(TestFilePath);
        }
    }

    [Test]
    public void ReadAlbumsFromFile_ShouldReturnCorrectNumberOfAlbums()
    {
        var albums = Program.ReadAlbumsFromFile(TestFilePath);
        Assert.AreEqual(4, albums.Count);
    }

    [Test]
    public void CountAlbumsByMonth_ShouldReturnCorrectCounts()
    {
        var albums = Program.ReadAlbumsFromFile(TestFilePath);
        var monthCounts = Program.CountAlbumsByMonth(albums);

        Assert.AreEqual(2, monthCounts[1]);
        Assert.AreEqual(1, monthCounts[2]);
        Assert.AreEqual(1, monthCounts[3]);
    }

    [Test]
    public void DisplayMonthCounts_ShouldDisplayCorrectOutput()
    {
        var albums = Program.ReadAlbumsFromFile(TestFilePath);
        var monthCounts = Program.CountAlbumsByMonth(albums);

        using (var sw = new StringWriter())
        {
            Console.SetOut(sw);
            Program.DisplayMonthCounts(monthCounts);
            var result = sw.ToString().Trim();

            var expectedOutput = string.Join(Environment.NewLine, new[]
            {
                "January: 2",
                "February: 1",
                "March: 1",
                "April: 0",
                "May: 0",
                "June: 0",
                "July: 0",
                "August: 0",
                "September: 0",
                "October: 0",
                "November: 0",
                "December: 0"
            });

            Assert.AreEqual(expectedOutput, result);
        }
    }
}