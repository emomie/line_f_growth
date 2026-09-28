// 集計用: node scripts/db.mjs "SELECT ..."  または  node scripts/db.mjs -f query.sql  （結果はJSON）
import { readFileSync } from "node:fs";

const { env } = JSON.parse(readFileSync("D:/line_f_data/.mcp.json", "utf8")).mcpServers.mysql;
const raw = process.argv[2] === "-f" ? readFileSync(process.argv[3], "utf8") : process.argv[2];
// API は先頭が SELECT/SHOW/DESCRIBE/EXPLAIN の文しか通さないので、先頭のコメント行を落とす
const arg = raw.replace(/^(\s*--.*\n)+/, "").trim().replace(/;\s*$/, "");

const res = await fetch(env.DB_API_URL, {
  method: "POST",
  headers: { "Content-Type": "application/json", "X-API-Key": env.DB_API_KEY },
  body: JSON.stringify({ sql: arg }),
});
const data = await res.json();
if (!res.ok) {
  console.error(data.error || `HTTP ${res.status}`);
  process.exit(1);
}
console.log(JSON.stringify(data.rows, null, 1));
if (data.truncated) console.error(`[truncated at ${data.row_count} rows]`);
