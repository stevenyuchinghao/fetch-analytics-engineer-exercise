-- What are the top 5 brands by receipts scanned for most recent month?
WITH recent_month AS (
  SELECT 
    EXTRACT(YEAR FROM MAX(date_scanned)) AS year,
    EXTRACT(MONTH FROM MAX(date_scanned)) AS month
  FROM `modern-cipher-437418-v8.fetch_rewards.receipts`
)

SELECT brand_code, COUNT(*) AS receipts_scanned
FROM `modern-cipher-437418-v8.fetch_rewards.receipts`, recent_month
LEFT JOIN `modern-cipher-437418-v8.fetch_rewards.receipt_items` USING (receipt_id)
WHERE EXTRACT(YEAR FROM date_scanned) = recent_month.year
  AND EXTRACT(MONTH FROM date_scanned) = recent_month.month
GROUP BY brand_code
ORDER BY receipts_scanned DESC
LIMIT 5;



-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
WITH months AS (
  SELECT 
    MAX(date_scanned) AS latest_date
  FROM `modern-cipher-437418-v8.fetch_rewards.receipts`
),
month_info AS (
  SELECT 
    EXTRACT(YEAR FROM latest_date) AS latest_year,
    EXTRACT(MONTH FROM latest_date) AS latest_month,
    EXTRACT(YEAR FROM DATE_SUB(latest_date, INTERVAL 1 MONTH)) AS prev_year,
    EXTRACT(MONTH FROM DATE_SUB(latest_date, INTERVAL 1 MONTH)) AS prev_month
  FROM months
),
recent_rank AS (
  SELECT 
    ri.brand_code,
    COUNT(*) AS receipts_scanned,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_recent
  FROM `modern-cipher-437418-v8.fetch_rewards.receipts` r
  JOIN `modern-cipher-437418-v8.fetch_rewards.receipt_items` ri USING (receipt_id)
  JOIN month_info
  WHERE EXTRACT(YEAR FROM r.date_scanned) = month_info.latest_year
    AND EXTRACT(MONTH FROM r.date_scanned) = month_info.latest_month
  GROUP BY ri.brand_code
),
prev_rank AS (
  SELECT 
    ri.brand_code,
    COUNT(*) AS receipts_scanned,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_previous
  FROM `modern-cipher-437418-v8.fetch_rewards.receipts` r
  JOIN `modern-cipher-437418-v8.fetch_rewards.receipt_items` ri USING (receipt_id)
  JOIN month_info
  WHERE EXTRACT(YEAR FROM r.date_scanned) = month_info.prev_year
    AND EXTRACT(MONTH FROM r.date_scanned) = month_info.prev_month
  GROUP BY ri.brand_code
)

SELECT 
  r.brand_code,
  r.rank_recent,
  p.rank_previous
FROM recent_rank r
LEFT JOIN prev_rank p USING (brand_code)
WHERE r.rank_recent <= 5
ORDER BY r.rank_recent;



--- When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT 
  status,
  AVG(total_spent) AS avg_spend
FROM `modern-cipher-437418-v8.fetch_rewards.receipts`
WHERE status IN ('FINISHED', 'REJECTED') -- out of 'SUBMITTED', 'REJECTED', 'FLAGGED', 'FINISHED', 'PENDING'
GROUP BY status
ORDER BY avg_spend DESC;



--- When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT 
  status,
  SUM(item_count) AS total_number_item_purchase
FROM `modern-cipher-437418-v8.fetch_rewards.receipts`
WHERE status IN ('FINISHED', 'REJECTED') -- out of 'SUBMITTED', 'REJECTED', 'FLAGGED', 'FINISHED', 'PENDING'
GROUP BY status
ORDER BY total_number_item_purchase DESC;



-- Which brand has the most spend among users who were created within the past 6 months?
SELECT 
  brand_code,
  SUM(total_spent) AS total_spend 
FROM `modern-cipher-437418-v8.fetch_rewards.receipts` r
LEFT JOIN `modern-cipher-437418-v8.fetch_rewards.receipt_items` ri USING (receipt_id)
LEFT JOIN `modern-cipher-437418-v8.fetch_rewards.users` u ON r.user_id = u.user_id
WHERE 
  u.created_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
GROUP BY brand_code
ORDER BY total_spend DESC
LIMIT 1;



-- Which brand has the most transactions among users who were created within the past 6 months?
SELECT 
  ri.brand_code, 
  COUNT(*) AS num_transactions
FROM `modern-cipher-437418-v8.fetch_rewards.receipts` r
JOIN `modern-cipher-437418-v8.fetch_rewards.users` u 
  ON r.user_id = u.user_id
JOIN `modern-cipher-437418-v8.fetch_rewards.receipt_items` ri 
  ON r.receipt_id = ri.receipt_id
WHERE 
  u.created_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
  AND ri.brand_code IS NOT NULL
GROUP BY ri.brand_code
ORDER BY num_transactions DESC
LIMIT 1;