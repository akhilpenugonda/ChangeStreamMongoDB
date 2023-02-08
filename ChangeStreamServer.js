import React, { useState, useEffect } from 'react';
import {MongoClient} from 'mongodb';

function ChangeStreamApp() {
  const [changes, setChanges] = useState([]);

  useEffect(() => {
    async function startChangeStream() {
      const client = await MongoClient.MongoClient.connect('mongodb+srv://admin:admin@cluster0.grcivgr.mongodb.net');
      const db = client.db('test');
      const collection = db.collection('Books');

      const changeStream = collection.watch();

      changeStream.on('change', (next) => {
        setChanges([...changes, next]);
      });
    }

    startChangeStream();
  }, []);

  return (
    <div>
      <h2>Change Stream</h2>
      <ul>
        {changes.map((change, index) => (
          <li key={index}>{JSON.stringify(change)}</li>
        ))}
      </ul>
    </div>
  );
}

export default ChangeStreamApp;
