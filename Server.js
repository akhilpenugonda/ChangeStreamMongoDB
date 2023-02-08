const MongoClient = require('mongodb').MongoClient;

async function startChangeStream() {
  const client = await MongoClient.connect('mongodb+srv://admin:admin@cluster0.8dymixf.mongodb.net');
  const db = client.db('test');
  const collection = db.collection('books');
  list = collection.find();
  console.log(list);
  const changeStream = collection.watch();
  const AuditColl = db.collection('AuditCollection');

  await changeStream.on('change', async (next) => {
    console.log('Received change event:', next);
    const result = await AuditColl.insertOne({"operationType": next.operationType,"fullDocument": next.fullDocument
  })
  });
}

startChangeStream();
