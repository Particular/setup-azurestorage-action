using System.Data.Common;
using Azure.Data.Tables;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Queues;
using NUnit.Framework;

namespace Tests;

[TestFixture]
public class DefaultCredentialTests
{
    string baseUrlTemplate;

    [SetUp]
    public void Setup()
    {
        var connectionString = Environment.GetEnvironmentVariable("StorageConnectionString");

        var connectionBuilder = new DbConnectionStringBuilder
        {
            ConnectionString = connectionString
        };

        baseUrlTemplate = $"https://{connectionBuilder["AccountName"]}.{{0}}.{connectionBuilder["EndpointSuffix"]}";
    }

    [Test]
    public async Task Should_establish_queue_connection()
    {
        var client = new QueueServiceClient(new Uri(string.Format(baseUrlTemplate, "queue")), new DefaultAzureCredential());
        await client.CreateQueueAsync("testqueuedefault");
    }
    
    [Test]
    public async Task Should_establish_table_connection()
    {
        var client = new TableServiceClient(new Uri(string.Format(baseUrlTemplate, "table")), new DefaultAzureCredential());
        await client.CreateTableAsync("testtabledefault");
    }
    
    [Test]
    public async Task Should_establish_blob_connection()
    {
        var client = new BlobServiceClient(new Uri(string.Format(baseUrlTemplate, "blob")), new DefaultAzureCredential());
        await client.CreateBlobContainerAsync("testblobcontainerdefault");
    }
}