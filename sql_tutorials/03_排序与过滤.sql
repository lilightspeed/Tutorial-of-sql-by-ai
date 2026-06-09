-- ============================================================
-- 第3章 排序与过滤
-- ============================================================
-- 学习目标:
-- - ORDER BY 排序（升序/降序、多列排序）
-- - AND / OR / NOT 逻辑运算符
-- - IN 操作符
-- - BETWEEN 范围查询
-- - LIKE 模糊匹配
-- - IS NULL 空值判断
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. ORDER BY 排序
-- ============================================================
-- 使用 ORDER BY 对查询结果排序
-- 语法: SELECT 列名 FROM 表名 ORDER BY 列名 [ASC|DESC];
--
-- +----------+---------------------------+
-- | 关键字   | 说明                      |
-- +----------+---------------------------+
-- | ASC      | 升序（从小到大，默认）    |
-- | DESC     | 降序（从大到小）          |
-- +----------+---------------------------+

-- 按价格升序排列（默认）
SELECT product_name, price
FROM products
ORDER BY price ASC;

-- 按价格降序排列
SELECT product_name, price
FROM products
ORDER BY price DESC;

-- 多列排序：先按分类升序，再按价格降序
SELECT product_name, category_id, price
FROM products
ORDER BY category_id ASC, price DESC;

-- ============================================================
-- 2. AND — 同时满足多个条件
-- ============================================================
-- 语法: WHERE 条件1 AND 条件2
-- 所有条件都必须为真，行才会被选中

-- 查询价格在 100 到 500 之间的商品
SELECT product_name, price
FROM products
WHERE price >= 100 AND price <= 500
ORDER BY price;

-- 查询北京的、且名字以"张"开头的客户
SELECT customer_name, city
FROM customers
WHERE city = '北京' AND customer_name LIKE '张%';

-- ============================================================
-- 3. OR — 满足任一条件
-- ============================================================
-- 语法: WHERE 条件1 OR 条件2
-- 只要有一个条件为真，行就会被选中

-- 查询北京或上海的客户
SELECT customer_name, city
FROM customers
WHERE city = '北京' OR city = '上海';

-- AND 和 OR 的优先级
-- AND 的优先级高于 OR，使用括号 () 来明确优先级
--
-- 示例:
-- WHERE city = '北京' AND age > 20 OR salary > 10000
-- 等价于:
-- WHERE (city = '北京' AND age > 20) OR salary > 10000
--
-- 使用括号明确意图:
-- WHERE city = '北京' AND (age > 20 OR salary > 10000)

-- 查询电子产品（分类1）或价格超过 5000 的商品
SELECT product_name, category_id, price
FROM products
WHERE category_id = 1 OR price > 5000
ORDER BY price DESC;

-- ============================================================
-- 4. NOT — 取反
-- ============================================================
-- 语法: WHERE NOT 条件
-- 排除满足条件的行

-- 查询不在北京的客户
SELECT customer_name, city
FROM customers
WHERE NOT city = '北京';

-- 查询未完成的订单
SELECT order_id, status, total_amount
FROM orders
WHERE NOT status = '已完成';

-- ============================================================
-- 5. IN — 匹配一组值
-- ============================================================
-- IN 是多个 OR 的简写形式
-- 语法: WHERE 列名 IN (值1, 值2, 值3)
-- 等价于: WHERE 列名 = 值1 OR 列名 = 值2 OR 列名 = 值3

-- 查询北京、上海、广州的客户
SELECT customer_name, city
FROM customers
WHERE city IN ('北京', '上海', '广州');

-- 查询分类为 1、3、4 的商品
SELECT product_name, category_id, price
FROM products
WHERE category_id IN (1, 3, 4)
ORDER BY category_id, price;

-- NOT IN — 不在列表中
SELECT customer_name, city
FROM customers
WHERE city NOT IN ('北京', '上海');

-- ============================================================
-- 6. BETWEEN — 范围查询
-- ============================================================
-- 语法: WHERE 列名 BETWEEN 值1 AND 值2
-- 等价于: WHERE 列名 >= 值1 AND 列名 <= 值2
-- 注意: BETWEEN 是闭区间，包含两端的值

-- 查询价格在 100 到 500 之间的商品
SELECT product_name, price
FROM products
WHERE price BETWEEN 100 AND 500
ORDER BY price;

-- 查询 2024年3月 的订单
SELECT order_id, order_date, total_amount
FROM orders
WHERE order_date BETWEEN '2024-03-01' AND '2024-03-31 23:59:59'
ORDER BY order_date;

-- ============================================================
-- 7. LIKE — 模糊匹配
-- ============================================================
-- 用于字符串的模糊匹配，配合通配符使用
-- 语法: WHERE 列名 LIKE '模式'
--
-- +----------+----------------+----------------+------------------+
-- | 通配符   | 说明           | 示例           | 匹配             |
-- +----------+----------------+----------------+------------------+
-- | %        | 任意多个字符   | '张%'          | 张三、张三丰     |
-- | _        | 恰好一个字符   | '张_'          | 张三（不匹配张三丰）|
-- +----------+----------------+----------------+------------------+

-- 查询名字以"张"开头的客户
SELECT customer_name
FROM customers
WHERE customer_name LIKE '张%';

-- 查询商品名称中包含"Pro"的商品
SELECT product_name, price
FROM products
WHERE product_name LIKE '%Pro%';

-- 查询名字为两个字的客户（姓+名，共2个字符）
SELECT customer_name
FROM customers
WHERE customer_name LIKE '__';

-- ============================================================
-- 8. IS NULL — 空值判断
-- ============================================================
-- NULL 表示"没有值"，不能用 = 判断
-- 必须用 IS NULL 或 IS NOT NULL
-- 语法: WHERE 列名 IS NULL      -- 列值为空
--       WHERE 列名 IS NOT NULL  -- 列值不为空

-- 查询没有上级的员工（顶级管理者）
SELECT employee_name, department, manager_id
FROM employees
WHERE manager_id IS NULL;

-- 查询有上级的员工
SELECT employee_name, department, manager_id
FROM employees
WHERE manager_id IS NOT NULL;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 查询所有商品，按价格从高到低排列
SELECT product_name, price FROM products ORDER BY price DESC;

-- 题目2（简单）: 查询上海或深圳的客户
SELECT * FROM customers WHERE city IN ('上海', '深圳');

-- 题目3（中等）: 查询价格在 100 到 1000 之间、且库存大于 50 的商品名称、价格和库存
SELECT product_name, price, stock
FROM products
WHERE price BETWEEN 100 AND 1000 AND stock > 50
ORDER BY price;

-- 题目4（中等）: 查询商品名称中包含"服"字的商品
SELECT product_name, price FROM products WHERE product_name LIKE '%服%';

-- 题目5（中等）: 查询销售部或技术部的员工，按工资降序排列
SELECT employee_name, department, salary
FROM employees
WHERE department IN ('销售部', '技术部')
ORDER BY salary DESC;

-- ============================================================
-- 下一章：04_聚合函数与分组.sql
-- ============================================================
