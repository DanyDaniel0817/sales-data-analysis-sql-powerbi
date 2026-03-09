-- Score de priorización de mercados

WITH region_metrics AS (
    SELECT
        region,
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS sales
    FROM sales.ventas_clean
    GROUP BY region, DATE_TRUNC('month', order_date)
),
region_growth AS (
    SELECT
        region,
        month,
        sales,
        (sales - LAG(sales) OVER (PARTITION BY region ORDER BY month))
        / NULLIF(LAG(sales) OVER (PARTITION BY region ORDER BY month), 0) AS growth
    FROM region_metrics
)
SELECT
    region,
    ROUND(AVG(sales)::numeric, 2) AS avg_sales,
    ROUND(STDDEV(sales)::numeric, 2) AS volatility,
    ROUND(AVG(growth)::numeric * 100, 2) AS avg_growth_pct,
    (AVG(sales) * 0.5 + AVG(growth) * 0.4 - STDDEV(sales) * 0.1) AS market_score,
    CASE
        WHEN (AVG(sales) * 0.5 + AVG(growth) * 0.4 - STDDEV(sales) * 0.1) > 500
        THEN 'PRIORIDAD ALTA'
        ELSE 'PRIORIDAD MEDIA/BAJA'
    END AS recommendation
FROM region_growth
GROUP BY region
ORDER BY market_score DESC;

















