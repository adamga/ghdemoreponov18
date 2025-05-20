using System;

public class Greetings
{
    /// <summary>
    /// Prints a simple "Hello, World!" message to the console.
    /// This method demonstrates a basic console output operation.
    /// </summary>
    public void SayHelloWorld()
    {
        // Output the string "Hello, World!" to the console.
        Console.WriteLine("Hello, World!");
    }

    /// <summary>
    /// Prompts the user to enter their name and then greets them with a personalized message.
    /// This method demonstrates how to interact with the user via console input and output.
    /// </summary>
    public void SayHelloToUser()
    {
        // Declare a variable for the user's favorite color (currently unused).
        // This variable is included as an example of variable declaration.
        string favcolor = "blue";

        // Prompt the user to enter their name.
        Console.Write("What is your name? ");

        // Read the user's input from the console and store it in the 'name' variable.
        string name = Console.ReadLine();

        // Output a personalized greeting using the user's name.
        // If the user does not enter a name, the greeting will still display "Hello, !".
        Console.WriteLine($"Hello, {name}!");
    }

    /// <summary>
    /// Prints greetings in both French and Spanish to the console.
    /// This method demonstrates multilingual support and basic console output.
    /// </summary>
    public void SayHelloInFrenchAndSpanish()
    {
        // Output a greeting in French.
        Console.WriteLine("Bonjour, le monde!");

        // Output a greeting in Spanish.
        Console.WriteLine("Hola, mundo!");
    }
}