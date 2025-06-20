/*
 * File: Program.cs (albums-api)
 * Purpose: Main entry point and configuration for the Albums API ASP.NET Core service
 * 
 * Description:
 * This file contains the application startup configuration for the Albums API service.
 * It configures the web application builder, services, middleware, CORS policies,
 * and Dapr integration for the microservices architecture.
 * 
 * Logic:
 * - Configures WebApplication builder with environment variables
 * - Sets up CORS policy allowing all origins, headers, and methods
 * - Adds controllers, Swagger/OpenAPI documentation, and HTTP client services
 * - Integrates with Dapr sidecar for state management and service communication
 * - Configures application pipeline with CORS, Swagger, and routing
 * 
 * Security Considerations:
 * - CRITICAL: CORS policy allows all origins - major security vulnerability
 * - CRITICAL: Environment variables used directly - validate and sanitize inputs
 * - CRITICAL: HTTP client without proper security configuration
 * - CRITICAL: No authentication or authorization configured
 * - CRITICAL: Swagger UI exposed in production - information disclosure risk
 * - CORS should be restricted to specific allowed origins
 * - Environment variables should be validated for format and content
 * - Authentication middleware should be added for protected endpoints
 * - Swagger should be disabled in production environments
 */

var builder = WebApplication.CreateBuilder(args);

var DefaultHttpPort = Environment.GetEnvironmentVariable("DAPR_HTTP_PORT") ?? "3500";
var AlbumStateStore = "statestore";
var CollectionId = Environment.GetEnvironmentVariable("COLLECTION_ID") ?? "GreatestHits";

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpClient();

builder.Services.AddCors(options => {
    options.AddDefaultPolicy(builder =>
    {
        builder.AllowAnyOrigin();
        builder.AllowAnyHeader();
        builder.AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseCors();

// app.Urls.Add("${ASPNETCORE_URLS}");

app.UseHttpsRedirection();

app.UseAuthorization();

app.UseRouting();

app.MapGet("/", async context =>
{
    await context.Response.WriteAsync("Hit the /albums endpoint to retrieve a list of albums!");
});

app.MapControllers();

app.Run();
