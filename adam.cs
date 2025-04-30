using System;

public class Greetings
{
    public void SayHelloWorld()
    {
        Console.WriteLine("Hello, World!");
    }

    public void SayHelloToUser()
    {
        Console.Write("Enter your name: ");
        string userName = Console.ReadLine();
        Console.WriteLine($"Hello, {userName}!");
    }
}