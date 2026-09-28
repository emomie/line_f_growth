-- 止める条件の監視: 「1日10回超のユーザーが新規の1%超」（週次、月曜始まり、直近12週）
-- 占い回数 = user_tickets の used 件数。1日 = 暦日（DBはJST）
-- 新規 = その日の時点で登録から30日以内のユーザー。分母 = 週末時点で直近30日以内に登録したユーザー数
-- テストアカウント(1,2)除外。user59は新規ではないので分子には入らないが、参考に全体の人数も出す
-- DB API が SELECT 始まりしか通さないため WITH 句は使わない
SELECT
  w.wk AS week_start,
  (SELECT COUNT(*) FROM users u WHERE u.id NOT IN (1, 2)
     AND u.created >= w.wk AND u.created < w.wk + INTERVAL 7 DAY) AS new_this_week,
  (SELECT COUNT(*) FROM users u WHERE u.id NOT IN (1, 2)
     AND u.created >= w.wk + INTERVAL 7 DAY - INTERVAL 30 DAY
     AND u.created < w.wk + INTERVAL 7 DAY) AS new_30d,
  COUNT(DISTINCT CASE WHEN h.is_new THEN h.user_id END) AS heavy_new,
  COUNT(DISTINCT h.user_id) AS heavy_all,
  (SELECT MAX(x.n) FROM (
     SELECT COUNT(*) n, DATE(used_at) d FROM user_tickets
     WHERE status = 'used' AND user_id NOT IN (1, 2) GROUP BY user_id, DATE(used_at)
   ) x WHERE x.d >= w.wk AND x.d < w.wk + INTERVAL 7 DAY) AS max_per_day
FROM (
  SELECT CURDATE() - INTERVAL WEEKDAY(CURDATE()) DAY - INTERVAL (7 * i) DAY AS wk
  FROM (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11) n
) w
LEFT JOIN (
  SELECT t.user_id, DATE(t.used_at) AS d, DATEDIFF(DATE(t.used_at), DATE(u.created)) <= 30 AS is_new
  FROM user_tickets t JOIN users u ON u.id = t.user_id
  WHERE t.status = 'used' AND t.user_id NOT IN (1, 2)
  GROUP BY t.user_id, DATE(t.used_at), u.created
  HAVING COUNT(*) > 10
) h ON h.d >= w.wk AND h.d < w.wk + INTERVAL 7 DAY
GROUP BY w.wk
ORDER BY w.wk DESC
