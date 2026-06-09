-- ============================================================
-- 第8章 数据定义 — DDL
-- ============================================================
-- 学习目标:
-- - CREATE TABLE 创建表
-- - ALTER TABLE 修改表结构
-- - DROP TABLE 删除表
-- - MySQL 常用数据类型详解
-- - 临时表
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. CREATE TABLE — 创建表
-- ============================================================
-- 语法:
-- CREATE TABLE 表名 (
--     列名1 数据类型 [约束],
--     列名2 数据类型 [约束],
--     ...
-- );

-- 创建一个学生表
CREATE TABLE IF NOT EXISTS students (
    student_id   INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50) NOT NULL,
    gender       CHAR(1) DEFAULT '男',
    age          INT,
    email        VARCHAR(100),
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 查看表结构
DESCRIBE students;

-- ============================================================
-- 2. MySQL 数据类型详解
-- ============================================================

-- 2.1 数值类型
-- +----------+----------+--------------------+------------------+
-- | 类型     | 字节数   | 范围               | 用途             |
-- +----------+----------+--------------------+------------------+
-- | TINYINT  | 1        | -128 ~ 127         | 小整数           |
-- | SMALLINT | 2        | -32768 ~ 32767     | 中等整数         |
-- | INT      | 4        | -21亿 ~ 21亿       | 常用整数         |
-- | BIGINT   | 8        | 极大               | 超大整数         |
-- | FLOAT    | 4        | 单精度             | 浮点数（不精确） |
-- | DOUBLE   | 8        | 双精度             | 浮点数（不精确） |
-- | DECIMAL  | 可变     | 精确               | 金额等精确计算   |
-- +----------+----------+--------------------+------------------+

-- 2.2 字符串类型
-- +------------+------------+----------------+------------------+
-- | 类型       | 最大长度   | 特点           | 用途             |
-- +------------+------------+----------------+------------------+
-- | CHAR(N)    | 255字节    | 固定长度       | 性别、状态码     |
-- | VARCHAR(N) | 65535字节  | 可变长度       | 姓名、邮箱       |
-- | TEXT       | 65535字节  | 长文本         | 文章内容         |
-- | MEDIUMTEXT | 16MB       | 中等文本       | 长文章           |
-- | LONGTEXT   | 4GB        | 超长文本       | 极大文本         |
-- +------------+------------+----------------+------------------+

-- 2.3 日期时间类型
-- +------------+------------------------+------------------+
-- | 类型       | 格式                   | 用途             |
-- +------------+------------------------+------------------+
-- | DATE       | YYYY-MM-DD             | 日期             |
-- | TIME       | HH:MM:SS               | 时间             |
-- | DATETIME   | YYYY-MM-DD HH:MM:SS    | 日期时间         |
-- | TIMESTAMP  | 自动                   | 时间戳           |
-- | YEAR       | YYYY                   | 年份             |
-- +------------+------------------------+------------------+

-- ============================================================
-- 3. ALTER TABLE — 修改表结构
-- ============================================================

-- 3.1 添加列
-- 语法: ALTER TABLE 表名 ADD 列名 数据类型 [约束];

-- 给学生表添加手机号列
ALTER TABLE students ADD phone VARCHAR(20);
DESCRIBE students;

-- 3.2 修改列
-- 语法: ALTER TABLE 表名 MODIFY 列名 新数据类型 [新约束];

-- 修改 phone 列的长度
ALTER TABLE students MODIFY phone VARCHAR(30);
DESCRIBE students;

-- 3.3 删除列
-- 语法: ALTER TABLE 表名 DROP COLUMN 列名;

-- 删除 phone 列
ALTER TABLE students DROP COLUMN phone;
DESCRIBE students;

-- 3.4 重命名列
-- 语法: ALTER TABLE 表名 CHANGE 旧列名 新列名 数据类型;

-- 将 student_name 重命名为 name
ALTER TABLE students CHANGE student_name name VARCHAR(50) NOT NULL;
DESCRIBE students;

-- ============================================================
-- 4. DROP TABLE — 删除表
-- ============================================================
-- 语法: DROP TABLE 表名;            -- 删除表（如果不存在会报错）
--       DROP TABLE IF EXISTS 表名;  -- 安全删除（不存在也不报错）

-- 删除学生表
DROP TABLE IF EXISTS students;

-- 确认删除
SHOW TABLES;

-- ============================================================
-- 5. 重命名表
-- ============================================================
-- 语法: RENAME TABLE 旧表名 TO 新表名;

-- 重新创建学生表用于演示
CREATE TABLE IF NOT EXISTS students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50) NOT NULL,
    age INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 重命名
RENAME TABLE students TO pupils;
SHOW TABLES LIKE 'pu%';

-- 清理
DROP TABLE IF EXISTS pupils;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 创建一个 books 表
CREATE TABLE IF NOT EXISTS books (
    book_id      INT PRIMARY KEY AUTO_INCREMENT,
    title        VARCHAR(100) NOT NULL,
    author       VARCHAR(50),
    price        DECIMAL(10, 2),
    publish_date DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 题目2（简单）: 给 books 表添加一个 isbn 列
ALTER TABLE books ADD isbn VARCHAR(20);
DESCRIBE books;

-- 题目3（中等）: 修改 books 表的 price 列
ALTER TABLE books MODIFY price DECIMAL(8, 2) DEFAULT 0.00;
DESCRIBE books;

-- 题目4（中等）: 向 books 表插入测试数据
INSERT INTO books (title, author, price, publish_date, isbn)
VALUES
    ('SQL入门教程', '张老师', 59.90, '2024-01-15', '978-1234567890'),
    ('Python编程指南', '李老师', 79.00, '2024-03-20', '978-0987654321');
SELECT * FROM books;

-- 题目5（简单）: 删除 books 表
DROP TABLE IF EXISTS books;

-- ============================================================
-- 下一章：09_约束与索引.sql
-- ============================================================
