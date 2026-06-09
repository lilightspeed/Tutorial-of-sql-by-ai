-- ============================================================
-- 第10章 综合实战
-- ============================================================
-- 学习目标:
-- 本章通过真实业务场景，综合运用窗口函数、CTE、子查询等进阶技巧：
-- - 排行榜查询
-- - 用户留存分析
-- - 销售漏斗分析
-- - 环比/同比计算
-- - 连续登录天数
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 场景1：Top-N 排行榜
-- ============================================================
-- 每个分类中价格最高的前 2 个商品

WITH ranked_products AS (
    SELECT
        c.category_name,
        p.product_name,
        p.price,
        ROW_NUMBER() OVER (PARTITION BY p.category_id ORDER BY p.price DESC) AS rn
    FROM products p
    INNER JOIN categories c ON p.category_id = c.category_id
)
SELECT category_name, product_name, price
FROM ranked_products
WHERE rn <= 2
ORDER BY category_name, price DESC;

-- ============================================================
-- 场景2：消费排行榜
-- ============================================================
-- 客户消费排名 + 累计占比

WITH customer_spending AS (
    SELECT
        c.customer_name,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
),
total AS (
    SELECT SUM(total_spent) AS grand_total FROM customer_spending
)
SELECT
    ROW_NUMBER() OVER (ORDER BY cs.total_spent DESC) AS 排名,
    cs.customer_name,
    cs.total_spent AS 消费金额,
    ROUND(cs.total_spent / t.grand_total * 100, 2) AS 占比百分比,
    ROUND(SUM(cs.total_spent) OVER (ORDER BY cs.total_spent DESC) / t.grand_total * 100, 2) AS 累计占比
FROM customer_spending cs
CROSS JOIN total t
ORDER BY cs.total_spent DESC;

-- ============================================================
-- 场景3：月度销售环比
-- ============================================================
-- 计算每月销售额和环比增长率

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        COUNT(*) AS order_count,
        SUM(total_amount) AS monthly_amount
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month AS 月份,
    order_count AS 订单数,
    monthly_amount AS 销售额,
    LAG(monthly_amount, 1) OVER (ORDER BY month) AS 上月销售额,
    CASE
        WHEN LAG(monthly_amount, 1) OVER (ORDER BY month) IS NULL THEN '-'
        ELSE CONCAT(
            ROUND((monthly_amount - LAG(monthly_amount, 1) OVER (ORDER BY month))
                  / LAG(monthly_amount, 1) OVER (ORDER BY month) * 100, 2),
            '%'
        )
    END AS 环比增长率
FROM monthly_sales
ORDER BY month;

-- ============================================================
-- 场景4：RFM 客户分层
-- ============================================================
-- 基于 R（Recency）、F（Frequency）、M（Monetary）进行客户分层

WITH rfm AS (
    SELECT
        c.customer_name,
        DATEDIFF(CURDATE(), MAX(o.order_date)) AS recency,
        COUNT(o.order_id) AS frequency,
        ROUND(SUM(o.total_amount), 2) AS monetary
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
),
rfm_scored AS (
    SELECT
        customer_name,
        recency, frequency, monetary,
        NTILE(3) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(3) OVER (ORDER BY frequency) AS f_score,
        NTILE(3) OVER (ORDER BY monetary) AS m_score
    FROM rfm
)
SELECT
    customer_name,
    recency AS 最近购买天数,
    frequency AS 订单频率,
    monetary AS 消费总额,
    CONCAT(r_score, f_score, m_score) AS rfm_score,
    CASE
        WHEN r_score >= 2 AND f_score >= 2 AND m_score >= 2 THEN '高价值客户'
        WHEN r_score >= 2 AND f_score >= 2 THEN '忠实客户'
        WHEN r_score >= 2 AND m_score >= 2 THEN '高消费客户'
        WHEN r_score = 3 THEN '新客户'
        ELSE '待激活客户'
    END AS 客户分层
FROM rfm_scored
ORDER BY monetary DESC;

-- ============================================================
-- 场景5：员工层级分析
-- ============================================================
-- 递归查询组织架构 + 统计每个管理者下属人数

WITH RECURSIVE org_tree AS (
    SELECT employee_id, employee_name, manager_id, 0 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, t.level + 1
    FROM employees e
    INNER JOIN org_tree t ON e.manager_id = t.employee_id
)
SELECT
    CONCAT(REPEAT('  ', level), employee_name) AS 组织架构,
    level AS 层级,
    (SELECT COUNT(*) FROM employees WHERE manager_id = ot.employee_id) AS 直接下属数
FROM org_tree ot
ORDER BY ot.employee_id;

-- ============================================================
-- 场景6：商品关联分析
-- ============================================================
-- 找出经常一起被购买的商品组合

SELECT
    p1.product_name AS 商品A,
    p2.product_name AS 商品B,
    COUNT(*) AS 一起购买次数
FROM order_items oi1
INNER JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
INNER JOIN products p1 ON oi1.product_id = p1.product_id
INNER JOIN products p2 ON oi2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(*) >= 1
ORDER BY 一起购买次数 DESC;

-- ============================================================
-- 场景7：综合报表
-- ============================================================
-- 生成一份完整的销售分析报表

WITH
category_sales AS (
    SELECT
        cat.category_name,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.quantity) AS total_qty,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
    FROM order_items oi
    INNER JOIN products p ON oi.product_id = p.product_id
    INNER JOIN categories cat ON p.category_id = cat.category_id
    INNER JOIN orders o ON oi.order_id = o.order_id
    GROUP BY cat.category_id, cat.category_name
)
SELECT
    category_name AS 分类,
    order_count AS 订单数,
    total_qty AS 总销量,
    total_revenue AS 总收入,
    ROUND(total_revenue / SUM(total_revenue) OVER () * 100, 2) AS 收入占比,
    ROUND(total_revenue / order_count, 2) AS 客单价,
    RANK() OVER (ORDER BY total_revenue DESC) AS 收入排名
FROM category_sales
ORDER BY total_revenue DESC;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（中等）: 查询每个部门工资排名前 2 的员工
WITH ranked AS (
    SELECT
        employee_name, department, salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT employee_name, department, salary
FROM ranked
WHERE rn <= 2
ORDER BY department, salary DESC;

-- 题目2（中等）: 计算每个月的订单数量，并显示环比变化
WITH monthly AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month AS 月份,
    order_count AS 订单数,
    LAG(order_count, 1) OVER (ORDER BY month) AS 上月订单数,
    order_count - LAG(order_count, 1) OVER (ORDER BY month) AS 变化量
FROM monthly
ORDER BY month;

-- 题目3（较难）: 使用递归 CTE，查询 "何敏" 到 "刘总" 之间的管理层级路径
WITH RECURSIVE path AS (
    SELECT employee_id, employee_name, manager_id, 0 AS level,
           CAST(employee_name AS CHAR(500)) AS path
    FROM employees
    WHERE employee_name = '何敏'

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, p.level + 1,
           CONCAT(e.employee_name, ' → ', p.path)
    FROM employees e
    INNER JOIN path p ON e.employee_id = p.manager_id
)
SELECT path AS 管理路径, level AS 层级数
FROM path
WHERE manager_id IS NULL;

-- 题目4（较难）: 为每个客户计算 RFM 分数，并标注客户等级
WITH rfm AS (
    SELECT
        c.customer_name,
        DATEDIFF(CURDATE(), MAX(o.order_date)) AS R,
        COUNT(o.order_id) AS F,
        ROUND(SUM(o.total_amount), 2) AS M
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    R, F, M,
    CASE
        WHEN R <= 30 AND F >= 3 AND M >= 3000 THEN '高价值'
        WHEN R <= 60 AND F >= 2 THEN '活跃'
        WHEN R <= 120 THEN '沉睡'
        ELSE '流失'
    END AS 客户等级
FROM rfm
ORDER BY M DESC;

-- ============================================================
-- 恭喜完成 SQL 进阶教程！
-- ============================================================
-- 你已经掌握了:
-- +----------+---------------------------+
-- | 章节     | 进阶技能                  |
-- +----------+---------------------------+
-- | A01      | 窗口函数（排名、偏移、聚合）|
-- | A02      | CTE 和递归查询            |
-- | A03      | 高级 JOIN 技巧            |
-- | A04      | 高级子查询（ALL/ANY、派生表）|
-- | A05      | 性能优化与 EXPLAIN        |
-- | A06      | 高级数据操作（Upsert、批量）|
-- | A07      | JSON 数据操作             |
-- | A08      | 存储过程高级特性          |
-- | A09      | 数据库设计与范式          |
-- | A10      | 真实业务场景实战          |
-- +----------+---------------------------+
--
-- 继续学习建议:
-- 1. 刷题平台 — LeetCode SQL、HackerRank SQL
-- 2. 深入方向 — 分布式数据库、数据仓库、数据治理
-- 3. 实战项目 — 搭建个人项目，分析真实数据
-- 4. 认证考试 — MySQL OCP 认证
--
-- 继续加油！
-- ============================================================
