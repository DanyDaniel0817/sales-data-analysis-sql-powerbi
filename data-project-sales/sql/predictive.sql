-- ================================
-- ANALISIS PREDICTIVO 
-- ================================

-- Serie temporal mensual
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales
    FROM sales.ventas_clean
    GROUP BY 1
)

SELECT
    month,
    ROUND(total_sales:: numeric, 2) AS total_sales
FROM monthly_sales
ORDER BY month;

-- Crecimiento mensual
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales
    FROM sales.ventas_clean
    GROUP BY 1
)

SELECT
    month,
    ROUND(total_sales:: numeric, 2) AS total_sales,
    ROUND(
        (
            100 * (total_sales - LAG(total_sales) OVER (ORDER BY month))
            / LAG(total_sales) OVER (ORDER BY month)
        )::numeric,
        2
    ) AS growth_percentage
FROM monthly_sales
ORDER BY month;

-- Promedio móvil de 3 meses
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales
    FROM sales.ventas_clean
    GROUP BY 1
)

SELECT
    month,
    ROUND(total_sales:: numeric, 2) AS total_sales,
    ROUND(
    	(
        	AVG(total_sales) OVER (
           		ORDER BY month
            	ROWS BETWEEN 2 PRECEDING AND CURRENT row
        	)
        ):: numeric,
        2
    ) AS moving_avg_3m
FROM monthly_sales
ORDER BY month;

-- Proyección del siguiente mes
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales
    FROM sales.ventas_clean
    GROUP BY 1
),
last_three AS (
    SELECT total_sales
    FROM monthly_sales
    ORDER BY month DESC
    LIMIT 3
)

SELECT
    ROUND(AVG(total_sales):: numeric, 2) AS predicted_next_month_sales
FROM last_three;

-- Tendencia mensual por región
SELECT
    region,
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales):: numeric, 2) AS monthly_sales
FROM sales.ventas_clean
GROUP BY region, month
ORDER BY region, month;

-- Crecimiento por categoría
WITH category_monthly AS (
    SELECT
        category,
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales
    FROM sales.ventas_clean
    GROUP BY category, month
)

SELECT
    category,
    month,
    ROUND(total_sales:: numeric, 2),
  	ROUND(
        (
            100 * (total_sales - LAG(total_sales) OVER (PARTITION BY category ORDER BY month))
            / LAG(total_sales) OVER (PARTITION BY category ORDER BY month)
        )::numeric,
        2
    ) AS growth_percentage

FROM category_monthly
ORDER BY category, month;

















