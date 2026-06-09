-- ============================================================
-- 第5章 多表连接查询
-- ============================================================
-- 学习目标:
-- - 为什么需要连接查询
-- - INNER JOIN 内连接
-- - LEFT JOIN 左连接
-- - RIGHT JOIN 右连接
-- - 多表连接
-- - 自连接
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 为什么需要连接查询？
-- ============================================================
-- 在关系型数据库中，数据被分散存储在多张表中以避免冗余
-- 当我们需要从多张表中获取关联数据时，就需要使用连接查询（JOIN）
--
-- 例子:
-- orders 表只存储了 customer_id，没有客户姓名
-- 要同时显示订单和客户姓名，就需要连接两张表
--
-- orders 表                          customers 表
-- +----------+-------------+        +-------------+--------------+
-- | order_id | customer_id |        | customer_id | customer_name|
-- +----------+-------------+        +-------------+--------------+
-- | 1        | 1           |------->| 1           | 张三         |
-- | 2        | 2           |------->| 2           | 李四         |
-- +----------+-------------+        +-------------+--------------+

-- ============================================================
-- 2. INNER JOIN — 内连接
-- ============================================================
-- 只返回两张表中都能匹配的行
-- 语法: SELECT 列名 FROM 表A INNER JOIN 表B ON 表A.列 = 表B.列;
--
--     表A            表B
--    +---+         +---+
--    |   | XXXXXXXX|   |  <-- 返回重叠部分
--    |   | XXXXXXXX|   |
--    +---+         +---+

-- 内连接：订单 + 客户信息
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date;

-- 连接商品和分类表
SELECT
    p.product_name,
    c.category_name,
    p.price
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
ORDER BY c.category_name, p.price;

-- 连接时可以使用 WHERE 过滤
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE c.city = '北京'
ORDER BY o.total_amount DESC;

-- ============================================================
-- 3. LEFT JOIN — 左连接
-- ============================================================
-- 返回左表的所有行，即使右表没有匹配
-- 右表无匹配时显示 NULL
-- 语法: SELECT 列名 FROM 表A LEFT JOIN 表B ON 表A.列 = 表B.列;
--
--     表A            表B
--    +---+         +---+
--    |XXX| XXXXXXXX|   |  <-- 左表全部 + 右表匹配
--    |XXX| XXXXXXXX|   |
--    +---+         +---+

-- LEFT JOIN：显示所有客户，即使没有订单
SELECT
    c.customer_name,
    c.city,
    o.order_id,
    o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_name;

-- 查找没有订单的客户
SELECT
    c.customer_name,
    c.city
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- ============================================================
-- 4. RIGHT JOIN — 右连接
-- ============================================================
-- 返回右表的所有行，即使左表没有匹配
-- 左表无匹配时显示 NULL
-- 语法: SELECT 列名 FROM 表A RIGHT JOIN 表B ON 表A.列 = 表B.列;

-- RIGHT JOIN：显示所有员工，即使没有处理过订单
SELECT
    e.employee_name,
    e.department,
    o.order_id
FROM orders o
RIGHT JOIN employees e ON o.employee_id = e.employee_id
ORDER BY e.employee_name;

-- ============================================================
-- 5. 连接类型对比
-- ============================================================
-- +--------------+---------------------------+---------------------------+
-- | 连接类型     | 说明                      | 使用场景                  |
-- +--------------+---------------------------+---------------------------+
-- | INNER JOIN   | 只返回匹配的行            | 最常用，需要关联数据时    |
-- | LEFT JOIN    | 左表全返回                | 需要保留左表所有记录      |
-- | RIGHT JOIN   | 右表全返回                | 需要保留右表所有记录      |
-- | FULL JOIN    | 两表全返回（MySQL不直接支持）| 需要保留两表所有记录    |
-- +--------------+---------------------------+---------------------------+

-- ============================================================
-- 6. 多表连接
-- ============================================================
-- 可以同时连接多张表
-- 语法: SELECT ... FROM 表A JOIN 表B ON 条件1 JOIN 表C ON 条件2;

-- 三表连接：订单 + 客户 + 员工
SELECT
    o.order_id,
    c.customer_name AS 客户,
    e.employee_name AS 负责员工,
    o.order_date,
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN employees e ON o.employee_id = e.employee_id
ORDER BY o.order_date;

-- 四表连接：订单明细 + 订单 + 商品 + 分类
SELECT
    o.order_id,
    p.product_name AS 商品,
    cat.category_name AS 分类,
    oi.quantity AS 数量,
    oi.unit_price AS 单价,
    oi.quantity * oi.unit_price AS 小计
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN categories cat ON p.category_id = cat.category_id
ORDER BY o.order_id;

-- ============================================================
-- 7. 自连接
-- ============================================================
-- 表与自身进行连接，常用于处理层级关系（如员工-上级）
-- 语法: SELECT e.员工, m.上级 FROM 员工表 e JOIN 员工表 m ON e.manager_id = m.employee_id;

-- 自连接：查询员工及其上级
SELECT
    e.employee_name AS 员工,
    e.department AS 部门,
    m.employee_name AS 上级
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.employee_id;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 查询所有商品及其分类名称
SELECT p.product_name, c.category_name, p.price
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
ORDER BY c.category_name, p.price;

-- 题目2（简单）: 查询所有订单及其客户姓名和城市
SELECT o.order_id, c.customer_name, c.city, o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date;

-- 题目3（中等）: 查询每个客户的订单数量（没有订单的客户显示 0）
SELECT
    c.customer_name,
    COUNT(o.order_id) AS 订单数量
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY 订单数量 DESC;

-- 题目4（中等）: 查询每个分类的商品数量和平均价格

select c.category_name '类别', avg(p.price) '平均价格', count(p.product_id) '商品数量'
from products p
left join categories c on p.category_id = c.category_id
group by c.category_name, c.category_id
order by '商品数量' desc;





SELECT
    c.category_name,
    COUNT(p.product_id) AS 商品数量,
    ROUND(AVG(p.price), 2) AS 平均价格
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY 商品数量 DESC;

-- 题目5（较难）: 查询每个订单的详细信息
SELECT
    o.order_id,
    c.customer_name AS 客户名,
    e.employee_name AS 员工名,
    p.product_name AS 商品名,
    oi.quantity AS 数量,
    oi.unit_price AS 单价
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN employees e ON o.employee_id = e.employee_id
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;

-- ============================================================
-- 下一章：06_子查询.sql
-- ============================================================
