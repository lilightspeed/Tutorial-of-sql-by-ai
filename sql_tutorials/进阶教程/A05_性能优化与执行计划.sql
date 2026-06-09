-- ============================================================
-- 第5章 性能优化与执行计划
-- ============================================================
-- 学习目标:
-- - EXPLAIN 执行计划解读
-- - 索引策略与优化
-- - 慢查询分析
-- - 常见优化技巧
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. EXPLAIN 执行计划
-- ============================================================
-- EXPLAIN 显示 MySQL 如何执行一条查询，是性能调优的核心工具
-- 语法: EXPLAIN SELECT ...;
--       EXPLAIN ANALYZE SELECT ...;  -- MySQL 8.0.18+，包含实际执行时间

-- EXPLAIN 基本用法
EXPLAIN SELECT * FROM products WHERE price > 1000;

-- EXPLAIN 连接查询
EXPLAIN SELECT o.order_id, c.customer_name
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE c.city = '北京';

-- EXPLAIN 关键字段解读:
-- +----------+----------------+---------------------------+
-- | 字段     | 说明           | 关注点                    |
-- +----------+----------------+---------------------------+
-- | type     | 访问类型       | ALL→index→range→ref→eq_ref→const |
-- | key      | 使用的索引     | NULL 表示没用索引         |
-- | rows     | 预估扫描行数   | 越小越好                  |
-- | Extra    | 额外信息       | Using filesort/temporary 需优化 |
-- +----------+----------------+---------------------------+
--
-- type 性能排序（从差到好）:
-- ALL < index < range < ref < eq_ref < const < system
-- 全表  索引全扫  范围扫描  索引查找  唯一索引  常量

-- ============================================================
-- 2. 索引策略
-- ============================================================

-- 2.1 联合索引（复合索引）
-- 语法: CREATE INDEX idx_name ON table(col1, col2, col3);
--
-- 最左前缀原则: 索引 (a, b, c) 可以用于:
-- WHERE a = ?                     -- 可以使用
-- WHERE a = ? AND b = ?           -- 可以使用
-- WHERE a = ? AND b = ? AND c = ? -- 可以使用
-- WHERE b = ?                     -- 不能使用
-- WHERE a = ? AND c = ?           -- 只能用到 a

-- 创建联合索引
CREATE INDEX idx_order_cust_date ON orders(customer_id, order_date);

-- 使用联合索引
EXPLAIN SELECT * FROM orders WHERE customer_id = 1 AND order_date > '2024-01-01';

-- 2.2 覆盖索引
-- 当查询的所有列都在索引中时，MySQL 可以直接从索引返回数据，无需回表
-- 索引：(customer_id, order_date)
-- SELECT customer_id, order_date FROM orders WHERE customer_id = 1;
-- Extra 会显示 Using index

-- 覆盖索引示例
EXPLAIN SELECT customer_id, order_date FROM orders WHERE customer_id = 1;

-- ============================================================
-- 3. 常见优化技巧
-- ============================================================

-- 3.1 避免 SELECT *
-- 不好: SELECT * FROM orders WHERE customer_id = 1;
-- 好: SELECT order_id, total_amount FROM orders WHERE customer_id = 1;

-- 3.2 避免在索引列上使用函数
-- 不好: 索引失效
-- SELECT * FROM orders WHERE YEAR(order_date) = 2024;
-- 好: 使用范围查询
-- SELECT * FROM orders WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';

-- 对比
EXPLAIN SELECT * FROM orders WHERE YEAR(order_date) = 2024;
EXPLAIN SELECT * FROM orders WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';

-- 3.3 避免隐式类型转换
-- 不好: phone 是 VARCHAR，传入数字会导致隐式转换
-- SELECT * FROM customers WHERE phone = 13800001111;
-- 好: 类型匹配
-- SELECT * FROM customers WHERE phone = '13800001111';

-- 3.4 LIMIT 优化
-- 深分页问题: OFFSET 越大越慢
-- SELECT * FROM orders LIMIT 10 OFFSET 100000;
-- 优化: 使用游标分页
-- SELECT * FROM orders WHERE order_id > 上次最后ID LIMIT 10;

-- ============================================================
-- 4. 清理测试索引
-- ============================================================

-- 清理
DROP INDEX idx_order_cust_date ON orders;
SELECT '测试索引已清理' AS result;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 使用 EXPLAIN 分析一个简单查询的执行计划
EXPLAIN SELECT * FROM products WHERE category_id = 1 AND price > 1000;

-- 题目2（中等）: 为 products 表的 price 列创建索引，然后对比创建前后的 EXPLAIN 结果
-- 创建索引前
EXPLAIN SELECT * FROM products WHERE price > 1000;

-- 创建索引
CREATE INDEX idx_product_price ON products(price);

-- 创建索引后
EXPLAIN SELECT * FROM products WHERE price > 1000;

-- 清理
DROP INDEX idx_product_price ON products;

-- 题目3（中等）: 隐式类型转换示例
-- 隐式类型转换（索引失效）
EXPLAIN SELECT * FROM customers WHERE phone = 13800001111;

-- 正确类型（索引有效）
EXPLAIN SELECT * FROM customers WHERE phone = '13800001111';
