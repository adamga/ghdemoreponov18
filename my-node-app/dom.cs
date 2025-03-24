//create a new class named dom

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Net;
using System.Net.Http;

namespace dom
{
// create a class named domisclassy and implement the main method
    class domisclassy
    {
        static void Main(string[] args)
        {
            // create a new instance of the class
            domisclassy dom = new domisclassy();
            // call the method to get the HTML content
            string htmlContent = dom.GetHtmlContent("https://example.com");
            // print the HTML content to the console
            Console.WriteLine(htmlContent);

            string favcolor = "blue";
        }

        // create a method to get the HTML content from a URL
        public string GetHtmlContent(string url)
        {
            using (HttpClient client = new HttpClient())
            {
                return client.GetStringAsync(url).Result;
            }
        }

        public void PrintHtmlContent(string htmlContent)
        {
            Console.WriteLine(htmlContent);
        }


        // create a method to save the HTML content to a file
        public void SaveHtmlContentToFile(string htmlContent, string filePath)
        {
            File.WriteAllText(filePath, htmlContent);
        }

        // create a method to read the HTML content from a file
        public string ReadHtmlContentFromFile(string filePath)
        {
            return File.ReadAllText(filePath);
        }

        // create a method to parse the HTML content and extract specific data
        public string ParseHtmlContent(string htmlContent)
        {
            // Implement your parsing logic here
            return "Parsed data";
        }

        // createa a mthod that says hello to dom in french
        public void SayHelloInFrench()
        {
            Console.WriteLine("Bonjour, dom!");
        }

        // faites un mthod qui dit bonjour a dom en francais
        public void SayHelloInFrench(string name)
        {
            Console.WriteLine($"Bonjour, {name}!");
        }
    }
    
}
