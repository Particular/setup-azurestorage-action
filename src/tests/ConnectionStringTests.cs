using Azure.Data.Tables;
using Azure.Storage.Blobs;
using Azure.Storage.Queues;
using NUnit.Framework;

namespace Tests;

[TestFixture]
public class ConnectionStringTests
{
    [Test]
    public async Task Should_establish_queue_connection()
    {
        var client = new QueueServiceClient(Environment.GetEnvironmentVariable("StorageConnectionString"));
        await client.CreateQueueAsync("testqueue");
    }
    
    [Test]
    public async Task Should_establish_table_connection()
    {
        var client = new TableServiceClient(Environment.GetEnvironmentVariable("StorageConnectionString"));
        await client.CreateTableAsync("testtable");
    }
    
    [Test]
    public async Task Should_establish_blob_connection()
    {
        var client = new BlobServiceClient(Environment.GetEnvironmentVariable("StorageConnectionString"));
        await client.CreateBlobContainerAsync("testblobcontainer");
    }
}