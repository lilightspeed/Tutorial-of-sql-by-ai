-- ============================================================
-- 第10章 视图与存储过程
-- ============================================================
-- 学习目标:
-- - 视图（VIEW）的创建和使用
-- - 存储过程（Stored Procedure）基础
-- - 存储函数（Function）
-- - 触发器（Trigger）基础
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 视图（VIEW）
-- ============================================================
-- 视图是一个虚拟表，基于 SELECT 查询的结果
-- 它不存储数据，每次访问时动态生成
-- 语法: CREATE VIEW 视图名 AS SELECT 语句;

-- 创建一个订单详情视图
DROP VIEW IF EXISTS v_order_details;
CREATE VIEW v_order_details AS
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    e.employee_name,
    o.order_date,
    o.status,
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN employees e ON o.employee_id = e.employee_id;

-- 使用视图（像普通表一样查询）
SELECT * FROM v_order_details ORDER BY total_amount DESC;

-- 对视图使用 WHERE 过滤
SELECT * FROM v_order_details
WHERE city = '北京'
ORDER BY total_amount DESC;

-- 对视图使用聚合
SELECT
    city,
    COUNT(*) AS 订单数,
    SUM(total_amount) AS 总金额
FROM v_order_details
GROUP BY city
ORDER BY 总金额 DESC;

-- 视图的优点:
-- +----------------+------------------------------------------+
-- | 优点           | 说明                                     |
-- +----------------+------------------------------------------+
-- | 简化查询       | 封装复杂 JOIN，使用时只需 SELECT * FROM 视图 |
-- | 安全性         | 可以只暴露部分列给用户                   |
-- | 一致性         | 不同用户看到相同的数据逻辑               |
-- +----------------+------------------------------------------+

-- ============================================================
-- 2. 存储过程（Stored Procedure）
-- ============================================================
-- 存储过程是一组预编译的 SQL 语句，可以接受参数，像函数一样调用
--
-- 创建存储过程:
-- DELIMITER //
-- CREATE PROCEDURE 过程名(参数列表)
-- BEGIN
--     SQL 语句;
-- END //
-- DELIMITER ;
--
-- 调用存储过程: CALL 过程名(参数);

-- 创建：根据城市查询客户
DROP PROCEDURE IF EXISTS get_customers_by_city;
DELIMITER //
CREATE PROCEDURE get_customers_by_city(IN city_name VARCHAR(50))
BEGIN
    SELECT customer_name, email, phone
    FROM customers
    WHERE city = city_name;
END //
DELIMITER ;

CALL get_customers_by_city('北京');

-- 查看数据库的默认 collation
SHOW CREATE DATABASE shop_db;

-- 或
SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'shop_db';
ALTER DATABASE shop_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

DROP PROCEDURE IF EXISTS get_customers_by_city;
DELIMITER //
CREATE PROCEDURE get_customers_by_city(IN city_name VARCHAR(50))
BEGIN
    SELECT customer_name, email, phone
    FROM customers
    WHERE CONVERT(city USING utf8mb4) COLLATE utf8mb4_unicode_ci = CONVERT(city_name USING utf8mb4) COLLATE utf8mb4_unicode_ci;
END //
DELIMITER ;




-- 调用存储过程
CALL get_customers_by_city('北京');

-- 创建带输出参数的存储过程
DROP PROCEDURE IF EXISTS get_order_stats;
DELIMITER //
CREATE PROCEDURE get_order_stats(
    IN cust_id INT,
    OUT order_count INT,
    OUT total_spent DECIMAL(12,2)
)
BEGIN
    SELECT COUNT(*), IFNULL(SUM(total_amount), 0)
    INTO order_count, total_spent
    FROM orders
    WHERE customer_id = cust_id;
END //
DELIMITER ;

-- 调用带输出参数的存储过程
CALL get_order_stats(1, @cnt, @total);
SELECT @cnt AS 订单数, @total AS 总消费;

-- ============================================================
-- 3. 存储函数（Function）
-- ============================================================
-- 存储函数返回一个值，可以在 SQL 语句中使用
--
-- 语法:
-- DELIMITER //
-- CREATE FUNCTION 函数名(参数)
-- RETURNS 返回类型
-- BEGIN
--     RETURN 值;
-- END //
-- DELIMITER ;

-- 创建函数：根据价格返回等级
DROP FUNCTION IF EXISTS price_level;
DELIMITER //
CREATE FUNCTION price_level(p DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE level VARCHAR(20);
    IF p < 100 THEN
        SET level = '低价';
    ELSEIF p < 1000 THEN
        SET level = '中价';
    ELSE
        SET level = '高价';
    END IF;
    RETURN level;
END //
DELIMITER ;

-- 使用自定义函数
SELECT
    product_name,
    price,
    price_level(price) AS 价格等级
FROM products
ORDER BY price
LIMIT 10;

-- ============================================================
-- 4. 触发器（Trigger）
-- ============================================================
-- 触发器在表上执行 INSERT/UPDATE/DELETE 时自动触发
--
-- 语法:
-- CREATE TRIGGER 触发器名
-- BEFORE/AFTER INSERT/UPDATE/DELETE ON 表名
-- FOR EACH ROW
-- BEGIN
--     -- 触发时执行的语句
-- END;

-- 创建一个日志表
DROP TABLE IF EXISTS audit_log;
CREATE TABLE audit_log (
    log_id      INT PRIMARY KEY AUTO_INCREMENT,
    action      VARCHAR(20),
    table_name  VARCHAR(50),
    record_id   INT,
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 创建触发器：插入新客户时记录日志
DROP TRIGGER IF EXISTS trg_after_insert_customer;
DELIMITER //
CREATE TRIGGER trg_after_insert_customer
AFTER INSERT ON customers
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (action, table_name, record_id)
    VALUES ('INSERT', 'customers', NEW.customer_id);
END //
DELIMITER ;

-- 测试触发器
INSERT INTO customers (customer_name, city) VALUES ('触发器测试用户', '广州');
SELECT * FROM audit_log;

-- 清理测试数据
DELETE FROM customers WHERE customer_name = '触发器测试用户';
DELETE FROM audit_log;
-- 查看指定表的所有触发器
SHOW TRIGGERS WHERE `Table` = '你的表名';

-- 或查看全部触发器
SHOW TRIGGERS;

-- 或从系统表查询
SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE, ACTION_STATEMENT
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE EVENT_OBJECT_SCHEMA = '你的数据库名';

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 创建一个视图 v_product_info
DROP VIEW IF EXISTS v_product_info;
CREATE VIEW v_product_info AS
SELECT
    p.product_name,
    c.category_name,
    p.price
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id;

select * from v_product_info;

-- 题目2（简单）: 使用视图查询价格超过 1000 的商品
SELECT * FROM v_product_info
WHERE price > 1000
ORDER BY price DESC;

-- 题目3（中等）: 创建一个存储过程
DROP PROCEDURE IF EXISTS get_products_by_category;
DELIMITER //
CREATE PROCEDURE get_products_by_category(IN cat_name VARCHAR(50))
BEGIN
    SELECT p.product_name, p.price, p.stock
    FROM products p
    INNER JOIN categories c ON p.category_id = c.category_id
    WHERE c.category_name = cat_name
    ORDER BY p.price;
END //
DELIMITER ;

-- 测试
CALL get_products_by_category('电子产品');

-- 题目4（中等）: 创建一个函数 stock_status
DROP FUNCTION IF EXISTS stock_status;
DELIMITER //
CREATE FUNCTION stock_status(s INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF s <= 50 THEN
        RETURN '库存紧张';
    ELSEIF s <= 200 THEN
        RETURN '库存正常';
    ELSE
        RETURN '库存充足';
    END IF;
END //
DELIMITER ;

-- 测试
SELECT product_name, stock, stock_status(stock) AS 库存状态
FROM products
ORDER BY stock
LIMIT 10;

-- ============================================================
-- 下一章：11_事务与并发控制.sql
-- ============================================================
