-- ============================================================
-- 第6章 子查询
-- ============================================================
-- 学习目标:
-- - 什么是子查询
-- - 标量子查询（返回单个值）
-- - IN 子查询（返回一组值）
-- - EXISTS 子查询
-- - 关联子查询
-- - 子查询 vs JOIN 的选择
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 什么是子查询？
-- ============================================================
-- 子查询（Subquery）是嵌套在另一个 SQL 语句中的 SELECT 语句
-- 语法: SELECT ... FROM ... WHERE 列名 = (SELECT ...);
-- 子查询可以出现在 WHERE、FROM、SELECT 等子句中

-- ============================================================
-- 2. 标量子查询
-- ============================================================
-- 子查询返回单个值（一行一列），可以用在 =、>、< 等比较运算符后面
-- 语法: WHERE 列名 = (SELECT MAX(列名) FROM 表)

-- 查询价格最高的商品
SELECT product_name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);

select product_name, price from products order by price desc limit 1 ;
-- 查询价格高于平均价格的商品
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- 查询工资最高的员工所在的部门
SELECT employee_name, department, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);

-- ============================================================
-- 3. IN 子查询
-- ============================================================
-- 子查询返回一组值，配合 IN 或 NOT IN 使用
-- 语法: WHERE 列名 IN (SELECT 列名 FROM 表)

-- 查询有订单的客户
SELECT customer_name, city
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM orders
);

-- 查询没有订单的客户
SELECT customer_name, city
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
);

-- 查询电子产品（分类名称为'电子产品'）的所有商品
SELECT product_name, price
FROM products
WHERE category_id IN (
    SELECT category_id
    FROM categories
    WHERE category_name = '电子产品'
)
ORDER BY price DESC;

-- ============================================================
-- 4. EXISTS 子查询
-- ============================================================
-- EXISTS 检查子查询是否返回了行，只要子查询有结果，条件就为真
-- 语法: WHERE EXISTS (SELECT ... FROM ... WHERE 关联条件)

-- 查询有订单的客户（使用 EXISTS）
SELECT customer_name, city
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- 查询没有订单的客户（使用 NOT EXISTS）
SELECT customer_name, city
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- ============================================================
-- 5. 关联子查询
-- ============================================================
-- 子查询中引用了外部查询的列，形成关联
-- 语法:
-- SELECT ...
-- FROM 表A a
-- WHERE 列名 = (
--     SELECT MAX(列名)
--     FROM 表B b
--     WHERE b.外键 = a.主键  -- 关联条件
-- );

-- 查询每个分类中价格最高的商品
SELECT product_name, category_id, price
FROM products p
WHERE price = (
    SELECT MAX(price)
    FROM products
    WHERE category_id = p.category_id
)
ORDER BY category_id;

-- 查询每个部门工资最高的员工
SELECT employee_name, department, salary
FROM employees e
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department = e.department
)
ORDER BY department;

-- ============================================================
-- 6. FROM 子句中的子查询
-- ============================================================
-- 子查询也可以放在 FROM 子句中，作为临时表使用（派生表）
-- 语法: SELECT * FROM (SELECT ... ) AS 临时表名;

-- 查询每个客户的订单数，只显示订单数 >= 2 的
SELECT *
FROM (
    SELECT
        customer_id,
        COUNT(*) AS order_count,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
) AS customer_stats
WHERE order_count >= 2
ORDER BY total_spent DESC;

-- ============================================================
-- 7. 子查询 vs JOIN
-- ============================================================
-- +---------------------------+---------------------------+
-- | 场景                      | 推荐使用                  |
-- +---------------------------+---------------------------+
-- | 检查存在性（有/没有）     | EXISTS / NOT EXISTS       |
-- | 比较聚合值                | 标量子查询                |
-- | 需要显示关联表的多列      | JOIN                      |
-- | 性能敏感                  | 通常 JOIN 更快            |
-- +---------------------------+---------------------------+
--
-- 很多情况下，子查询和 JOIN 可以互相转换:
--
-- 子查询写法:
-- SELECT * FROM customers
-- WHERE customer_id IN (SELECT customer_id FROM orders);
--
-- 等价的 JOIN 写法:
-- SELECT DISTINCT c.*
-- FROM customers c
-- INNER JOIN orders o ON c.customer_id = o.customer_id;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 查询库存最少的商品
SELECT product_name, stock
FROM products
WHERE stock = (SELECT MIN(stock) FROM products);

-- 题目2（简单）: 查询工资高于平均工资的员工
SELECT employee_name, department, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- 题目3（中等）: 查询至少下过一个订单的员工姓名
SELECT employee_name, department
FROM employees
WHERE employee_id IN (
    SELECT DISTINCT employee_id
    FROM orders
);

-- 题目4（中等）: 查询每个分类中价格最低的商品
SELECT product_name, category_id, price
FROM products p
WHERE price = (
    SELECT MIN(price)
    FROM products
    WHERE category_id = p.category_id
)
ORDER BY category_id;

-- 题目5（较难）: 查询总消费金额最高的客户姓名和总消费金额
SELECT customer_name, total_spent
FROM customers c
INNER JOIN (
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
) o ON c.customer_id = o.customer_id
WHERE total_spent = (
    SELECT MAX(total_sum)
    FROM (
        SELECT SUM(total_amount) AS total_sum
        FROM orders
        GROUP BY customer_id
    ) AS sums
);

-- ============================================================
-- 下一章：07_数据操作_DML.sql
-- ============================================================
