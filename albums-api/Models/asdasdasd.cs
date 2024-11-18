using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using albums_api.Models;

namespace albums_api.Tests
{
    [TestClass]
    public class AlbumTests
    {
        [TestMethod]
        public void GetAll_ShouldReturnCorrectNumberOfAlbums()
        {
            // Arrange
            var expectedCount = 6;

            // Act
            var albums = Album.GetAll();

            // Assert
            Assert.AreEqual(expectedCount, albums.Count);
        }

        [TestMethod]
        public void GetAll_FirstAlbumShouldHaveCorrectProperties()
        {
            // Arrange
            var expectedId = 1;
            var expectedTitle = "You, Me and an App Id";
            var expectedArtist = "Daprize";
            var expectedPrice = 10.99;
            var expectedImageUrl = "https://aka.ms/albums-daprlogo";

            // Act
            var albums = Album.GetAll();
            var firstAlbum = albums[0];

            // Assert
            Assert.AreEqual(expectedId, firstAlbum.Id);
            Assert.AreEqual(expectedTitle, firstAlbum.Title);
            Assert.AreEqual(expectedArtist, firstAlbum.Artist);
            Assert.AreEqual(expectedPrice, firstAlbum.Price);
            Assert.AreEqual(expectedImageUrl, firstAlbum.Image_url);
        }

        [TestMethod]
        public void GetAll_LastAlbumShouldHaveCorrectProperties()
        {
            // Arrange
            var expectedId = 6;
            var expectedTitle = "Sweet Container O' Mine";
            var expectedArtist = "Guns N Probeses";
            var expectedPrice = 14.99;
            var expectedImageUrl = "https://aka.ms/albums-containerappslogo";

            // Act
            var albums = Album.GetAll();
            var lastAlbum = albums[albums.Count - 1];

            // Assert
            Assert.AreEqual(expectedId, lastAlbum.Id);
            Assert.AreEqual(expectedTitle, lastAlbum.Title);
            Assert.AreEqual(expectedArtist, lastAlbum.Artist);
            Assert.AreEqual(expectedPrice, lastAlbum.Price);
            Assert.AreEqual(expectedImageUrl, lastAlbum.Image_url);
        }
    }
}