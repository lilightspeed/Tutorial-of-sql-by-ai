-- ============================================================
-- 第8章 存储过程高级特性
-- ============================================================
-- 学习目标:
-- - 游标（Cursor）
-- - 错误处理（Handler）
-- - 动态 SQL（PREPARE/EXECUTE）
-- - 事件调度器（Event Scheduler）
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 游标（Cursor）
-- ============================================================
-- 游标用于逐行处理查询结果
-- 语法:
-- DECLARE cur CURSOR FOR SELECT ...;
-- OPEN cur;
-- FETCH cur INTO 变量;
-- -- 处理数据
-- CLOSE cur;

-- 创建演示表和日志表
DROP TABLE IF EXISTS cursor_log;
CREATE TABLE cursor_log (id INT PRIMARY KEY AUTO_INCREMENT, message VARCHAR(200));

-- 创建使用游标的存储过程
DROP PROCEDURE IF EXISTS process_orders;
DELIMITER //
CREATE PROCEDURE process_orders()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_order_id INT;
    DECLARE v_amount DECIMAL(10,2);
    DECLARE v_status VARCHAR(20);

    DECLARE cur CURSOR FOR
        SELECT order_id, total_amount, status FROM orders;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_order_id, v_amount, v_status;
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO cursor_log (message)
        VALUES (CONCAT('订单 ', v_order_id, ': ', v_amount, '元, 状态: ', v_status));
    END LOOP;

    CLOSE cur;
END //
DELIMITER ;

-- 执行
CALL process_orders();
SELECT * FROM cursor_log;

-- ============================================================
-- 2. 错误处理（Handler）
-- ============================================================
-- 语法: DECLARE handler_type HANDLER FOR condition_value action;
--
-- +----------------+------------------+
-- | handler_type   | 说明             |
-- +----------------+------------------+
-- | CONTINUE       | 继续执行         |
-- | EXIT           | 退出 BEGIN...END |
-- +----------------+------------------+

-- 错误处理示例
DROP PROCEDURE IF EXISTS safe_insert;
DELIMITER //
CREATE PROCEDURE safe_insert(
    IN p_name VARCHAR(50),
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result = '插入失败：发生错误';
        ROLLBACK;
    END;

    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SET p_result = '插入失败：记录已存在';
    END;

    START TRANSACTION;
    INSERT INTO categories (category_name) VALUES (p_name);
    COMMIT;
    SET p_result = '插入成功';
END //
DELIMITER ;

-- 测试
CALL safe_insert('新分类', @result);
SELECT @result;

-- ============================================================
-- 3. 动态 SQL（PREPARE / EXECUTE）
-- ============================================================
-- 在运行时动态构建和执行 SQL

-- 动态 SQL 示例
DROP PROCEDURE IF EXISTS dynamic_query;
DELIMITER //
CREATE PROCEDURE dynamic_query(
    IN p_table VARCHAR(50),
    IN p_column VARCHAR(50),
    IN p_value VARCHAR(100)
)
BEGIN
    SET @sql = CONCAT('SELECT * FROM ', p_table, ' WHERE ', p_column, ' = ?');
    SET @val = p_value;
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING @val;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- 调用
CALL dynamic_query('customers', 'city', '北京');

-- ============================================================
-- 4. 事件调度器（Event Scheduler）
-- ============================================================
-- 定时执行 SQL 任务，类似于 Linux 的 cron
-- 语法:
-- CREATE EVENT event_name
-- ON SCHEDULE EVERY 1 HOUR
-- DO
--     SQL 语句;

-- 查看事件调度器状态
SHOW VARIABLES LIKE 'event_scheduler';

-- 创建事件：每天清理30天前的日志
DROP EVENT IF EXISTS cleanup_old_logs;
CREATE EVENT cleanup_old_logs
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
    DELETE FROM cursor_log WHERE id > 0;

-- 查看事件
SHOW EVENTS FROM shop_db;

-- ============================================================
-- 5. 清理
-- ============================================================

DROP EVENT IF EXISTS cleanup_old_logs;
DROP PROCEDURE IF EXISTS process_orders;
DROP PROCEDURE IF EXISTS safe_insert;
DROP PROCEDURE IF EXISTS dynamic_query;
DROP TABLE IF EXISTS cursor_log;
SELECT '清理完成' AS result;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 游标计算工资总和
DROP PROCEDURE IF EXISTS calc_salary_sum;
DELIMITER //
CREATE PROCEDURE calc_salary_sum(OUT total DECIMAL(12,2))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_salary DECIMAL(10,2);
    DECLARE cur CURSOR FOR SELECT salary FROM employees;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET total = 0;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_salary;
        IF done THEN LEAVE read_loop; END IF;
        SET total = total + v_salary;
    END LOOP;
    CLOSE cur;
END //
DELIMITER ;

CALL calc_salary_sum(@total);
SELECT @total AS 工资总和;

-- 题目2（中等）: 动态排序
DROP PROCEDURE IF EXISTS dynamic_sort;
DELIMITER //
CREATE PROCEDURE dynamic_sort(
    IN p_table VARCHAR(50),
    IN p_order_col VARCHAR(50)
)
BEGIN
    SET @sql = CONCAT('SELECT * FROM ', p_table, ' ORDER BY ', p_order_col);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

CALL dynamic_sort('employees', 'salary DESC');
