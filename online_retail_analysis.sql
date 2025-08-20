-- Schema
CREATE TABLE sales (
    OrderID VARCHAR(20) PRIMARY KEY,
    OrderDate DATE,
    CustomerID VARCHAR(20),
    Region VARCHAR(20),
    Country VARCHAR(50),
    SalesChannel VARCHAR(30),
    Category VARCHAR(50),
    ProductName VARCHAR(100),
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    DiscountRate DECIMAL(5,3),
    GrossAmount DECIMAL(12,2),
    Revenue DECIMAL(12,2),
    Cost DECIMAL(12,2),
    Profit DECIMAL(12,2),
    IsReturned BOOLEAN
);

-- Example queries

-- 1) Monthly revenue trend
SELECT DATE_TRUNC('month', OrderDate) AS month, SUM(Revenue) AS total_revenue
FROM sales
GROUP BY 1
ORDER BY 1;

-- 2) Top 10 products by revenue
SELECT ProductName, SUM(Revenue) AS revenue
FROM sales
GROUP BY ProductName
ORDER BY revenue DESC
LIMIT 10;

-- 3) Total profit by category
SELECT Category, SUM(Profit) AS total_profit
FROM sales
GROUP BY Category
ORDER BY total_profit DESC;

-- 4) Top customers by CLV
SELECT CustomerID, SUM(Revenue) AS clv
FROM sales
GROUP BY CustomerID
ORDER BY clv DESC
LIMIT 20;

-- 5) Repeat rate
WITH oc AS (
    SELECT CustomerID, COUNT(DISTINCT OrderID) AS orders
    FROM sales
    GROUP BY CustomerID
)
SELECT
    SUM(CASE WHEN orders = 1 THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) AS one_time_share,
    SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) AS repeat_share
FROM oc;

-- 6) Return rate by category
SELECT Category, AVG(CASE WHEN IsReturned THEN 1 ELSE 0 END) AS return_rate
FROM sales
GROUP BY Category
ORDER BY return_rate DESC;

-- 7) 80/20 analysis - revenue share for top 20% customers
WITH clv AS (
    SELECT CustomerID, SUM(Revenue) AS revenue
    FROM sales
    GROUP BY CustomerID
),
ranked AS (
    SELECT *, NTILE(5) OVER (ORDER BY revenue DESC) AS quint
    FROM clv
)
SELECT
    SUM(CASE WHEN quint = 1 THEN revenue ELSE 0 END) / SUM(revenue) AS top20_share
FROM ranked;
