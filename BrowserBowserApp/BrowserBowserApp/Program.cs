/*
 * File: Program.cs
 * Purpose: Main entry point for the BrowserBowser Windows Forms application
 * 
 * Description:
 * This file contains the primary entry point and initialization logic for the
 * BrowserBowser application. It configures the application settings and starts
 * the main form (Form1) using Windows Forms framework.
 * 
 * Logic:
 * - Initializes application configuration including DPI settings
 * - Creates and runs the main application form (Form1)
 * - Uses STAThread model for COM interoperability support
 * 
 * Security Considerations:
 * - Uses STAThread which is required for certain COM operations but may have
 *   security implications when interacting with browser components
 * - Application.Run creates a message loop that processes Windows messages,
 *   potential for message injection attacks if not properly validated
 * - ApplicationConfiguration.Initialize() may load configuration from external
 *   sources which should be validated and sanitized
 */

namespace BrowserBowserApp
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();
            Application.Run(new Form1());
        }
    }
}