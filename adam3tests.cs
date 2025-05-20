using System;
using System.IO;
using NUnit.Framework;

[TestFixture]
public class GreetingsTests
{
    [Test]
    public void SayHelloToUser_ShouldGreetUserWithName()
    {
        // Arrange
        var greetings = new Greetings();
        var input = "Alice";
        var expectedOutput = "What is your name? Hello, Alice!\r\n";

        using (var inputReader = new StringReader(input))
        using (var outputWriter = new StringWriter())
        {
            Console.SetIn(inputReader);
            Console.SetOut(outputWriter);

            // Act
            greetings.SayHelloToUser();

            // Assert
            var actualOutput = outputWriter.ToString();
            Assert.AreEqual(expectedOutput, actualOutput);
        }
    }

    [Test]
    public void SayHelloToUser_ShouldHandleEmptyName()
    {
        // Arrange
        var greetings = new Greetings();
        var input = "";
        var expectedOutput = "What is your name? Hello, !\r\n";

        using (var inputReader = new StringReader(input))
        using (var outputWriter = new StringWriter())
        {
            Console.SetIn(inputReader);
            Console.SetOut(outputWriter);

            // Act
            greetings.SayHelloToUser();

            // Assert
            var actualOutput = outputWriter.ToString();
            Assert.AreEqual(expectedOutput, actualOutput);
        }
    }

    [Test]
    public void SayHelloToUser_ShouldHandleNullName()
    {
        // Arrange
        var greetings = new Greetings();
        var input = "\0";
        var expectedOutput = "What is your name? Hello, \0!\r\n";

        using (var inputReader = new StringReader(input))
        using (var outputWriter = new StringWriter())
        {
            Console.SetIn(inputReader);
            Console.SetOut(outputWriter);

            // Act
            greetings.SayHelloToUser();

            // Assert
            var actualOutput = outputWriter.ToString();
            Assert.AreEqual(expectedOutput, actualOutput);
        }
    }
}