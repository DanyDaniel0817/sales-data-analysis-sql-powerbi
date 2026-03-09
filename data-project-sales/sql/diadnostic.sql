-- ================================
-- ANALISIS DIAGNOSTICO 
-- ================================

-- Desempeño categoría por región
SELECT
    region,
    category,
    ROUND(SUM(sales):: numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY region, category
ORDER BY region, total_sales DESC;

-- Ticket promedio por segmento
SELECT
    segment,
    ROUND(AVG(order_total):: numeric, 2) AS avg_order_value
FROM (
    SELECT
        segment,
        order_id,
        SUM(sales) AS order_total
    FROM sales.ventas_clean
    GROUP BY segment, order_id
) t
GROUP BY segment
ORDER BY avg_order_value DESC;

-- Días de envío y ventas
SELECT
    ship_mode,
    ROUND(AVG(ship_date - order_date), 2) AS avg_shipping_days,
    ROUND(SUM(sales):: numeric, 2)                  AS total_sales
FROM sales.ventas_clean
GROUP BY ship_mode
ORDER BY avg_shipping_days;

-- Top 10 clientes por ventas
SELECT
    customer_id,
    customer_name,
    ROUND(SUM(sales):: numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY customer_id, customer_name
ORDER BY total_sales DESC
LIMIT 10;

-- Participación porcentual por región
SELECT
    region,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(
        (100 * SUM(sales) / SUM(SUM(sales)) OVER ())::numeric,
        2
    ) AS percentage_share
FROM sales.ventas_clean
GROUP BY region
ORDER BY total_sales DESC;

-- Productos con menor venta
SELECT
    product_name,
    category,
    ROUND(SUM(sales):: numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY product_name, category
ORDER BY total_sales ASC
LIMIT 10;

-- Ventas promedio por mes del año
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    ROUND(AVG(sales):: numeric, 2) AS avg_sales
FROM sales.ventas_clean
GROUP BY month
ORDER BY month;






































