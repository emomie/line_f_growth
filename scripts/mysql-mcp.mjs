// line_f_data/.mcp.json の接続情報を読み、同じ mysql-proxy を起動する（APIキーをこのリポに置かないため）
import { readFileSync } from "node:fs";
import { spawn } from "node:child_process";

const DATA_DIR = "D:/line_f_data";
const { env } = JSON.parse(readFileSync(`${DATA_DIR}/.mcp.json`, "utf8")).mcpServers.mysql;

const child = spawn(process.execPath, [`${DATA_DIR}/mcp-mysql-proxy/index.mjs`], {
  stdio: "inherit",
  env: { ...process.env, ...env },
});
child.on("exit", (code) => process.exit(code ?? 0));
