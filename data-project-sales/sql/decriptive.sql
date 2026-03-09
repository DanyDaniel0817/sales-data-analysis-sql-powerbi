-- ================================
-- ANALISIS DESCRIPTIVO 
-- ================================

-- Volumen general del negocio
SELECT
    COUNT(*)                    AS total_rows,
    COUNT(DISTINCT order_id)     AS total_orders,
    COUNT(DISTINCT customer_id)  AS total_customers,
    COUNT(DISTINCT product_id)   AS total_products,
    ROUND(SUM(sales)::numeric, 2)         AS total_sales
FROM sales.ventas_clean;

-- Evolución mensual de ventas
SELECT
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales):: numeric, 2)             AS monthly_sales
FROM sales.ventas_clean
GROUP BY 1
ORDER BY 1;

-- Desempeño por región
SELECT
    region,
    ROUND(SUM(sales):: numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY region
ORDER BY total_sales DESC;

-- Top 10 ciudades por ventas
SELECT
    country,
    city,
    ROUND(SUM(sales):: numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY country, city
ORDER BY total_sales DESC
LIMIT 10;

-- Ventas por categoría
SELECT
    category,
    ROUND(SUM(sales):: numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY category
ORDER BY total_sales DESC;

-- Ventas por categoría
SELECT
    category,
    ROUND(SUM(sales):: numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY category
ORDER BY total_sales DESC;

-- Top subcategorías
SELECT
    category,
    sub_category,
    ROUND(SUM(sales):: numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY category, sub_category
ORDER BY total_sales DESC;

-- Ticket promedio
SELECT
    ROUND(AVG(order_total):: numeric, 2) AS avg_order_value
FROM (
    SELECT
        order_id,
        SUM(sales) AS order_total
    FROM sales.ventas_clean
    GROUP BY order_id
) t;

-- Ventas por segmento de cliente
SELECT
    segment,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(sales):: numeric, 2)        AS total_sales,
    ROUND(AVG(sales):: numeric, 2)        AS avg_sale
FROM sales.ventas_clean
GROUP BY segment
ORDER BY total_sales DESC;

-- Impacto del método de envío
SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales):: numeric, 2)     AS total_sales
FROM sales.ventas_clean
GROUP BY ship_mode
ORDER BY total_sales DESC;

-- Consulta Total de ordenes
SELECT COUNT(*) AS total_ordenes
FROM sales.ventas_clean;




