-- ============================================================
-- 第4章 高级子查询
-- ============================================================
-- 学习目标:
-- - ALL / ANY / SOME 子查询
-- - 派生表（Derived Tables）
-- - SELECT 中的标量子查询
-- - 子查询与 JOIN 的性能对比
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. ALL 子查询
-- ============================================================
-- > ALL(子查询) 表示大于子查询返回的所有值（即大于最大值）
-- 语法: WHERE 列 > ALL(SELECT ...)
--       WHERE 列 < ALL(SELECT ...)

-- 查询价格高于"食品"分类所有商品的商品
SELECT product_name, price
FROM products
WHERE price > ALL (
    SELECT price FROM products WHERE category_id = 3
)
ORDER BY price;

-- 等价写法：使用 MAX
SELECT product_name, price
FROM products
WHERE price > (SELECT MAX(price) FROM products WHERE category_id = 3)
ORDER BY price;

-- ============================================================
-- 2. ANY / SOME 子查询
-- ============================================================
-- > ANY(子查询) 表示大于子查询返回的任意一个值（即大于最小值）
-- ANY 和 SOME 是同义词

-- 查询价格高于"食品"分类中任一商品的商品
SELECT product_name, price
FROM products
WHERE price > ANY (
    SELECT price FROM products WHERE category_id = 3
)
ORDER BY price;

-- 等价写法：使用 MIN
SELECT product_name, price
FROM products
WHERE price > (SELECT MIN(price) FROM products WHERE category_id = 3)
ORDER BY price;

-- ============================================================
-- 3. SELECT 中的标量子查询
-- ============================================================
-- 在 SELECT 列表中嵌入子查询，为每一行计算一个值

-- 每个商品与平均价格的对比
SELECT
    product_name,
    price,
    (SELECT ROUND(AVG(price), 2) FROM products) AS 平均价格,
    price - (SELECT AVG(price) FROM products) AS 与均价差异
FROM products
ORDER BY price DESC;

-- 每个客户的订单数和总消费（用标量子查询）
SELECT
    customer_name,
    city,
    (SELECT COUNT(*) FROM orders WHERE customer_id = c.customer_id) AS 订单数,
    (SELECT IFNULL(SUM(total_amount), 0) FROM orders WHERE customer_id = c.customer_id) AS 总消费
FROM customers c
ORDER BY 总消费 DESC;

-- ============================================================
-- 4. 派生表（Derived Tables）
-- ============================================================
-- 在 FROM 子句中的子查询，也叫内联视图（Inline View）

-- 派生表：先聚合再连接
SELECT
    c.customer_name,
    cs.order_count,
    cs.total_spent
FROM customers c
INNER JOIN (
    SELECT
        customer_id,
        COUNT(*) AS order_count,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
) cs ON c.customer_id = cs.customer_id
ORDER BY cs.total_spent DESC;

-- 多层派生表
SELECT *
FROM (
    SELECT
        category_id,
        COUNT(*) AS product_count,
        AVG(price) AS avg_price
    FROM products
    GROUP BY category_id
) cat_stats
WHERE product_count > 3
ORDER BY avg_price DESC;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 使用 ALL 查询工资高于"技术部"所有员工的员工
SELECT employee_name, department, salary
FROM employees
WHERE salary > ALL (
    SELECT salary FROM employees WHERE department = '技术部'
)
ORDER BY salary DESC;

-- 题目2（中等）: 使用标量子查询显示每个商品的分类平均价格
SELECT
    p.product_name,
    p.price,
    (SELECT ROUND(AVG(price), 2) FROM products WHERE category_id = p.category_id) AS 分类均价
FROM products p
ORDER BY p.category_id, p.price DESC;

-- 题目3（中等）: 使用派生表查询每个城市消费最高的客户
SELECT c.customer_name, c.city, cs.total_spent
FROM customers c
INNER JOIN (
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
) cs ON c.customer_id = cs.customer_id
WHERE cs.total_spent = (
    SELECT MAX(sub.total_spent)
    FROM (
        SELECT o2.customer_id, SUM(o2.total_amount) AS total_spent
        FROM orders o2
        INNER JOIN customers c2 ON o2.customer_id = c2.customer_id
        WHERE c2.city = c.city
        GROUP BY o2.customer_id
    ) sub
)
ORDER BY c.city;
