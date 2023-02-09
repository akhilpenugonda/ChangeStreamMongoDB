const MongoClient = require('mongodb').MongoClient;

async function startChangeStream() {
  const client = await MongoClient.connect('mongodb+srv://admin:admin@cluster0.8dymixf.mongodb.net');
  const db = client.db('test');
  const collection = db.collection('books');
  list = collection.find();
  // console.log(list);
  const changeStream = collection.watch();
  const AuditColl = db.collection('AuditCollection');
  
  await changeStream.on('change', async (next) => {
    console.log('Received change event:', next);
    resumeToken = next._id;
    await db.collection('resumeToken').updateOne({}, { $set: { resumeToken } }, { upsert: true });
    insertDocument = {"CollectionInfo": null, "Operation": null, "Decsription": null}
    insertDocument.CollectionInfo = next.ns.db + "." + next.ns.coll;
    switch(next.operationType){
      case "insert":
        insertDocument.Operation = next.fullDocument;
        insertDocument.Decsription = next.updateDescription;
        break;
      case "update":
        insertDocument.Operation = next.operationType;
        insertDocument.Decsription = next.updateDescription;
        break;
      }
    AuditColl.insertOne(insertDocument);
  });
  await databaseWatch(db);
}
async function databaseWatch(db)
{
  const AuditColl = db.collection('AuditCollection');
  const dbPipeline = [
    {
      $match: {
        $and: [
          {
            ns: {
              $ne: {
                db: "test",
                coll: "AuditCollection",
              },
            },
          },
          {
            ns: {
              $ne: {
                db: "test",
                coll: "resumeToken",
              },
            },
          },
        ],
      },
    },
  ];
  const dbWatch = db.watch(dbPipeline);
  await dbWatch.on('change', async (next) => {
    console.log('Received change event:', next);
    resumeToken = next._id;
    await db.collection('resumeToken').updateOne({}, { $set: { resumeToken } }, { upsert: true });
    insertDocument = {"CollectionInfo": null, "Operation": null, "Decsription": null}
    insertDocument.CollectionInfo = next.ns.db + "." + next.ns.coll;
    switch(next.operationType){
      case "insert":
        insertDocument.Operation = next.fullDocument;
        insertDocument.Decsription = next.updateDescription;
        break;
      case "update":
        insertDocument.Operation = next.operationType;
        insertDocument.Decsription = next.updateDescription;
        break;
      }
    AuditColl.insertOne(insertDocument);
  });
}
startChangeStream();
