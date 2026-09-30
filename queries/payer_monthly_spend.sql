-- 課金者の月ごとの支払額と占い回数（サブスク導入時の共食い試算用）
-- 支払 = payments completed かつ amount>0。テスト id 1,2 除外。user59 も含めて出す（試算時に分けて見る）
-- used_all = その月の占い回数（無料含む）、max_day = その月の1日あたり最大回数
SELECT p.user_id, p.ym, p.spend, p.n_pay, p.items,
  COALESCE(t.used_all, 0) AS used_all, COALESCE(t.max_day, 0) AS max_day
FROM (
  SELECT user_id, DATE_FORMAT(created, '%Y-%m') AS ym, SUM(amount) AS spend, COUNT(*) AS n_pay,
    GROUP_CONCAT(amount ORDER BY created) AS items
  FROM payments
  WHERE status = 'completed' AND amount > 0 AND user_id NOT IN (1, 2)
  GROUP BY 1, 2
) p
LEFT JOIN (
  SELECT user_id, ym, SUM(n) AS used_all, MAX(n) AS max_day
  FROM (
    SELECT user_id, DATE_FORMAT(used_at, '%Y-%m') AS ym, DATE(used_at) AS d, COUNT(*) AS n
    FROM user_tickets WHERE status = 'used' GROUP BY 1, 2, 3
  ) x GROUP BY 1, 2
) t ON t.user_id = p.user_id AND t.ym = p.ym
ORDER BY p.user_id, p.ym
