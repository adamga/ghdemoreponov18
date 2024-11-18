using albums_api.Controllers;
using albums_api.Models;
using Microsoft.AspNetCore.Mvc;
using Moq;
using System.Collections.Generic;
using Xunit;

namespace albums_api.Tests.Controllers
{
    public class AlbumControllerTest
    {
        private readonly Mock<IAlbumRepository> _mockRepo;
        private readonly AlbumController _controller;

        public AlbumControllerTest()
        {
            _mockRepo = new Mock<IAlbumRepository>();
            _controller = new AlbumController(_mockRepo.Object);
        }

        [Fact]
        public void Get_ReturnsOkResult_WithListOfAlbums()
        {
            // Arrange
            var mockAlbums = new List<Album>
            {
                new Album { Id = 1, Title = "Album1" },
                new Album { Id = 2, Title = "Album2" }
            };
            _mockRepo.Setup(repo => repo.GetAll()).Returns(mockAlbums);

            // Act
            var result = _controller.Get();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnAlbums = Assert.IsType<List<Album>>(okResult.Value);
            Assert.Equal(2, returnAlbums.Count);
        }

        [Fact]
        public void Get_WithValidId_ReturnsOkResult_WithAlbum()
        {
            // Arrange
            var mockAlbum = new Album { Id = 1, Title = "Album1" };
            _mockRepo.Setup(repo => repo.GetById(1)).Returns(mockAlbum);

            // Act
            var result = _controller.Get(1);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnAlbum = Assert.IsType<Album>(okResult.Value);
            Assert.Equal(1, returnAlbum.Id);
        }

        [Fact]
        public void Get_WithInvalidId_ReturnsNotFoundResult()
        {
            // Arrange
            _mockRepo.Setup(repo => repo.GetById(1)).Returns((Album)null);

            // Act
            var result = _controller.Get(1);

            // Assert
            Assert.IsType<NotFoundResult>(result);
        }
    }
}