import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import sqlite3 from 'sqlite3';
import { open } from 'sqlite';
import { toBytes, toHex } from 'viem'

const app = new Hono();

let db;

(async () => {
  db = await open({
    filename: './server/database.db',
    driver: sqlite3.Database,
  });

  // Create the user table if it doesn't exist
  await db.run(`
    CREATE TABLE IF NOT EXISTS did (
      id TEXT,
      document TEXT,
      signature TEXT
    )
  `);

  console.log('Connected to the Base ID database');
})();

app.get('/', (c) => c.text("BA5E ID--Discover What's Possible"));

app.get('/:id', async (c) => {
    const { id } = c.req.param();
    try {
      // Query the database for the user with the given address
      const user = await db.get(`SELECT id, document, signature FROM did WHERE id = ?`, [
        id.toLowerCase(),
      ]);
  
      if (user) {
          console.log('Base ID returned: ', user);
        return c.text(user.signature + toHex(toBytes(user.document)));
      } else {
        return c.text('Base ID not found', 404);
      }
    } catch (err) {
      console.error('Error querying the database', err.message);
      return c.text('Error querying the database', 500);
    }
});

// Change the method from GET to POST
app.post('/write', async (c) => {
    try {
        const { address, document, signature } = await c.req.json();
        if (!address || !document || !signature) {
            return c.text('Missing address or document in request body', 400);
        }
        await db.run(`INSERT INTO did (id, document, signature) VALUES (?, ?, ?)`, [address.toLowerCase(), document, signature]);
        console.log('Base ID created successfully');
        return c.text('Data inserted successfully');
    } catch (err) {
        console.error('Error inserting into database', err.message);
        console.error('Error inserting into database', err.message);
        return c.text('Error inserting into database', 500);
    }
});

serve(
  {
    port: 4200,
    hostname: 'localhost',
    fetch: app.fetch.bind(app),
  },
  (info) => {
    console.log(`Listening on http://localhost:${info.port}`);
  }
);
