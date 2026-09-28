SELECT CASE
  WHEN u.created < '2026-06-01' THEN '0_~5/31'
  WHEN u.created < '2026-08-10' THEN '1_6/1-8/9 Google'
  WHEN u.created < '2026-08-17' THEN '2_8/10-16 Google減'
  WHEN u.created < '2026-08-31' THEN '3_8/17-30 Instagramのみ'
  WHEN u.created < '2026-09-07' THEN '4_8/31-9/6 Google+Instagram'
  ELSE '5_9/7- Instagram' END period,
  COUNT(*) reg,
  SUM(COALESCE(t.used_n,0)>=1) reached,
  SUM(COALESCE(t.used_n,0)=1 AND s.count=2 AND p.uid IS NULL) b,
  SUM(COALESCE(t.used_n,0)>=3 AND p.uid IS NULL) a,
  SUM(p.uid IS NOT NULL) paid
FROM users u JOIN user_statuses s ON s.user_id=u.id
LEFT JOIN (SELECT user_id, SUM(status='used') used_n FROM user_tickets GROUP BY user_id) t ON t.user_id=u.id
LEFT JOIN (SELECT DISTINCT user_id uid FROM payments WHERE status='completed' AND amount>0) p ON p.uid=u.id
WHERE u.id NOT IN (1,2) AND u.created >= '2026-04-01'
GROUP BY period ORDER BY period
