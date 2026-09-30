-- 登録月コホートの月次定着（PMFの確認用）
-- 母数 = その月に登録したユーザー全員（テスト id 1,2 除外。学生12名はID一覧が無く除外できていない）
-- M{k} = 登録月からk暦月後に、占い（user_tickets used）が1回以上あった人数
-- paid_M{k} = 同じく、有料チケットを使った人数。有料 = payment_credits → payments が completed かつ amount>0
--   （payment_credit_id は登録時3回・月初1枚の無料チケットにも入っているので、それだけでは判定できない）
-- user_tickets の used は 2026-02-23 以降しか無いので、コホートは 2026-03 以降。user59（2025-12登録）は自動的に外れる
-- 当月（2026-09）はまだ途中なので、各コホートの最新の列は低めに出る
SELECT
  c.cohort,
  c.n AS registered,
  SUM(r.k = 0) AS M0, SUM(r.k = 1) AS M1, SUM(r.k = 2) AS M2, SUM(r.k = 3) AS M3,
  SUM(r.k = 4) AS M4, SUM(r.k = 5) AS M5, SUM(r.k = 6) AS M6,
  SUM(r.k = 0 AND r.paid) AS paid_M0, SUM(r.k = 1 AND r.paid) AS paid_M1, SUM(r.k = 2 AND r.paid) AS paid_M2,
  SUM(r.k = 3 AND r.paid) AS paid_M3, SUM(r.k = 4 AND r.paid) AS paid_M4, SUM(r.k = 5 AND r.paid) AS paid_M5
FROM (
  SELECT DATE_FORMAT(created, '%Y-%m') AS cohort, COUNT(*) AS n
  FROM users WHERE id NOT IN (1, 2) AND created >= '2026-03-01' GROUP BY 1
) c
LEFT JOIN (
  SELECT DATE_FORMAT(u.created, '%Y-%m') AS cohort, t.user_id,
    PERIOD_DIFF(DATE_FORMAT(t.used_at, '%Y%m'), DATE_FORMAT(u.created, '%Y%m')) AS k,
    MAX(p.id IS NOT NULL) AS paid
  FROM user_tickets t
  JOIN users u ON u.id = t.user_id
  LEFT JOIN payment_credits pc ON pc.id = t.payment_credit_id
  LEFT JOIN payments p ON p.id = pc.payment_id AND p.status = 'completed' AND p.amount > 0
  WHERE t.status = 'used' AND t.user_id NOT IN (1, 2) AND u.created >= '2026-03-01'
  GROUP BY 1, 2, 3
) r ON r.cohort = c.cohort
GROUP BY c.cohort, c.n
ORDER BY c.cohort
