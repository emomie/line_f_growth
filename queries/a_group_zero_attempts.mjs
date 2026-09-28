// 前提: out/ に groups.json(queries/groups_active_3m.sql) / a_menus.json / a_tickets.json を取得済み。課金メニュー送信時刻から「残高0で話しかけた回数」を推定する
import fs from "node:fs";
const J = f => JSON.parse(fs.readFileSync(`out/${f}.json`, "utf8"));
const ts = s => new Date(s.replace(" ", "T") + "+09:00").getTime();
const menus = J("a_menus"), tickets = J("a_tickets"), groups = J("groups");
const uses = {};
for (const t of tickets) if (t.status === "used" && t.used_at) (uses[t.user_id] ??= []).push(ts(t.used_at));
// pending 3件（単発/3回/10回）を1回のメニュー送信にまとめる
const byU = {};
for (const m of menus) (byU[m.user_id] ??= []).push(ts(m.created));
const rows = [];
for (const g of groups.filter(x => x.grp === "A")) {
  const t = (byU[g.id] || []).sort((a, b) => a - b);
  const sends = [];
  for (const x of t) if (!sends.length || x - sends.at(-1) > 10_000) sends.push(x);
  const closing = sends.filter(s => (uses[g.id] || []).some(u => s >= u - 5_000 && s - u < 180_000));
  const atZero = sends.filter(s => !closing.includes(s));
  const days = new Set(atZero.map(s => new Date(s + 9 * 3600e3).toISOString().slice(0, 10)));
  const recent = atZero.filter(s => s >= ts("2026-06-28 00:00:00"));
  rows.push({ id: g.id, reg: g.reg, menus: sends.length, closing: closing.length, at_zero: atZero.length, zero_days: days.size, at_zero_3m: recent.length,
    hours: atZero.map(s => new Date(s + 9 * 3600e3).getUTCHours()) });
}
fs.writeFileSync("out/a_zero_attempts.json", JSON.stringify(rows, null, 1));
const dist = k => { const c = {}; for (const r of rows) { const v = r[k] >= 10 ? "10+" : r[k] >= 4 ? "4-9" : String(r[k]); c[v] = (c[v] || 0) + 1; } return c; };
console.log("A群", rows.length, "人");
console.log("メニュー自動送信あり", rows.filter(r => r.menus).length, "人");
console.log("残高0で話しかけた人", rows.filter(r => r.at_zero).length, "人 / 合計", rows.reduce((s, r) => s + r.at_zero, 0), "回");
console.log("  直近3ヶ月(6/28-)", rows.filter(r => r.at_zero_3m).length, "人 / 合計", rows.reduce((s, r) => s + r.at_zero_3m, 0), "回");
console.log("人ごとの回数分布", dist("at_zero"));
console.log("人ごとの日数分布", dist("zero_days"));
const h = {}; rows.flatMap(r => r.hours).forEach(x => { const b = x >= 22 || x < 3 ? "22-3時" : x < 7 ? "3-7時" : x < 12 ? "7-12時" : x < 18 ? "12-18時" : "18-22時"; h[b] = (h[b] || 0) + 1; });
console.log("時間帯", h);
console.log("上位", rows.sort((a, b) => b.at_zero - a.at_zero).slice(0, 8).map(r => `u${r.id}:${r.at_zero}回/${r.zero_days}日`).join(" "));
