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
        private const string DATABASE_NAME = "stats";
        private const string COLLECTION_NAME = "counters";

        [FunctionName("counter")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            [CosmosDB(DATABASE_NAME, COLLECTION_NAME, Id = "id", ConnectionStringSetting = "CosmosDb")] IAsyncCollector<CounterStatsItem> counterItemsOut,
            [CosmosDB(DATABASE_NAME, COLLECTION_NAME, ConnectionStringSetting = "CosmosDb")] DocumentClient client,
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

            var collectionUri = UriFactory.CreateDocumentCollectionUri(DATABASE_NAME, COLLECTION_NAME);
            var query = client.CreateDocumentQuery<dynamic>(collectionUri, new SqlQuerySpec()
            {
                QueryText = "SELECT VALUE COUNT(1) FROM Counters",
            });

            var stats = new Stats();
            foreach (dynamic res in query)
            {
                stats.TotalCount = res;
            }
            return new OkObjectResult(stats);

        }
    }

    public class Stats 
    {
        public int TotalCount { get; set; }
    }
}
