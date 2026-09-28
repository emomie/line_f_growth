-- 課金メニュー表示（pending は表示1回につき3件）をユーザー別に
SELECT user_id, COUNT(*) pend, ROUND(COUNT(*)/3) menus, COUNT(DISTINCT DATE(created)) days, MIN(created) first_menu, MAX(created) last_menu
FROM payments WHERE payment_type='pay_as_you_go' AND status='pending' AND user_id NOT IN (1,2) GROUP BY user_id;

-- KOMOJUで決済手段まで進んだ記録（成功以外）。手段は raw_data の data.payment_details.type
SELECT id, event_type, user_id, payment_id, created, raw_data FROM stripe_webhook_events
WHERE event_type IN ('payment.captured','payment.failed','payment.expired','payment.authorized','payment.cancelled') ORDER BY created;
