const MongoClient = require('mongodb').MongoClient;

async function startChangeStream() {
  const client = await MongoClient.connect('mongodb+srv://admin:admin@cluster0.8dymixf.mongodb.net');
  const db = client.db('test');
  const collection = db.collection('books');
  const collectionWatch = collection.watch();//{ fullDocument: 'updateLookup' }
  const AuditColl = db.collection('AuditCollection');
  await collectionWatch.on('change', async (next) => {
    console.log('Received change event:', next);
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

// db.adminCommand( { setFeatureCompatibilityVersion: "6.0" } );
//   db.command({
//     collMod: "books",
//     changeStreamPreAndPostImages: { enabled: true } 
//   }, function (err, res) {
//     console.log(res);
//     client.close();
//   });
