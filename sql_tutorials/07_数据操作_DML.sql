-- ============================================================
-- 第7章 数据操作 — DML
-- ============================================================
-- 学习目标:
-- - INSERT 插入数据
-- - UPDATE 更新数据
-- - DELETE 删除数据
-- - 批量操作
-- - 安全注意事项
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. INSERT — 插入数据
-- ============================================================

-- 1.1 基本语法
-- INSERT INTO 表名 (列1, 列2, 列3) VALUES (值1, 值2, 值3);
--
-- 注意事项:
-- - 字符串值用单引号 ' ' 包裹
-- - 数值不需要引号
-- - 日期时间用 'YYYY-MM-DD' 格式
-- - 自增列（如 AUTO_INCREMENT）可以省略

-- 插入一个新客户
INSERT INTO customers (customer_name, email, phone, city)
VALUES ('测试用户', 'test@email.com', '13900001111', '北京');

-- 验证插入结果
SELECT * FROM customers ORDER BY customer_id DESC LIMIT 5;

-- 1.2 插入多条数据
-- INSERT INTO 表名 (列1, 列2) VALUES (值1, 值2), (值3, 值4), (值5, 值6);

-- 批量插入新商品
INSERT INTO products (product_name, category_id, price, stock)
VALUES
    ('测试商品A', 1, 999.00, 50),
    ('测试商品B', 2, 199.00, 100),
    ('测试商品C', 3, 39.90, 200);

-- 验证
SELECT * FROM products ORDER BY product_id DESC LIMIT 5;

-- 1.3 从查询结果插入
-- INSERT INTO 表A (列1, 列2) SELECT 列1, 列2 FROM 表B WHERE 条件;

-- ============================================================
-- 2. UPDATE — 更新数据
-- ============================================================
-- 语法: UPDATE 表名 SET 列1 = 新值1, 列2 = 新值2 WHERE 条件;
-- 警告: 如果不加 WHERE 条件，会更新所有行！

-- 先查看要修改的数据
SELECT * FROM customers WHERE customer_name = '测试用户';

-- 更新客户城市
UPDATE customers
SET city = '上海', email = 'test_sh@email.com'
WHERE customer_name = '测试用户';

-- 验证更新结果
SELECT * FROM customers WHERE customer_name = '测试用户';

-- 给所有商品打 9 折
UPDATE products
SET price = ROUND(price * 0.9, 2)
WHERE product_name LIKE '测试%';

-- 验证
SELECT product_name, price FROM products WHERE product_name LIKE '测试%';

-- ============================================================
-- 3. DELETE — 删除数据
-- ============================================================
-- 语法: DELETE FROM 表名 WHERE 条件;
-- 警告: 如果不加 WHERE 条件，会删除所有行！

-- 删除测试客户
DELETE FROM customers
WHERE customer_name = '测试用户';

-- 删除测试商品
DELETE FROM products
WHERE product_name LIKE '测试%';

-- 验证删除结果
SELECT COUNT(*) AS 剩余客户数 FROM customers;

-- ============================================================
-- 4. 安全操作最佳实践
-- ============================================================

-- 4.1 先 SELECT 再操作
-- 在执行 UPDATE 或 DELETE 前，先用 SELECT 确认要操作的数据:
-- 第1步：确认数据
-- SELECT * FROM orders WHERE status = '已取消';
-- 第2步：确认无误后再执行
-- DELETE FROM orders WHERE status = '已取消';

-- 4.2 使用事务
START TRANSACTION;
-- UPDATE accounts SET balance = balance - 100 WHERE id = 1;
-- UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
ROLLBACK;

-- 4.3 限制影响范围
-- 使用 LIMIT 限制删除数量
-- DELETE FROM logs WHERE created_at < '2023-01-01' LIMIT 1000;

-- ============================================================
-- 练习题
-- ============================================================
-- 注意: 以下练习涉及数据修改，请谨慎操作。建议先用 SELECT 确认数据。

-- 题目1（简单）: 向 categories 表插入一个新分类
INSERT INTO categories (category_name, description)
VALUES ('体育用品', '运动器材和装备');

-- 验证
SELECT * FROM categories ORDER BY category_id DESC LIMIT 3;

-- 题目2（简单）: 将客户 '张三' 的城市修改为 '深圳'
UPDATE customers
SET city = '深圳'
WHERE customer_name = '张三';

-- 验证
SELECT customer_name, city FROM customers WHERE customer_name = '张三';

-- 题目3（中等）: 将所有 '待处理' 状态的订单修改为 '已取消'

update orders
set status = '待处理'
where status = '已取消';






UPDATE orders
SET status = '已取消'
WHERE status = '待处理';

-- 验证
SELECT order_id, status FROM orders WHERE status = '已取消';

-- 题目4（中等）: 删除刚才插入的 '体育用品' 分类

delete from categories
where category_name = '体育用品';





DELETE FROM categories
WHERE category_name = '体育用品';

-- 题目5（较难）: 插入一个新订单和订单明细
-- 第1步：插入订单
INSERT INTO orders (customer_id, employee_id, order_date, status, total_amount)
VALUES (1, 4, NOW(), '待处理', 299.00);

-- 第2步：获取新订单的ID
SET @new_order_id = LAST_INSERT_ID();

-- 第3步：插入订单明细
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (@new_order_id, 6, 3, 99.00);

-- 验证
SELECT o.order_id, c.customer_name, o.status, o.total_amount,
       oi.product_id, oi.quantity, oi.unit_price
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_id = @new_order_id;

-- ============================================================
-- 下一章：08_数据定义_DDL.sql
-- ============================================================
