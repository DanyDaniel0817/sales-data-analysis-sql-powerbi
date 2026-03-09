-- Creo ina vista para que dejar el dataset completamente original 
CREATE VIEW ventas_clean AS
SELECT
    "Row ID"        AS row_id,
    "Order ID"      AS order_id,
    "Order Date"    AS order_date,
    "Ship Date"     AS ship_date,
    "Ship Mode"     AS ship_mode,
    "Customer ID"   AS customer_id,
    "Customer Name" AS customer_name,
    "Segment"       AS segment,
    "Country"       AS country,
    "City"          AS city,
    "State"         AS state,
    "Postal Code"::TEXT AS postal_code,
    "Region"        AS region,
    "Product ID"    AS product_id,
    "Category"      AS category,
    "Sub-Category"  AS sub_category,
    "Product Name"  AS product_name,
    "Sales"         AS sales
FROM sales.ventas;

-- ================================
-- ANALISIS DESCRIPTIVO 
-- ================================

-- Desempeño por región
CREATE OR REPLACE VIEW sales.v_kpi_sales_by_region AS
SELECT
    region,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY region;

-- Top ciudades por ventas
CREATE OR REPLACE VIEW sales.v_kpi_sales_by_city AS
SELECT
    country,
    city,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY country, city;

-- Ventas por categoría
CREATE OR REPLACE VIEW sales.v_kpi_sales_by_category AS
SELECT
    category,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY category;

-- Top subcategorías
CREATE OR REPLACE VIEW sales.v_kpi_sales_by_subcategory AS
SELECT
    category,
    sub_category,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY category, sub_category;

-- View optimizada para mapas en Power BI
CREATE OR REPLACE VIEW sales.v_sales_by_city_geo AS
SELECT
    country,
    state,
    city,
    CONCAT(city, ', ', state, ', ', country) AS full_location,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders
FROM sales.ventas_clean
WHERE country = 'United States'  -- Solo USA para evitar confusión
GROUP BY country, state, city
ORDER BY total_sales DESC;

-- Ticket promedio
CREATE OR REPLACE VIEW sales.v_kpi_avg_order_value AS
SELECT
    ROUND(AVG(order_total)::numeric, 2) AS avg_order_value
FROM (
    SELECT
        order_id,
        SUM(sales) AS order_total
    FROM sales.ventas_clean
    GROUP BY order_id
) t;

-- Ventas por segmento de cliente
CREATE OR REPLACE VIEW sales.vw_ventas_por_segmento AS
SELECT
    segment,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(AVG(sales)::numeric, 2) AS avg_sale
FROM sales.ventas_clean
GROUP BY segment
ORDER BY total_sales DESC;

-- Impacto del método de envío
CREATE OR REPLACE VIEW sales.vw_ventas_por_ship_mode AS
SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY ship_mode
ORDER BY total_sales DESC;

-- View optimizada para mapas en Power BI
CREATE OR REPLACE VIEW sales.v_sales_by_city_geo AS
SELECT
    country,
    state,
    city,
    CONCAT(city, ', ', state, ', ', country) AS full_location,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders
FROM sales.ventas_clean
WHERE country = 'United States'  -- Solo USA para evitar confusión
GROUP BY country, state, city
ORDER BY total_sales DESC;

-- ================================
-- ANALISIS DIADNOSTICO 
-- ================================

-- Desempeño categoría por región
CREATE OR REPLACE VIEW sales.vw_desempeno_categoria_region AS
SELECT
    region,
    category,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY region, category
ORDER BY region, total_sales DESC;

-- Ticket promedio por segmento
CREATE OR REPLACE VIEW sales.vw_ticket_promedio_por_segmento AS
SELECT
    segment,
    ROUND(AVG(order_total)::numeric, 2) AS avg_order_value
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
CREATE OR REPLACE VIEW sales.vw_shipping_performance AS
SELECT
    ship_mode,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (ship_date - order_date)) / 86400)::numeric,
        2
    ) AS avg_shipping_days,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY ship_mode
ORDER BY avg_shipping_days;

-- Top clientes por ventas
CREATE OR REPLACE VIEW sales.vw_ventas_por_cliente AS
SELECT
    customer_id,
    customer_name,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY customer_id, customer_name
ORDER BY total_sales DESC;

-- Participación porcentual por región
CREATE OR REPLACE VIEW sales.vw_participacion_ventas_region AS
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
CREATE OR REPLACE VIEW sales.vw_productos_menor_venta AS
SELECT
    product_name,
    category,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM sales.ventas_clean
GROUP BY product_name, category
ORDER BY total_sales ASC;

-- Ventas promedio por mes del año
CREATE OR REPLACE VIEW sales.vw_promedio_ventas_mensual AS
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    ROUND(AVG(sales)::numeric, 2) AS avg_sales
FROM sales.ventas_clean
GROUP BY month
ORDER BY month;

-- ================================
-- ANALISIS PREDICTIVO
-- ================================

-- Serie temporal mensual
CREATE OR REPLACE VIEW sales.vw_ventas_mensuales AS
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales
    FROM sales.ventas_clean
    GROUP BY 1
)
SELECT
    month,
    ROUND(total_sales::numeric, 2) AS total_sales
FROM monthly_sales
ORDER BY month;

-- Crecimiento mensual
CREATE OR REPLACE VIEW sales.vw_crecimiento_mensual_ventas AS
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales
    FROM sales.ventas_clean
    GROUP BY 1
)
SELECT
    month,
    ROUND(total_sales::numeric, 2) AS total_sales,
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
CREATE OR REPLACE VIEW sales.vw_promedio_movil_ventas_3m AS
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales
    FROM sales.ventas_clean
    GROUP BY 1
)
SELECT
    month,
    ROUND(total_sales::numeric, 2) AS total_sales,
    ROUND(
        (
            AVG(total_sales) OVER (
                ORDER BY month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            )
        )::numeric,
        2
    ) AS moving_avg_3m
FROM monthly_sales
ORDER BY month;

-- Proyección del siguiente mes
CREATE OR REPLACE VIEW sales.vw_prediccion_ventas_proximo_mes AS
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
    ROUND(AVG(total_sales)::numeric, 2) AS predicted_next_month_sales
FROM last_three;

-- Tendencia mensual por región
CREATE OR REPLACE VIEW sales.vw_tendencia_mensual_region AS
SELECT
    region,
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales)::numeric, 2) AS monthly_sales
FROM sales.ventas_clean
GROUP BY region, month
ORDER BY region, month;

-- Crecimiento por categoría
CREATE OR REPLACE VIEW sales.vw_crecimiento_mensual_categoria AS
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
    ROUND(total_sales::numeric, 2) AS total_sales,
    ROUND(
        (
            100 * (total_sales - LAG(total_sales) OVER (PARTITION BY category ORDER BY month))
            / LAG(total_sales) OVER (PARTITION BY category ORDER BY month)
        )::numeric,
        2
    ) AS growth_percentage
FROM category_monthly
ORDER BY category, month;

-- ================================
-- ANALISIS PRESCRIPTIVO 
-- ================================

-- Recomendación de inversión por región
CREATE OR REPLACE VIEW sales.vw_crecimiento_region_decision AS
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
    GROUP BY region, DATE_TRUNC('month', order_date)
)
SELECT
    region,
    month,
    ROUND(total_sales::numeric, 2) AS total_sales,
    ROUND(
        CASE 
            WHEN prev_sales IS NULL OR prev_sales = 0 THEN NULL
            ELSE (100.0 * (total_sales - prev_sales) / prev_sales)
        END::numeric,
        2
    ) AS growth_pct,
    CASE
        WHEN prev_sales IS NULL THEN 'NUEVO'
        WHEN (100.0 * (total_sales - prev_sales) / prev_sales) > 10
        THEN 'INVERTIR MAS'
        WHEN (100.0 * (total_sales - prev_sales) / prev_sales) < -5
        THEN 'REVISAR / REDUCIR'
        ELSE 'MANTENER'
    END AS decision
FROM region_growth
WHERE prev_sales IS NOT NULL  -- Solo meses con comparación válida
ORDER BY month DESC, region;

-- Recomendación de inversión por región ultima version 
CREATE OR REPLACE VIEW sales.vw_decision_regional_final AS
WITH monthly AS (
    SELECT
        region,
        DATE_TRUNC('month', order_date)::date AS month,
        ROUND(SUM(sales)::numeric, 2) AS total_sales
    FROM sales.ventas_clean
    GROUP BY region, DATE_TRUNC('month', order_date)::date
),
with_growth AS (
    SELECT
        region,
        month,
        total_sales,
        LAG(total_sales) OVER (PARTITION BY region ORDER BY month) AS prev_sales
    FROM monthly
),
final AS (
    SELECT
        region,
        month,
        total_sales,
        ROUND(((total_sales - prev_sales) / prev_sales * 100)::numeric, 1) AS growth_pct,
        CASE
            WHEN ((total_sales - prev_sales) / prev_sales * 100) > 10  THEN 'INVERTIR MÁS'
            WHEN ((total_sales - prev_sales) / prev_sales * 100) < -5  THEN 'REVISAR / REDUCIR'
            ELSE 'MANTENER'
        END AS decision
    FROM with_growth
    WHERE prev_sales IS NOT NULL
)
-- Solo trae la fila más reciente por región
SELECT DISTINCT ON (region)
    region,
    month,
    total_sales,
    growth_pct,
    decision
FROM final
ORDER BY region, month DESC;

-- Vista simple para tabla de decisiones
CREATE OR REPLACE VIEW sales.vw_regional_performance AS
WITH monthly_region AS (
    SELECT
        region,
        DATE_TRUNC('month', order_date)::date AS month,
        ROUND(SUM(sales)::numeric, 2) AS monthly_sales
    FROM sales.ventas_clean
    GROUP BY region, DATE_TRUNC('month', order_date)::date
),
with_previous AS (
    SELECT
        region,
        month,
        monthly_sales,
        LAG(monthly_sales) OVER (PARTITION BY region ORDER BY month) AS prev_month_sales
    FROM monthly_region
),
with_growth AS (
    SELECT
        region,
        month,
        monthly_sales,
        prev_month_sales,
        CASE 
            WHEN prev_month_sales IS NULL OR prev_month_sales = 0 THEN NULL
            ELSE ROUND(((monthly_sales - prev_month_sales) / prev_month_sales * 100)::numeric, 1)
        END AS growth_pct
    FROM with_previous
)
SELECT
    region,
    month,
    monthly_sales AS total_sales,
    growth_pct,
    CASE
        WHEN growth_pct IS NULL THEN 'N/A'
        WHEN growth_pct > 10 THEN 'INVERTIR MAS'
        WHEN growth_pct < -5 THEN 'REVISAR / REDUCIR'
        ELSE 'MANTENER'
    END AS decision
FROM with_growth
WHERE prev_month_sales IS NOT NULL  -- Solo meses con datos previos
ORDER BY month DESC, region;

-- Recomendación de inventario por producto
CREATE OR REPLACE VIEW sales.vw_recomendacion_inventario_subcategoria AS
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
CREATE OR REPLACE VIEW sales.vw_estrategia_segmento_cliente AS
SELECT
    segment,
    SUM(sales) AS total_sales,
    CASE
        WHEN SUM(sales) > (
            SELECT AVG(total_sales)
            FROM (
                SELECT SUM(sales) AS total_sales
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
CREATE OR REPLACE VIEW sales.vw_recomendacion_tipo_envio AS
SELECT
    ship_mode,
    AVG(sales) AS avg_sales,
    CASE
        WHEN AVG(sales) = (
            SELECT MAX(avg_sales)
            FROM (
                SELECT ship_mode, AVG(sales) AS avg_sales
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
CREATE OR REPLACE VIEW sales.vw_alerta_desempeno_categoria AS
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































