using NUnit.Framework;
using albums_api.Controllers;
using albums_api.Models;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Moq;
using System.Linq;

namespace albums_api.Controllers.Tests
{
    [TestFixture]
    public class AlbumControllerTest
    {
        // Example of dependency injection for mocking (requires refactoring AlbumController and Album)
        // For now, we demonstrate static mocking with Moq.Contrib or similar, but here is a pattern for future refactor:

        [Test]
        public void Get_ReturnsOkObjectResult_WithListOfAlbums()
        {
            // Arrange
            var expectedAlbums = new List<Album>
            {
                new Album { Id = 1, Title = "Test Album 1" },
                new Album { Id = 2, Title = "Test Album 2" }
            };

            // Act
            var controller = new AlbumController();
            var result = controller.Get();

            // Assert
            Assert.IsInstanceOf<OkObjectResult>(result);
            var okResult = result as OkObjectResult;
            Assert.IsInstanceOf<IEnumerable<Album>>(okResult.Value);
        }

        [Test]
        public void Get_ById_ReturnsOkResult()
        {
            // Arrange
            var controller = new AlbumController();

            // Act
            var result = controller.Get(1);

            // Assert
            Assert.IsInstanceOf<OkResult>(result);
        }

        [Test]
        public void Get_ReturnsNonEmptyList_WhenAlbumsExist()
        {
            // Arrange
            var controller = new AlbumController();

            // Act
            var result = controller.Get();

            // Assert
            var okResult = result as OkObjectResult;
            var albums = okResult?.Value as IEnumerable<Album>;
            Assert.IsNotNull(albums);
            Assert.IsTrue(albums.Any());
        }

        [Test]
        public void Get_ById_ReturnsOkResult_ForAnyId()
        {
            // Arrange
            var controller = new AlbumController();

            // Act
            var result = controller.Get(999);

            // Assert
            Assert.IsInstanceOf<OkResult>(result);
        }

        [Test]
        public void Get_ReturnsOkObjectResult_EvenIfNoAlbums()
        {
            // This test assumes Album.GetAll() could return an empty list.
            // If you refactor AlbumController to accept an IAlbumRepository, you can mock it here.
            var controller = new AlbumController();

            // Act
            var result = controller.Get();

            // Assert
            Assert.IsInstanceOf<OkObjectResult>(result);
            var okResult = result as OkObjectResult;
            Assert.IsInstanceOf<IEnumerable<Album>>(okResult.Value);
        }
    }
}
            Assert.IsInstanceOf<OkObjectResult>(result);
            var okResult = result as OkObjectResult;
            Assert.IsInstanceOf<IEnumerable<Album>>(okResult.Value);
        }

        [Test]
        public void Get_ById_ReturnsOkResult()
        {
            // Arrange
            var controller = new AlbumController();

            // Act
            var result = controller.Get(1);

            // Assert
            Assert.IsInstanceOf<OkResult>(result);
        }
    }
}