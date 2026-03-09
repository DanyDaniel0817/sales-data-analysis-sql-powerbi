-- ================================
-- ANALISIS PRESCRIPTIVO 
-- ================================

-- Recomendación de inversión por región

WITH region_growth AS (
    SELECT
        region,
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales,
        LAG(SUM(sales)) OVER (
            PARTITION BY region
            ORDER BY DATE_TRUNC('month', order_date)
        ) AS prev_sales
    FROM sales.ventas_clean
    GROUP BY region, month
)

SELECT
    region,
    month,
    ROUND(total_sales:: numeric,2),
    ROUND(
        (100 * (total_sales - prev_sales) / prev_sales)::numeric,
        2
    ) AS growth_pct,

    CASE
        WHEN (total_sales - prev_sales)/prev_sales > 0.10
        THEN 'INVERTIR MAS'
        WHEN (total_sales - prev_sales)/prev_sales < -0.05
        THEN 'REVISAR / REDUCIR'
        ELSE 'MANTENER'
    END AS decision
FROM region_growth
WHERE prev_sales IS NOT NULL;

-- Recomendación de inventario por producto

WITH product_trend AS (
    SELECT
        sub_category,
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales,
        LAG(SUM(sales)) OVER (
            PARTITION BY sub_category
            ORDER BY DATE_TRUNC('month', order_date)
        ) AS prev_sales
    FROM sales.ventas_clean
    GROUP BY sub_category, month
)

SELECT
    sub_category,
    month,
    total_sales,

    CASE
        WHEN total_sales > prev_sales THEN 'AUMENTAR INVENTARIO'
        WHEN total_sales < prev_sales THEN 'REDUCIR INVENTARIO'
        ELSE 'MANTENER'
    END AS stock_recommendation
FROM product_trend
WHERE prev_sales IS NOT NULL;

-- Priorización automática de clientes

SELECT
    segment,
    SUM(sales) AS total_sales,

    CASE
        WHEN SUM(sales) > (
            SELECT AVG(total_sales)
            FROM (
                SELECT SUM(sales) total_sales
                FROM sales.ventas_clean
                GROUP BY segment
            ) x
        )
        THEN 'CLIENTE PRIORITARIO'
        ELSE 'BAJA PRIORIDAD'
    END AS strategy
FROM sales.ventas_clean
GROUP BY segment;

-- Recomendación logística

SELECT
    ship_mode,
    AVG(sales) avg_sales,

    CASE
        WHEN AVG(sales) = (
            SELECT MAX(avg_sales)
            FROM (
                SELECT ship_mode, AVG(sales) avg_sales
                FROM sales.ventas_clean
                GROUP BY ship_mode
            ) t
        )
        THEN 'RECOMENDAR ESTE ENVIO'
        ELSE 'NO PRIORITARIO'
    END AS decision
FROM sales.ventas_clean
GROUP BY ship_mode;


-- Alerta de desempeño por categoria 
SELECT
    category,
    SUM(sales) AS total_sales,
    CASE
        WHEN SUM(sales) < (
            SELECT AVG(total_sales)
            FROM (
                SELECT SUM(sales) AS total_sales
                FROM sales.ventas_clean
                GROUP BY category
            ) sub
        )
        THEN 'ALERTA: BAJO DESEMPEÑO'
        ELSE 'ESTA BIEN'
    END AS status
FROM sales.ventas_clean
GROUP BY category;



















