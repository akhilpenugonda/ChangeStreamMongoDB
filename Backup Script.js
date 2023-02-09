const MongoClient = require('mongodb').MongoClient;

async function startChangeStream() {
  const client = await MongoClient.connect('mongodb+srv://admin:admin@cluster0.8dymixf.mongodb.net');
  const db = client.db('test');
  await booksWatch(db);
  await databaseWatch(db);
}
async function booksWatch(db)
{
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
        insertDocument.Operation = next.operationType;
        insertDocument.Decsription = next.fullDocument;
        break;
      case "update":
        insertDocument.Operation = next.operationType;
        insertDocument.Decsription = next.updateDescription;
        break;
      }
    AuditColl.insertOne(insertDocument);
  });
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
        insertDocument.Operation = next.operationType;
        insertDocument.Decsription = next.fullDocument;
        break;
      case "update":
        insertDocument.Operation = next.operationType;
        insertDocument.Decsription = next.updateDescription;
        break;
      }
    AuditColl.insertOne(insertDocument);
  });
}
async function resumeIfAny(db)
{
  let resumeToken = await db.collection('resumeToken').findOne({});
  resumeToken = resumeToken ? resumeToken.resumeToken : {};
  const changeStream = client.watch([], { startAtOperationTime: resumeToken });
  changeStream.on('change', async next => {
    console.log('Change detected: ', next);
    resumeToken = next._id;
    await db.collection('resumeToken').updateOne({}, { $set: { resumeToken } }, { upsert: true });
  });
}
startChangeStream();
