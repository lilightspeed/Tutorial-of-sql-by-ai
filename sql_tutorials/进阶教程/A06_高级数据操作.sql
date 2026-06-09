-- ============================================================
-- 第6章 高级数据操作
-- ============================================================
-- 学习目标:
-- - INSERT ... ON DUPLICATE KEY UPDATE（Upsert）
-- - REPLACE INTO
-- - INSERT ... SELECT
-- - 批量操作优化
-- - LOAD DATA INFILE
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. INSERT ... ON DUPLICATE KEY UPDATE
-- ============================================================
-- 如果插入时主键或唯一键冲突，则执行更新操作（Upsert）
-- 语法:
-- INSERT INTO 表名 (列1, 列2)
-- VALUES (值1, 值2)
-- ON DUPLICATE KEY UPDATE
--     列2 = VALUES(列2);

-- 创建演示表
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    stock INT DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 首次插入
INSERT INTO inventory (product_id, stock) VALUES (1, 100);
SELECT * FROM inventory;

-- 再次插入相同 product_id → 更新
INSERT INTO inventory (product_id, stock) VALUES (1, 150)
ON DUPLICATE KEY UPDATE stock = VALUES(stock);
SELECT * FROM inventory;

-- 累加库存
INSERT INTO inventory (product_id, stock) VALUES (1, 50)
ON DUPLICATE KEY UPDATE stock = stock + VALUES(stock);
SELECT * FROM inventory;

-- ============================================================
-- 2. REPLACE INTO
-- ============================================================
-- 如果主键或唯一键冲突，先删除旧行，再插入新行
-- 语法: REPLACE INTO 表名 (列1, 列2) VALUES (值1, 值2);

-- REPLACE INTO
REPLACE INTO inventory (product_id, stock) VALUES (1, 200);
SELECT * FROM inventory;

-- ============================================================
-- 3. INSERT ... SELECT
-- ============================================================
-- 从查询结果插入数据

-- 创建备份表
DROP TABLE IF EXISTS orders_backup;
CREATE TABLE orders_backup LIKE orders;

-- 从查询结果插入
INSERT INTO orders_backup
SELECT * FROM orders WHERE status = '已完成';

SELECT COUNT(*) AS 备份订单数 FROM orders_backup;

-- ============================================================
-- 4. 批量操作优化
-- ============================================================

-- 4.1 多值 INSERT vs 逐条 INSERT
-- 多值 INSERT（推荐）

DROP TABLE IF EXISTS batch_test;
CREATE TABLE batch_test (id INT PRIMARY KEY, name VARCHAR(50));

INSERT INTO batch_test (id, name) VALUES
(1, 'A'), (2, 'B'), (3, 'C'), (4, 'D'), (5, 'E');

SELECT * FROM batch_test;

-- 4.2 批量更新
-- 使用 CASE WHEN 实现批量条件更新

-- 批量更新：根据订单状态设置不同的折扣
UPDATE orders
SET total_amount = total_amount * CASE status
    WHEN '已完成' THEN 1.0
    WHEN '已发货' THEN 0.95
    WHEN '待处理' THEN 0.90
    ELSE 1.0
END
WHERE order_id <= 5;

SELECT order_id, status, total_amount FROM orders WHERE order_id <= 5;

-- 还原数据
UPDATE orders
SET total_amount = total_amount / CASE status
    WHEN '已完成' THEN 1.0
    WHEN '已发货' THEN 0.95
    WHEN '待处理' THEN 0.90
    ELSE 1.0
END
WHERE order_id <= 5;

-- ============================================================
-- 5. 清理
-- ============================================================

DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS orders_backup;
DROP TABLE IF EXISTS batch_test;
SELECT '清理完成' AS result;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: Upsert
DROP TABLE IF EXISTS user_scores;
CREATE TABLE user_scores (user_id INT PRIMARY KEY, score INT);

-- 首次插入
INSERT INTO user_scores (user_id, score) VALUES (1, 80);
SELECT * FROM user_scores;

-- Upsert 更新
INSERT INTO user_scores (user_id, score) VALUES (1, 95)
ON DUPLICATE KEY UPDATE score = VALUES(score);
SELECT * FROM user_scores;

DROP TABLE IF EXISTS user_scores;

-- 题目2（中等）: INSERT ... SELECT
DROP TABLE IF EXISTS beijing_orders;
CREATE TABLE beijing_orders LIKE orders;

INSERT INTO beijing_orders
SELECT o.*
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE c.city = '北京';

SELECT * FROM beijing_orders;
DROP TABLE IF EXISTS beijing_orders;

-- 题目3（中等）: 批量更新
UPDATE products
SET price = ROUND(price * CASE category_id
    WHEN 1 THEN 1.10  -- 电子产品 +10%
    WHEN 2 THEN 0.95  -- 服装 -5%
    ELSE 1.00
END, 2);

SELECT c.category_name, p.product_name, p.price
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
ORDER BY c.category_name, p.price DESC;
