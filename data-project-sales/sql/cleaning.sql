/*
=====================================================
DATA CLEANING SCRIPT
Dataset : Global Store Sales
Schema  : sales
Author  : Daniel Vallejo
Purpose : 
- Corregir tipos de datos
- Detectar y documentar nulos
- Detectar duplicados
- Preparar el dataset para análisis
=====================================================
*/

-- ================================
-- CORRECCIÓN DE TIPOS DE DATOS
-- ================================

ALTER TABLE sales.ventas
ALTER COLUMN "Order Date" TYPE date
USING "Order Date"::date;

ALTER TABLE sales.ventas
ALTER COLUMN "Ship Date" TYPE date
USING "Ship Date"::date;

ALTER TABLE sales.ventas
ALTER COLUMN "Sales" TYPE numeric(12,2)
USING "Sales"::numeric;

-- ================================
-- ANÁLISIS DE VALORES NULOS
-- ================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE row_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE sales IS NULL) AS null_sales,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS null_order_date,
    COUNT(*) FILTER (WHERE ship_date IS NULL) AS null_ship_date,
    COUNT(*) FILTER (WHERE country IS NULL) AS null_country

FROM sales.ventas_clean;

-- ================================
-- ELIMINACIÓN DE REGISTROS CRÍTICOS
-- ================================

DELETE FROM sales.ventas
WHERE
    "Order ID" IS NULL
    OR "Customer ID" IS NULL
    OR "Product ID" IS NULL
    OR "Sales" IS NULL;

-- ================================
-- DETECCIÓN DE DUPLICADOS
-- ================================

SELECT
    order_id,
    product_id,
    COUNT(*) AS duplicate_count
FROM sales.ventas_clean
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ================================
-- ELIMINACIÓN DE DUPLICADOS
-- ================================

DELETE FROM sales.ventas
WHERE "Row ID" IN (
    SELECT row_id
    FROM (
        SELECT
            "Row ID" AS row_id,
            ROW_NUMBER() OVER (
                PARTITION BY "Order ID", "Product ID"
                ORDER BY "Row ID"
            ) AS rn
        FROM sales.ventas
    ) t
    WHERE rn > 1
);

-- ================================
-- VALIDACIÓN FINAL
-- ================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(sales) AS total_sales
FROM sales.ventas_clean;



















