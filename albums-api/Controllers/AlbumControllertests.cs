// csharp
using Xunit;
using albums_api.Controllers;
using albums_api.Models;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;

namespace albums_api.Controllers.Tests
{
    public class AlbumControllerTest
    {
        [Fact]
        public void Get_ReturnsOkObjectResult_WithListOfAlbums()
        {
            // Arrange
            var expectedAlbums = new List<Album>
            {
                new Album { Id = 1, Title = "Test Album 1" },
                new Album { Id = 2, Title = "Test Album 2" }
            };

            // Temporarily replace Album.GetAll() with test data using a delegate or similar approach if possible.
            // If Album.GetAll() cannot be mocked, this test will call the real method.

            // Act
            var controller = new AlbumController();
            var result = controller.Get();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.IsAssignableFrom<IEnumerable<Album>>(okResult.Value);
        }

        [Fact]
        public void Get_ById_ReturnsOkResult()
        {
            // Arrange
            var controller = new AlbumController();

            // Act
            var result = controller.Get(1);

            // Assert
            Assert.IsType<OkResult>(result);
        }
    }
}