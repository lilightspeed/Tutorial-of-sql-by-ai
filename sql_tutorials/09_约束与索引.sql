-- ============================================================
-- 第9章 约束与索引
-- ============================================================
-- 学习目标:
-- - PRIMARY KEY 主键约束
-- - FOREIGN KEY 外键约束
-- - UNIQUE 唯一约束
-- - NOT NULL 非空约束
-- - CHECK 检查约束
-- - DEFAULT 默认值
-- - INDEX 索引
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 约束概述
-- ============================================================
-- 约束用于保证数据的完整性和准确性
--
-- +----------------+------------------------------------------+
-- | 约束           | 说明                                     |
-- +----------------+------------------------------------------+
-- | PRIMARY KEY    | 主键，唯一标识每条记录                   |
-- | FOREIGN KEY    | 外键，建立表间关联                       |
-- | UNIQUE         | 值不能重复                               |
-- | NOT NULL       | 值不能为空                               |
-- | CHECK          | 值必须满足指定条件                       |
-- | DEFAULT        | 未指定值时使用默认值                     |
-- +----------------+------------------------------------------+

-- ============================================================
-- 2. PRIMARY KEY — 主键
-- ============================================================
-- 唯一标识表中的每条记录，自动包含 NOT NULL 和 UNIQUE

-- 创建带主键的表
DROP TABLE IF EXISTS demo_pk;
CREATE TABLE demo_pk (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

-- 正常插入
INSERT INTO demo_pk (name) VALUES ('张三');

-- 尝试插入重复主键会报错
-- INSERT INTO demo_pk (id, name) VALUES (1, '李四');
-- 错误: Duplicate entry '1' for key 'PRIMARY'

SELECT * FROM demo_pk;

-- ============================================================
-- 3. FOREIGN KEY — 外键
-- ============================================================
-- 确保引用完整性：外键值必须在被引用表中存在
-- 语法: FOREIGN KEY (本表列) REFERENCES 其他表(其他表列)

-- 外键约束示例：尝试插入一个不存在的 category_id
-- INSERT INTO products (product_name, category_id, price, stock)
-- VALUES ('测试商品', 999, 100.00, 10);
-- 错误: Cannot add or update a child row: a foreign key constraint fails

-- 正常插入（category_id=1 存在于 categories 表中）
INSERT INTO products (product_name, category_id, price, stock)
VALUES ('外键测试商品', 1, 100.00, 10);
SELECT '插入成功' AS result;

-- 清理
DELETE FROM products WHERE product_name = '外键测试商品';

-- ============================================================
-- 4. UNIQUE — 唯一约束
-- ============================================================
-- 确保列中的值不重复（但允许 NULL）

-- 创建带 UNIQUE 约束的表
DROP TABLE IF EXISTS demo_unique;
CREATE TABLE demo_unique (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE,
    name VARCHAR(50)
);

-- 插入第一条
INSERT INTO demo_unique (email, name) VALUES ('test@email.com', '张三');

-- 尝试插入相同 email
-- INSERT INTO demo_unique (email, name) VALUES ('test@email.com', '李四');
-- 错误: Duplicate entry 'test@email.com' for key 'email'

SELECT * FROM demo_unique;

-- ============================================================
-- 5. NOT NULL — 非空约束
-- ============================================================
-- 确保列不能存储 NULL 值

-- 创建带 NOT NULL 约束的表
DROP TABLE IF EXISTS demo_notnull;
CREATE TABLE demo_notnull (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- 尝试插入 name 为 NULL
-- INSERT INTO demo_notnull (id) VALUES (1);
-- 错误: Column 'name' cannot be null

-- ============================================================
-- 6. CHECK — 检查约束
-- ============================================================
-- 确保列值满足指定条件（MySQL 8.0.16+ 支持）

-- 创建带 CHECK 约束的表
DROP TABLE IF EXISTS demo_check;
CREATE TABLE demo_check (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    price DECIMAL(10,2) CHECK (price > 0),
    stock INT CHECK (stock >= 0)
);

-- 尝试插入价格为负数
-- INSERT INTO demo_check (product_name, price, stock) VALUES ('测试', -10, 5);
-- 错误: Check constraint 'demo_check_chk_1' is violated

-- 正常插入
INSERT INTO demo_check (product_name, price, stock) VALUES ('测试', 99.00, 10);
SELECT * FROM demo_check;

-- ============================================================
-- 7. DEFAULT — 默认值
-- ============================================================
-- 未指定值时自动使用默认值

-- 创建带默认值的表
DROP TABLE IF EXISTS demo_default;
CREATE TABLE demo_default (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    status VARCHAR(20) DEFAULT '活跃',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 不指定 status 和 created_at
INSERT INTO demo_default (name) VALUES ('张三');
SELECT * FROM demo_default;

-- ============================================================
-- 8. INDEX — 索引
-- ============================================================
-- 索引可以加速查询，类似于书的目录
--
-- 创建索引:
-- CREATE INDEX 索引名 ON 表名(列名);
-- CREATE UNIQUE INDEX 索引名 ON 表名(列名);  -- 唯一索引

-- 为 products 表的 product_name 创建索引
CREATE INDEX idx_product_name ON products(product_name);
SELECT '索引创建成功' AS result;

-- 查看表的索引
SHOW INDEX FROM products;

-- 删除索引
DROP INDEX idx_product_name ON products;
SELECT '索引已删除' AS result;

-- 索引使用建议:
-- +---------------------------+------------------+
-- | 场景                      | 建议             |
-- +---------------------------+------------------+
-- | WHERE 条件常用列          | 创建索引         |
-- | JOIN 连接列               | 创建索引         |
-- | ORDER BY 排序列           | 创建索引         |
-- | 频繁更新的列              | 谨慎创建         |
-- | 数据量小的表              | 不需要           |
-- | 区分度低的列（如性别）    | 效果差           |
-- +---------------------------+------------------+

-- ============================================================
-- 9. 综合示例
-- ============================================================
-- 创建一个完整的表，包含所有约束

DROP TABLE IF EXISTS demo_full;
CREATE TABLE demo_full (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    email       VARCHAR(100) NOT NULL UNIQUE,
    age         INT          CHECK (age BETWEEN 0 AND 150),
    status      VARCHAR(20)  DEFAULT '活跃',
    created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
);

-- 测试
INSERT INTO demo_full (username, email, age) VALUES ('user1', 'user1@test.com', 25);
INSERT INTO demo_full (username, email) VALUES ('user2', 'user2@test.com');  -- age=NULL, status='活跃'
SELECT * FROM demo_full;

-- 清理演示表
DROP TABLE IF EXISTS demo_pk;
DROP TABLE IF EXISTS demo_unique;
DROP TABLE IF EXISTS demo_notnull;
DROP TABLE IF EXISTS demo_check;
DROP TABLE IF EXISTS demo_default;
DROP TABLE IF EXISTS demo_full;
SELECT '所有演示表已清理' AS result;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 创建一个 teachers 表
DROP TABLE IF EXISTS teachers;
CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(50) NOT NULL,
    email      VARCHAR(100) UNIQUE,
    department VARCHAR(50) DEFAULT '未分配'
);
SELECT 'teachers 表创建成功' AS result;

-- 题目2（简单）: 插入数据并验证约束
INSERT INTO teachers (name, email) VALUES ('王老师', 'wang@school.com');
INSERT INTO teachers (name, email, department) VALUES ('李老师', 'li@school.com', '数学系');
SELECT * FROM teachers;

-- 题目3（中等）: 创建一个 scores 表
DROP TABLE IF EXISTS scores;
CREATE TABLE scores (
    id           INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50) NOT NULL,
    score        DECIMAL(5,2) CHECK (score BETWEEN 0 AND 100),
    grade        VARCHAR(20) DEFAULT '未评定'
);

-- 测试
INSERT INTO scores (student_name, score, grade) VALUES ('张三', 95.5, '优秀');
INSERT INTO scores (student_name, score) VALUES ('李四', 82.0);
SELECT * FROM scores;

-- 题目4（中等）: 创建索引
CREATE INDEX idx_teacher_name ON teachers(name);
SHOW INDEX FROM teachers;

-- 题目5（简单）: 清理
DROP TABLE IF EXISTS teachers;
DROP TABLE IF EXISTS scores;
SELECT '练习表已清理' AS result;

-- ============================================================
-- 下一章：10_视图与存储过程.sql
-- ============================================================
