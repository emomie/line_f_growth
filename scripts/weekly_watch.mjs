// 止める条件の週次監視: node scripts/weekly_watch.mjs
import { execFileSync } from "node:child_process";

const json = execFileSync(process.execPath, ["scripts/db.mjs", "-f", "queries/weekly_heavy_new_users.sql"], { encoding: "utf8" });
console.log("週(月〜)     新規 新規30日 10回超(新規) 比率  10回超(全体) 1日最大");
for (const x of JSON.parse(json)) {
  const pct = x.new_30d ? ((x.heavy_new / x.new_30d) * 100).toFixed(1) + "%" : "-";
  const flag = x.new_30d && x.heavy_new / x.new_30d > 0.01 ? "  ← 止める条件" : "";
  console.log(x.week_start, String(x.new_this_week).padStart(4), String(x.new_30d).padStart(7), String(x.heavy_new).padStart(9),
    pct.padStart(7), String(x.heavy_all).padStart(9), String(x.max_per_day ?? "-").padStart(7) + flag);
}
