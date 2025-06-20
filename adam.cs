/*
 * File: adam.cs
 * Purpose: Simple C# console application demonstrating basic output functionality
 * 
 * Description:
 * This file contains a basic "Hello World" style application that outputs greeting
 * messages to the console. It serves as a simple demonstration of C# 13.0 features
 * and basic console I/O operations.
 * 
 * Logic:
 * - Defines a static Greetings class with a Main entry point
 * - Outputs three hardcoded greeting messages to the console
 * - Uses System.Console.WriteLine for standard output
 * 
 * Security Considerations:
 * - No direct security concerns as this only outputs static strings
 * - No user input processing or external resource access
 * - No sensitive data handling or network operations
 */

using System;

public class Greetings
{

    public static void Main(string[] args)
    {
        Console.WriteLine("Hello, World!");
        Console.WriteLine("Welcome to C# programming.");
        Console.WriteLine("Let's explore the features of C# 13.0 together.");
    }
}