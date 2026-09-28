SELECT u.id, DATE(u.created) reg, t.used_n, s.count remaining,
  CASE WHEN p.uid IS NOT NULL THEN 'paid' WHEN t.used_n=1 AND s.count=2 THEN 'B' WHEN t.used_n>=3 THEN 'A' ELSE 'other' END grp,
  DATE(t.first_used) first_used, DATE(t.last_used) last_used
FROM (SELECT DISTINCT user_id FROM user_tickets WHERE status='used' AND used_at>='2026-06-28') a
JOIN users u ON u.id=a.user_id
JOIN user_statuses s ON s.user_id=a.user_id
JOIN (SELECT user_id, SUM(status='used') used_n, MIN(used_at) first_used, MAX(used_at) last_used FROM user_tickets WHERE status='used' GROUP BY user_id) t ON t.user_id=a.user_id
LEFT JOIN (SELECT DISTINCT user_id uid FROM payments WHERE status='completed' AND amount>0) p ON p.uid=a.user_id
WHERE a.user_id NOT IN (1,2)
