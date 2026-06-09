-- ============================================================
-- 第12章 综合实战
-- ============================================================
-- 学习目标:
-- 本章通过综合练习题，巩固前面所有章节学到的知识
-- 题目涵盖:
-- - 基本查询与过滤
-- - 聚合与分组
-- - 多表连接
-- - 子查询
-- - 数据操作
-- - 综合分析
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 综合练习题
-- ============================================================

-- ============================================================
-- 第一部分：基础查询（共 5 题）
-- ============================================================

-- 题目 1.1: 查询所有价格超过 500 元的商品，按价格降序排列
SELECT product_name AS 商品名称, price AS 价格
FROM products
WHERE price > 500
ORDER BY price DESC;

-- 题目 1.2: 查询所有来自北京或上海的客户
SELECT customer_name AS 客户姓名, city AS 城市
FROM customers
WHERE city IN ('北京', '上海');

-- 题目 1.3: 查询商品名称中包含"Pro"的商品
SELECT product_name, price
FROM products
WHERE product_name LIKE '%Pro%';

-- 题目 1.4: 查询 2024年2月 之后创建的订单
SELECT order_id AS 订单ID, order_date AS 下单日期, total_amount AS 总金额
FROM orders
WHERE order_date > '2024-02-28 23:59:59'
ORDER BY order_date;

-- 题目 1.5: 查询每个城市的客户数量，只显示客户数 >= 2 的城市
SELECT city AS 城市, COUNT(*) AS 客户数量
FROM customers
GROUP BY city
HAVING COUNT(*) >= 2
ORDER BY 客户数量 DESC;

-- ============================================================
-- 第二部分：聚合与分组（共 5 题）
-- ============================================================

-- 题目 2.1: 计算所有商品的平均价格、最高价格和最低价格
SELECT
    ROUND(AVG(price), 2) AS 平均价格,
    MAX(price) AS 最高价格,
    MIN(price) AS 最低价格
FROM products;

-- 题目 2.2: 统计每个分类的商品数量和平均价格
SELECT
    c.category_name AS 分类,
    COUNT(p.product_id) AS 商品数量,
    ROUND(AVG(p.price), 2) AS 平均价格
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY 商品数量 DESC;

-- 题目 2.3: 查询每个客户的订单数量和总消费金额
SELECT
    c.customer_name AS 客户,
    COUNT(o.order_id) AS 订单数量,
    SUM(o.total_amount) AS 总消费金额
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY 总消费金额 DESC;

-- 题目 2.4: 查询平均订单金额超过 2000 元的客户ID和平均金额
SELECT
    customer_id AS 客户ID,
    ROUND(AVG(total_amount), 2) AS 平均金额
FROM orders
GROUP BY customer_id
HAVING AVG(total_amount) > 2000
ORDER BY 平均金额 DESC;

-- 题目 2.5: 统计每个员工处理的订单数量和订单总金额
SELECT
    e.employee_name AS 员工,
    e.department AS 部门,
    COUNT(o.order_id) AS 订单数量,
    IFNULL(SUM(o.total_amount), 0) AS 订单总金额
FROM employees e
LEFT JOIN orders o ON e.employee_id = o.employee_id
GROUP BY e.employee_id, e.employee_name, e.department
ORDER BY 订单总金额 DESC;

-- ============================================================
-- 第三部分：多表连接（共 5 题）
-- ============================================================

-- 题目 3.1: 查询所有订单的订单ID、客户姓名、员工姓名和订单金额
SELECT
    o.order_id AS 订单ID,
    c.customer_name AS 客户,
    e.employee_name AS 员工,
    o.total_amount AS 金额
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN employees e ON o.employee_id = e.employee_id
ORDER BY o.total_amount DESC;

-- 题目 3.2: 查询每个分类的商品数量和总库存，包括没有商品的分类
SELECT
    c.category_name AS 分类,
    COUNT(p.product_id) AS 商品数量,
    IFNULL(SUM(p.stock), 0) AS 总库存
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY 总库存 DESC;

-- 题目 3.3: 查询每个订单的详细信息
SELECT
    o.order_id AS 订单ID,
    c.customer_name AS 客户,
    p.product_name AS 商品,
    oi.quantity AS 数量,
    oi.unit_price AS 单价,
    oi.quantity * oi.unit_price AS 小计
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, 小计 DESC;

-- 题目 3.4: 查询没有下过订单的客户
SELECT c.customer_name AS 客户, c.city AS 城市
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 题目 3.5: 查询每个员工及其上级的名字（自连接）
SELECT
    e.employee_name AS 员工,
    e.department AS 部门,
    IFNULL(m.employee_name, '无上级') AS 上级
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.employee_id;

-- ============================================================
-- 第四部分：子查询（共 5 题）
-- ============================================================

-- 题目 4.1: 查询价格最高的商品
SELECT product_name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);

-- 题目 4.2: 查询工资高于平均工资的员工
SELECT employee_name, department, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- 题目 4.3: 查询每个分类中价格最高的商品
SELECT product_name, category_id, price
FROM products p
WHERE price = (
    SELECT MAX(price)
    FROM products
    WHERE category_id = p.category_id
)
ORDER BY category_id;

-- 题目 4.4: 查询总消费金额最高的客户姓名
SELECT c.customer_name, o.total_spent
FROM customers c
INNER JOIN (
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
) o ON c.customer_id = o.customer_id
WHERE o.total_spent = (
    SELECT MAX(total_sum)
    FROM (SELECT SUM(total_amount) AS total_sum FROM orders GROUP BY customer_id) t
);

-- 题目 4.5: 查询至少下过 2 个订单的客户姓名和订单数量
SELECT
    c.customer_name AS 客户,
    COUNT(o.order_id) AS 订单数量
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) >= 2
ORDER BY 订单数量 DESC;

-- ============================================================
-- 第五部分：综合分析（共 5 题）
-- ============================================================

-- 题目 5.1: 计算每个客户的 RFM 指标
-- R (Recency): 最近一次订单距今天数
-- F (Frequency): 订单数量
-- M (Monetary): 总消费金额
SELECT
    c.customer_name AS 客户,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS R_最近购买天数,
    COUNT(o.order_id) AS F_订单数量,
    ROUND(IFNULL(SUM(o.total_amount), 0), 2) AS M_总消费金额
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY M_总消费金额 DESC;

-- 题目 5.2: 找出每个分类中销量最高的商品
SELECT
    cat.category_name AS 分类,
    p.product_name AS 商品,
    SUM(oi.quantity) AS 总销量
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN categories cat ON p.category_id = cat.category_id
GROUP BY cat.category_name, p.product_name
HAVING SUM(oi.quantity) = (
    SELECT MAX(total_qty)
    FROM (
        SELECT SUM(oi2.quantity) AS total_qty
        FROM order_items oi2
        INNER JOIN products p2 ON oi2.product_id = p2.product_id
        WHERE p2.category_id = p.category_id
        GROUP BY p2.product_id
    ) t
)
ORDER BY 总销量 DESC;

-- 题目 5.3: 生成月度销售报表
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS 月份,
    COUNT(*) AS 订单数量,
    ROUND(SUM(total_amount), 2) AS 总金额
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY 月份;

-- 题目 5.4: 找出购买过"电子产品"分类商品的客户，以及他们还购买了哪些其他分类的商品
SELECT DISTINCT
    c.customer_name AS 客户,
    cat.category_name AS 其他购买分类
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN categories cat ON p.category_id = cat.category_id
WHERE c.customer_id IN (
    -- 购买过电子产品的客户
    SELECT DISTINCT o2.customer_id
    FROM orders o2
    INNER JOIN order_items oi2 ON o2.order_id = oi2.order_id
    INNER JOIN products p2 ON oi2.product_id = p2.product_id
    WHERE p2.category_id = 1
)
AND cat.category_name != '电子产品'
ORDER BY c.customer_name, cat.category_name;

-- 题目 5.5: 创建一个视图 v_sales_report
DROP VIEW IF EXISTS v_sales_report;
CREATE VIEW v_sales_report AS
SELECT
    o.order_id,
    c.customer_name,
    e.employee_name,
    o.order_date,
    o.status,
    o.total_amount,
    GROUP_CONCAT(
        CONCAT(p.product_name, ' x', oi.quantity)
        SEPARATOR ', '
    ) AS items_detail
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN employees e ON o.employee_id = e.employee_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id, c.customer_name, e.employee_name, o.order_date, o.status, o.total_amount;

-- 使用视图
SELECT * FROM v_sales_report ORDER BY total_amount DESC;

-- ============================================================
-- 恭喜完成 SQL 入门教程！
-- ============================================================
-- 你已经学习了:
-- +----------+------------------------------------------+
-- | 章节     | 知识点                                   |
-- +----------+------------------------------------------+
-- | 第0章    | 环境搭建                                 |
-- | 第1章    | 数据库基础概念                           |
-- | 第2章    | SELECT 基本查询                          |
-- | 第3章    | 排序与过滤                               |
-- | 第4章    | 聚合函数与分组                           |
-- | 第5章    | 多表连接查询                             |
-- | 第6章    | 子查询                                   |
-- | 第7章    | 数据操作 (DML)                           |
-- | 第8章    | 数据定义 (DDL)                           |
-- | 第9章    | 约束与索引                               |
-- | 第10章   | 视图与存储过程                           |
-- | 第11章   | 事务与并发控制                           |
-- | 第12章   | 综合实战                                 |
-- +----------+------------------------------------------+
--
-- 继续学习的建议:
-- 1. 多练习 — 在 LeetCode SQL 上刷题
-- 2. 深入学习 — 阅读 MySQL 官方文档
-- 3. 项目实践 — 用 SQL 解决实际工作中的数据问题
-- 4. 学习进阶 — 窗口函数、CTE、性能优化等高级特性
--
-- 祝你学习愉快！
-- ============================================================
