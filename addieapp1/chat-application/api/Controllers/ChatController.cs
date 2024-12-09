using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using YourNamespace.Models; // Update with the actual namespace
using YourNamespace.Services; // Update with the actual namespace

namespace YourNamespace.Controllers // Update with the actual namespace
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatController : ControllerBase
    {
        private readonly OpenAIService _openAIService;

        public ChatController(OpenAIService openAIService)
        {
            _openAIService = openAIService;
        }

        [HttpPost("inquire")]
        public async Task<IActionResult> Inquire([FromBody] ChatRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.UserInput))
            {
                return BadRequest("Invalid chat request.");
            }

            var response = await _openAIService.GetResponseAsync(request.UserInput);
            return Ok(response);
        }
    }
}