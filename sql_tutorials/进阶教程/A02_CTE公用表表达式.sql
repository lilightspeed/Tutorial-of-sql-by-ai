-- ============================================================
-- 第2章 CTE 公用表表达式
-- ============================================================
-- 学习目标:
-- - CTE 的基本语法和用途
-- - 多个 CTE 的组合使用
-- - 递归 CTE（Recursive CTE）
-- - 用递归 CTE 处理树形结构数据
-- - CTE vs 子查询 vs 临时表
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 什么是 CTE？
-- ============================================================
-- CTE（Common Table Expression）是一个临时的命名结果集
-- 在单条 SQL 语句中定义和使用
--
-- 语法:
-- WITH cte_name AS (
--     SELECT ...
-- )
-- SELECT * FROM cte_name;
--
-- CTE vs 子查询:
-- +----------+------------------+------------------+
-- | 特性     | CTE              | 子查询           |
-- +----------+------------------+------------------+
-- | 可读性   | 更好             | 嵌套较深时难读   |
-- | 复用     | 可多次引用       | 每次都需重写     |
-- | 递归     | 支持             | 不支持           |
-- | 性能     | 相同             | 相同             |
-- +----------+------------------+------------------+

-- ============================================================
-- 2. 基本 CTE
-- ============================================================

-- 简单 CTE：高价值订单
WITH high_value_orders AS (
    SELECT order_id, customer_id, total_amount
    FROM orders
    WHERE total_amount > 3000
)
SELECT
    hvo.order_id,
    c.customer_name,
    hvo.total_amount
FROM high_value_orders hvo
INNER JOIN customers c ON hvo.customer_id = c.customer_id
ORDER BY hvo.total_amount DESC;

-- 多个 CTE：先统计每个客户的订单数，再筛选
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
active_customers AS (
    SELECT customer_id, customer_name, city
    FROM customers
    WHERE city IN ('北京', '上海', '广州')
)
SELECT
    ac.customer_name,
    ac.city,
    co.order_count,
    co.total_spent
FROM active_customers ac
INNER JOIN customer_orders co ON ac.customer_id = co.customer_id
ORDER BY co.total_spent DESC;

-- ============================================================
-- 3. 递归 CTE
-- ============================================================
-- 递归 CTE 可以引用自身，常用于处理层级数据
--
-- 语法:
-- WITH RECURSIVE cte_name AS (
--     -- 锚点（Anchor）：起始查询
--     SELECT ... WHERE 初始条件
--     UNION ALL
--     -- 递归部分：引用自身
--     SELECT ... FROM cte_name WHERE 继续条件
-- )
-- SELECT * FROM cte_name;

-- 递归 CTE：生成 1 到 10 的数字序列
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT * FROM numbers;

-- 递归 CTE：生成日期序列
WITH RECURSIVE dates AS (
    SELECT DATE('2024-01-01') AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM dates WHERE dt < '2024-01-10'
)
SELECT * FROM dates;

-- ============================================================
-- 4. 递归 CTE 处理层级数据
-- ============================================================
-- employees 表有 manager_id 字段，可以表示组织架构树
--
-- 刘总 (1)
-- ├── 王经理 (2)
-- │   ├── 张明 (4)
-- │   ├── 陈静 (5)
-- │   └── 杨帆 (10)
-- ├── 李经理 (3)
-- │   ├── 赵伟 (6)
-- │   └── 黄丽 (7)
-- └── 林峰 (8)
--     └── 何敏 (9)

-- 递归 CTE：查询完整的组织架构
WITH RECURSIVE org_tree AS (
    -- 锚点：顶级管理者（没有上级的人）
    SELECT
        employee_id,
        employee_name,
        manager_id,
        department,
        0 AS level,
        CAST(employee_name AS CHAR(500)) AS path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- 递归：查找下级
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        e.department,
        t.level + 1,
        CONCAT(t.path, ' → ', e.employee_name)
    FROM employees e
    INNER JOIN org_tree t ON e.manager_id = t.employee_id
)
SELECT
    CONCAT(REPEAT('  ', level), employee_name) AS 组织架构,
    department,
    level AS 层级,
    path AS 完整路径
FROM org_tree
ORDER BY path;

-- 查询某员工的所有上级
WITH RECURSIVE managers AS (
    -- 锚点：从目标员工开始
    SELECT employee_id, employee_name, manager_id, 0 AS level
    FROM employees
    WHERE employee_name = '何敏'

    UNION ALL

    -- 递归：向上查找上级
    SELECT e.employee_id, e.employee_name, e.manager_id, m.level + 1
    FROM employees e
    INNER JOIN managers m ON e.employee_id = m.manager_id
)
SELECT employee_name AS 员工, level AS 上级层级
FROM managers
WHERE level > 0
ORDER BY level;

-- 查询某员工的所有下属
WITH RECURSIVE subordinates AS (
    -- 锚点：从目标管理者开始
    SELECT employee_id, employee_name, manager_id, department
    FROM employees
    WHERE employee_name = '王经理'

    UNION ALL

    -- 递归：查找下级
    SELECT e.employee_id, e.employee_name, e.manager_id, e.department
    FROM employees e
    INNER JOIN subordinates s ON e.manager_id = s.employee_id
)
SELECT employee_name AS 下属, department AS 部门
FROM subordinates
WHERE employee_name != '王经理'
ORDER BY employee_name;

-- ============================================================
-- 5. CTE 实战案例
-- ============================================================

-- CTE 实现分步统计
WITH
-- 第1步：每个分类的统计
category_stats AS (
    SELECT
        p.category_id,
        c.category_name,
        COUNT(*) AS product_count,
        ROUND(AVG(p.price), 2) AS avg_price,
        SUM(p.stock) AS total_stock
    FROM products p
    INNER JOIN categories c ON p.category_id = c.category_id
    GROUP BY p.category_id, c.category_name
),
-- 第2步：每个分类的订单销量
category_sales AS (
    SELECT
        p.category_id,
        SUM(oi.quantity) AS total_sold
    FROM order_items oi
    INNER JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category_id
)
-- 第3步：合并结果
SELECT
    cs.category_name,
    cs.product_count,
    cs.avg_price,
    cs.total_stock,
    IFNULL(css.total_sold, 0) AS 总销量
FROM category_stats cs
LEFT JOIN category_sales css ON cs.category_id = css.category_id
ORDER BY 总销量 DESC;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 使用 CTE 先筛选出价格超过 500 的商品
WITH expensive_products AS (
    SELECT product_id, product_name, category_id, price
    FROM products
    WHERE price > 500
)
SELECT ep.product_name, c.category_name, ep.price
FROM expensive_products ep
INNER JOIN categories c ON ep.category_id = c.category_id
ORDER BY ep.price DESC;

-- 题目2（简单）: 使用递归 CTE 生成 1 到 20 的偶数序列
WITH RECURSIVE even_numbers AS (
    SELECT 2 AS n
    UNION ALL
    SELECT n + 2 FROM even_numbers WHERE n < 20
)
SELECT * FROM even_numbers;

-- 题目3（中等）: 使用 CTE 计算每个客户的订单数和平均订单金额
WITH customer_stats AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count,
        ROUND(AVG(total_amount), 2) AS avg_amount
    FROM orders
    GROUP BY customer_id
)
SELECT
    c.customer_name,
    cs.order_count,
    cs.avg_amount
FROM customer_stats cs
INNER JOIN customers c ON cs.customer_id = c.customer_id
WHERE cs.avg_amount > 2000
ORDER BY cs.avg_amount DESC;

-- 题目4（中等）: 使用递归 CTE 查询 "赵伟" 的所有上级
WITH RECURSIVE managers AS (
    SELECT employee_id, employee_name, manager_id, 0 AS level
    FROM employees
    WHERE employee_name = '赵伟'

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, m.level + 1
    FROM employees e
    INNER JOIN managers m ON e.employee_id = m.manager_id
)
SELECT employee_name AS 上级, level AS 层级
FROM managers
WHERE level > 0
ORDER BY level;

-- 题目5（较难）: 使用多个 CTE 找出销量高于分类平均销量的商品
WITH
product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        IFNULL(SUM(oi.quantity), 0) AS sold_qty
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
),
category_avg AS (
    SELECT
        category_id,
        ROUND(AVG(sold_qty), 2) AS avg_sold
    FROM product_sales
    GROUP BY category_id
)
SELECT
    ps.product_name,
    c.category_name,
    ps.sold_qty AS 销量,
    ca.avg_sold AS 分类平均销量
FROM product_sales ps
INNER JOIN category_avg ca ON ps.category_id = ca.category_id
INNER JOIN categories c ON ps.category_id = c.category_id
WHERE ps.sold_qty > ca.avg_sold
ORDER BY ps.sold_qty DESC;
