using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace ChatApplication.Services
{
    public class OpenAIService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;
        private readonly string _endpoint;

        public OpenAIService(string apiKey, string endpoint)
        {
            _httpClient = new HttpClient();
            _apiKey = apiKey;
            _endpoint = endpoint;
        }

        public async Task<string> GetResponseAsync(string userInput)
        {
            var requestBody = new
            {
                prompt = userInput,
                max_tokens = 150
            };

            var requestJson = JsonConvert.SerializeObject(requestBody);
            var content = new StringContent(requestJson, Encoding.UTF8, "application/json");
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _apiKey);

            var response = await _httpClient.PostAsync(_endpoint, content);
            response.EnsureSuccessStatusCode();

            var responseJson = await response.Content.ReadAsStringAsync();
            dynamic jsonResponse = JsonConvert.DeserializeObject(responseJson);
            return jsonResponse.choices[0].text.ToString();
        }
    }
}