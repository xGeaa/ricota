import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { supabase } from './db/supabase.js';

const app = express();
const PORT = process.env.PORT ?? 3000;

app.use(cors());
app.use(express.json());

app.get('/health', async (_req, res) => {
  const { count, error } = await supabase
    .from('characters')
    .select('*', { count: 'exact', head: true });

  if (error) {
  return res.status(500).json({ status: 'error', message: error.message });
}

  res.json({ status: 'ok', project: 'ricota-api', characters_count: count });
});

app.listen(PORT, () => {
  console.log(`Ricota API running on port ${PORT}`);
});