using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using ResumeFunction;
using System.Linq;
using Microsoft.Azure.Documents.Client;
using Microsoft.Azure.Documents;

namespace CounterFunction
{
    public static class CounterFunction
    {
        [FunctionName("counter")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            [CosmosDB("Stats", "Counters", Id = "id", ConnectionStringSetting = "CosmosDb")] IAsyncCollector<CounterStatsItem> counterItemsOut,
            [CosmosDB("Stats", "Counters", ConnectionStringSetting = "CosmosDb")] DocumentClient client,
            ILogger log)
        {
            log.LogInformation("Arrived counter request");

            //string name = req.Query["name"];

            //string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            //dynamic data = JsonConvert.DeserializeObject(requestBody);
            //name = name ?? data?.name;

            //string responseMessage = string.IsNullOrEmpty(name)
            //    ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
            //    : $"Hello, {name}. This HTTP triggered function executed successfully.";
            
            await counterItemsOut.AddAsync(new CounterStatsItem()
            {
                Id = DateTime.Now.Ticks.ToString(),
                Date = DateTime.Now,
                
            });

            var collectionUri = UriFactory.CreateDocumentCollectionUri("Stats", "Counters");
            var query = client.CreateDocumentQuery<dynamic>(collectionUri, new SqlQuerySpec()
            {
                QueryText = "SELECT VALUE COUNT(1) FROM Counters",
            });

            string totalCount = "";
            foreach (dynamic res in query)
            {
                totalCount = res;
            }
            return new OkObjectResult($"OK-{totalCount}");


        }
    }
}
