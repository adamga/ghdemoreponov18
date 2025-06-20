/*
 * File: Album.cs
 * Purpose: Data model representing album information for the albums API service
 * 
 * Description:
 * This file defines the Album record type used throughout the albums-api service.
 * It provides the data structure for album information including metadata and
 * static methods for data retrieval. Uses C# record syntax for immutable data.
 * 
 * Logic:
 * - Defines Album record with Id, Title, Artist, Price, and Image_url properties
 * - Implements GetAll() static method returning hardcoded album collection
 * - Contains sample data for demonstration purposes with various tech-themed albums
 * - Uses external image URLs for album artwork hosted on Microsoft domains
 * 
 * Security Considerations:
 * - CRITICAL: External image URLs - potential for mixed content issues or broken links
 * - CRITICAL: Hardcoded data - not suitable for production use with real data
 * - CRITICAL: No data validation on properties - could accept malicious URLs or content
 * - CRITICAL: Image URLs from external sources may be vulnerable to manipulation
 * - Price values should be validated for reasonable ranges
 * - External URLs should be validated and use HTTPS only
 * - Consider implementing data access layer instead of hardcoded values
 * - Image URLs should be validated and potentially proxied for security
 */

namespace albums_api.Models
{
    public record Album(int Id, string Title, string Artist, double Price, string Image_url)
    {
        public static List<Album> GetAll()
        {
            var albums = new List<Album>(){
            new Album(1, "You, Me and an App Id", "Daprize", 10.99, "https://aka.ms/albums-daprlogo"),
            new Album(2, "Seven Revision Army", "The Blue-Green Stripes", 13.99, "https://aka.ms/albums-containerappslogo"),
            new Album(3, "Scale It Up", "KEDA Club", 13.99, "https://aka.ms/albums-kedalogo"),
            new Album(4, "Lost in Translation", "MegaDNS", 12.99,"https://aka.ms/albums-envoylogo"),
            new Album(5, "Lock Down Your Love", "V is for VNET", 12.99, "https://aka.ms/albums-vnetlogo"),
            new Album(6, "Sweet Container O' Mine", "Guns N Probeses", 14.99, "https://aka.ms/albums-containerappslogo")
         };

            return albums;
        }



    }
}
