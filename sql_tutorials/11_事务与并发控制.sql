-- ============================================================
-- 第11章 事务与并发控制
-- ============================================================
-- 学习目标:
-- - 什么是事务
-- - ACID 四大特性
-- - START TRANSACTION / COMMIT / ROLLBACK
-- - 事务的隔离级别
-- - 锁的概念
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 什么是事务？
-- ============================================================
-- 事务（Transaction）是一组操作，要么全部成功，要么全部失败
--
-- 经典例子：银行转账
-- 张三给李四转账 100 元：
-- 步骤1: 张三账户 -100
-- 步骤2: 李四账户 +100
--
-- 如果步骤1成功，步骤2失败：
-- 钱消失了！
--
-- 使用事务：
-- 两步都成功 → 提交（COMMIT）
-- 任一步失败 → 回滚（ROLLBACK）

-- ============================================================
-- 2. ACID 四大特性
-- ============================================================
-- +----------+----------------+------------------------------------------+
-- | 特性     | 英文           | 说明                                     |
-- +----------+----------------+------------------------------------------+
-- | 原子性   | Atomicity      | 事务中的操作要么全部完成，要么全部不执行 |
-- | 一致性   | Consistency    | 事务前后数据库保持一致状态               |
-- | 隔离性   | Isolation      | 并发事务之间互不干扰                     |
-- | 持久性   | Durability     | 事务提交后，数据永久保存                 |
-- +----------+----------------+------------------------------------------+

-- ============================================================
-- 3. 事务控制语句
-- ============================================================
-- START TRANSACTION;  -- 或 BEGIN;
-- -- 执行 SQL 操作
-- COMMIT;             -- 提交事务（所有操作生效）
-- -- 或
-- ROLLBACK;           -- 回滚事务（所有操作撤销）

-- 创建一个简单的账户表用于演示
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
    id      INT PRIMARY KEY,
    name    VARCHAR(50),
    balance DECIMAL(10, 2)
);

INSERT INTO accounts VALUES (1, '张三', 1000.00);
INSERT INTO accounts VALUES (2, '李四', 500.00);
SELECT * FROM accounts;

-- 3.1 COMMIT — 正常提交
-- 模拟转账：张三 → 李四 转 200 元
START TRANSACTION;

-- 步骤1：张三扣款
UPDATE accounts SET balance = balance - 200 WHERE id = 1;

-- 步骤2：李四收款
UPDATE accounts SET balance = balance + 200 WHERE id = 2;

-- 提交事务
COMMIT;
SELECT '转账成功！' AS result;
SELECT * FROM accounts;

-- 3.2 ROLLBACK — 回滚事务
-- 模拟转账失败并回滚
START TRANSACTION;

-- 步骤1：张三扣款
UPDATE accounts SET balance = balance - 200 WHERE id = 1;

-- 模拟错误：李四ID错误
UPDATE accounts SET balance = balance + 200 WHERE id = 999;

-- 回滚事务（因为 id=999 不存在，实际应用中需要检查）
ROLLBACK;
SELECT '转账失败，已回滚' AS result;
SELECT * FROM accounts;

-- 3.3 SAVEPOINT — 保存点
-- 在事务中设置保存点，可以回滚到指定位置，而不是整个事务
-- 语法: SAVEPOINT 保存点名;
--       ROLLBACK TO 保存点名;

-- 使用保存点
START TRANSACTION;

-- 第1步操作
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
SAVEPOINT step1;

-- 第2步操作（出错）
UPDATE accounts SET balance = balance + 100 WHERE id = 999;

-- 回滚到保存点
ROLLBACK TO step1;

-- 第2步重新执行
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;
SELECT '使用保存点，部分回滚成功' AS result;
SELECT * FROM accounts;

-- ============================================================
-- 4. 隔离级别
-- ============================================================
-- 当多个事务同时执行时，可能出现以下问题:
--
-- +----------------+--------------------------+--------------------------+
-- | 问题           | 说明                     | 例子                     |
-- +----------------+--------------------------+--------------------------+
-- | 脏读           | 读到未提交的数据         | 读到别人还没确认的修改   |
-- | 不可重复读     | 同一事务中两次读取不同   | 两次查余额不一样         |
-- | 幻读           | 同一事务中两次查询行数不同 | 第一次查5条，第二次查6条 |
-- +----------------+--------------------------+--------------------------+
--
-- MySQL 隔离级别:
-- +----------------------+--------+----------------+--------+
-- | 隔离级别             | 脏读   | 不可重复读     | 幻读   |
-- +----------------------+--------+----------------+--------+
-- | READ UNCOMMITTED     | 可能   | 可能           | 可能   |
-- | READ COMMITTED       | 不会   | 可能           | 可能   |
-- | REPEATABLE READ（默认）| 不会 | 不会           | 可能   |
-- | SERIALIZABLE         | 不会   | 不会           | 不会   |
-- +----------------------+--------+----------------+--------+

-- 查看当前隔离级别
SELECT @@transaction_isolation AS 隔离级别;

-- 设置隔离级别
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- ============================================================
-- 5. 锁
-- ============================================================
-- MySQL 使用锁来保证并发安全
--
-- 锁的类型:
-- +----------------+------------------------------------------+
-- | 锁类型         | 说明                                     |
-- +----------------+------------------------------------------+
-- | 共享锁（S锁）  | 读锁，多个事务可以同时读                 |
-- | 排他锁（X锁）  | 写锁，只有一个事务可以写                 |
-- | 表锁           | 锁定整张表                               |
-- | 行锁           | 锁定某一行（InnoDB 支持）                |
-- +----------------+------------------------------------------+
--
-- SELECT ... FOR SHARE;      -- 共享锁
-- SELECT ... FOR UPDATE;     -- 排他锁

-- 清理演示表
DROP TABLE IF EXISTS accounts;
SELECT '演示表已清理' AS result;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 创建 wallet 表并使用事务转账
DROP TABLE IF EXISTS wallet;
CREATE TABLE wallet (
    id      INT PRIMARY KEY,
    name    VARCHAR(50),
    balance DECIMAL(10, 2)
);
INSERT INTO wallet VALUES (1, '张三', 500.00);
INSERT INTO wallet VALUES (2, '李四', 300.00);

-- 使用事务转账
START TRANSACTION;
UPDATE wallet SET balance = balance - 100 WHERE id = 1;
UPDATE wallet SET balance = balance + 100 WHERE id = 2;
COMMIT;
SELECT '转账成功' AS result;
SELECT * FROM wallet;

-- 题目2（中等）: 余额不足时回滚
START TRANSACTION;

-- 检查余额
SELECT @balance := balance FROM wallet WHERE id = 1;

-- 如果余额不足则回滚
-- 注意: 在纯 SQL 中需要使用存储过程或应用程序逻辑来处理条件
-- 这里演示回滚操作
ROLLBACK;
SELECT '余额不足，已回滚' AS result;
SELECT * FROM wallet;

-- 题目3（中等）: 查看隔离级别
SELECT @@transaction_isolation AS 当前隔离级别;

-- 清理
DROP TABLE IF EXISTS wallet;

-- ============================================================
-- 下一章：12_综合实战.sql
-- ============================================================
