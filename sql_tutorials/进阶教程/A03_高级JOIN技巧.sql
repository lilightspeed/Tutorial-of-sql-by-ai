-- ============================================================
-- 第3章 高级 JOIN 技巧
-- ============================================================
-- 学习目标:
-- - CROSS JOIN 交叉连接
-- - NATURAL JOIN 自然连接
-- - USING 简化连接条件
-- - 自连接进阶应用
-- - 多表连接的执行顺序
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. CROSS JOIN — 交叉连接
-- ============================================================
-- 返回两张表的笛卡尔积（所有可能的行组合）
-- 语法: SELECT * FROM 表A CROSS JOIN 表B;
-- 结果行数 = 表A行数 × 表B行数

-- CROSS JOIN：生成所有分类 × 城市的组合
SELECT c.category_name, cu.city
FROM categories c
CROSS JOIN (SELECT DISTINCT city FROM customers) cu
ORDER BY c.category_name, cu.city;

-- 实战：生成日期维度表（当月所有日期）
WITH RECURSIVE dates AS (
    SELECT DATE('2024-01-01') AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM dates WHERE dt < '2024-01-31'
)
SELECT d.dt, IFNULL(SUM(o.total_amount), 0) AS daily_sales
FROM dates d
LEFT JOIN orders o ON DATE(o.order_date) = d.dt
GROUP BY d.dt
ORDER BY d.dt;

-- ============================================================
-- 2. USING — 简化连接条件
-- ============================================================
-- 当两个表的连接列名相同时，可以用 USING 代替 ON
--
-- ON 写法:
-- SELECT * FROM orders o INNER JOIN customers c ON o.customer_id = c.customer_id;
--
-- USING 写法（更简洁）:
-- SELECT * FROM orders INNER JOIN customers USING (customer_id);

-- USING 语法
SELECT order_id, customer_name, total_amount
FROM orders
INNER JOIN customers USING (customer_id)
LIMIT 5;

-- ============================================================
-- 3. 自连接进阶
-- ============================================================

-- 3.1 查找同城市的客户对
SELECT
    a.customer_name AS 客户A,
    b.customer_name AS 客户B,
    a.city AS 城市
FROM customers a
INNER JOIN customers b ON a.city = b.city AND a.customer_id < b.customer_id
ORDER BY a.city;

-- 3.2 查找同期订单（同一天下单的订单对）
SELECT
    a.order_id AS 订单A,
    b.order_id AS 订单B,
    DATE(a.order_date) AS 下单日期
FROM orders a
INNER JOIN orders b ON DATE(a.order_date) = DATE(b.order_date) AND a.order_id < b.order_id
ORDER BY 下单日期;

-- ============================================================
-- 4. JOIN 的执行顺序
-- ============================================================
-- SELECT ...
-- FROM A
-- INNER JOIN B ON ...
-- LEFT JOIN C ON ...
-- WHERE ...
-- GROUP BY ...
-- HAVING ...
-- ORDER BY ...
-- LIMIT ...
--
-- 逻辑执行顺序:
-- 1. FROM + JOIN → 确定数据源
-- 2. WHERE → 过滤行
-- 3. GROUP BY → 分组
-- 4. HAVING → 过滤分组
-- 5. SELECT → 选择列
-- 6. DISTINCT → 去重
-- 7. ORDER BY → 排序
-- 8. LIMIT → 限制行数

-- ============================================================
-- 5. JOIN 性能提示
-- ============================================================
-- +------------------+---------------------------+
-- | 技巧             | 说明                      |
-- +------------------+---------------------------+
-- | 小表驱动大表     | 让小的结果集驱动大的      |
-- | 连接列加索引     | ON 条件的列应该有索引     |
-- | 避免笛卡尔积     | 检查 ON 条件是否完整      |
-- | 用 WHERE 提前过滤 | 在 JOIN 前减少数据量     |
-- +------------------+---------------------------+

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 使用 USING 语法查询所有订单的客户名称和订单金额
SELECT customer_name, order_id, total_amount
FROM orders
INNER JOIN customers USING (customer_id)
ORDER BY total_amount DESC;

-- 题目2（中等）: 使用 CROSS JOIN 生成一个 3×4 的数字矩阵
WITH
nums1 AS (SELECT 1 AS a UNION SELECT 2 UNION SELECT 3),
nums2 AS (SELECT 1 AS b UNION SELECT 2 UNION SELECT 3 UNION SELECT 4)
SELECT n1.a, n2.b
FROM nums1 n1 CROSS JOIN nums2 n2
ORDER BY n1.a, n2.b;

-- 题目3（中等）: 使用自连接查找同一部门中工资不同的员工对
SELECT
    a.employee_name AS 员工A,
    b.employee_name AS 员工B,
    a.department AS 部门,
    a.salary AS 工资A,
    b.salary AS 工资B
FROM employees a
INNER JOIN employees b
    ON a.department = b.department
    AND a.employee_id < b.employee_id
    AND a.salary != b.salary
ORDER BY a.department, a.salary DESC;
