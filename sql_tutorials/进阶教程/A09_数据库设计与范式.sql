-- ============================================================
-- 第9章 数据库设计与范式
-- ============================================================
-- 学习目标:
-- - 范式理论（1NF、2NF、3NF、BCNF）
-- - 反范式设计
-- - EAV 模型
-- - 数据库设计实战
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 范式理论
-- ============================================================
-- 范式（Normal Form）是数据库设计的规范化标准
-- 目的是减少数据冗余和避免更新异常

-- 1.1 第一范式（1NF）
-- 规则：每个字段都是原子值，不可再分
--
-- 违反 1NF：
-- | student | hobbies          |
-- | 张三     | 读书, 游泳, 音乐 |
--
-- 符合 1NF：
-- | student | hobby |
-- | 张三     | 读书  |
-- | 张三     | 游泳  |
-- | 张三     | 音乐  |

-- 演示 1NF：拆分多值字段
DROP TABLE IF EXISTS student_hobbies;
CREATE TABLE student_hobbies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50),
    hobby VARCHAR(50)
);

INSERT INTO student_hobbies (student_name, hobby) VALUES ('张三', '读书'), ('张三', '游泳'), ('李四', '音乐');
SELECT * FROM student_hobbies;

-- 1.2 第二范式（2NF）
-- 规则：满足 1NF，且非主键列完全依赖于主键（消除部分依赖）
--
-- 违反 2NF（student_id + course 是联合主键）：
-- | student_id | course | student_name | score |
-- | 1          | 数学   | 张三         | 90    |
-- student_name 只依赖 student_id（部分依赖）
--
-- 符合 2NF（拆分为两张表）：
-- students: student_id → student_name
-- scores: student_id + course → score

-- 1.3 第三范式（3NF）
-- 规则：满足 2NF，且非主键列不传递依赖于主键
--
-- 违反 3NF：
-- | employee_id | department_id | department_name |
-- | 1           | 10            | 技术部          |
-- department_name 依赖 department_id，department_id 依赖 employee_id → 传递依赖
--
-- 符合 3NF（拆分）：
-- employees: employee_id → department_id
-- departments: department_id → department_name

-- 范式总结:
-- +----------+------------------+------------------+
-- | 范式     | 要求             | 解决问题         |
-- +----------+------------------+------------------+
-- | 1NF      | 字段原子性       | 消除多值字段     |
-- | 2NF      | 消除部分依赖     | 拆分联合主键表   |
-- | 3NF      | 消除传递依赖     | 拆分间接依赖     |
-- | BCNF     | 每个决定因素都是候选键 | 更严格的 3NF |
-- +----------+------------------+------------------+

-- ============================================================
-- 2. 反范式设计
-- ============================================================
-- 有时为了查询性能，会故意违反范式，添加冗余字段
--
-- 常见反范式场景:
-- +----------------+---------------------------+
-- | 场景           | 说明                      |
-- +----------------+---------------------------+
-- | 冗余列         | 在订单表中存储客户姓名    |
-- | 派生列         | 存储订单总金额            |
-- | 宽表           | 将多张表合并为一张宽表    |
-- +----------------+---------------------------+

-- 反范式示例：订单表中冗余存储客户姓名
SELECT
    o.order_id,
    c.customer_name,  -- 冗余字段
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
LIMIT 5;

-- ============================================================
-- 3. EAV 模型（Entity-Attribute-Value）
-- ============================================================
-- 一种灵活的数据模型，适用于属性不确定的场景
--
-- 传统方式：
-- | product_id | color | size | weight |
--
-- EAV 方式：
-- | entity_id | attribute | value |
-- | 1         | color     | 红色   |
-- | 1         | size      | XL    |
-- | 1         | weight    | 0.5kg |

-- EAV 模型示例
DROP TABLE IF EXISTS product_attrs;
CREATE TABLE product_attrs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    attr_name VARCHAR(50),
    attr_value VARCHAR(200)
);

INSERT INTO product_attrs (product_id, attr_name, attr_value) VALUES
(1, '颜色', '黑色'),
(1, '重量', '180g'),
(1, '屏幕尺寸', '6.1英寸'),
(2, '颜色', '银色'),
(2, '重量', '1.6kg'),
(2, '内存', '16GB');

SELECT * FROM product_attrs;

-- EAV 转换为传统行列
SELECT
    product_id,
    MAX(CASE WHEN attr_name = '颜色' THEN attr_value END) AS 颜色,
    MAX(CASE WHEN attr_name = '重量' THEN attr_value END) AS 重量,
    MAX(CASE WHEN attr_name = '屏幕尺寸' THEN attr_value END) AS 屏幕尺寸,
    MAX(CASE WHEN attr_name = '内存' THEN attr_value END) AS 内存
FROM product_attrs
GROUP BY product_id;

-- ============================================================
-- 4. 设计原则总结
-- ============================================================
-- +----------------+---------------------------+
-- | 原则           | 说明                      |
-- +----------------+---------------------------+
-- | 适度范式       | OLTP 用 3NF，OLAP 可反范式 |
-- | 主键选择       | 自增整数简单高效          |
-- | 外键约束       | 保证引用完整性            |
-- | 命名规范       | 表名用复数，列名用蛇形命名 |
-- | 预留扩展       | 考虑未来可能的变化        |
-- | 文档化         | 记录设计决策和表结构说明  |
-- +----------------+---------------------------+

-- ============================================================
-- 5. 清理
-- ============================================================

DROP TABLE IF EXISTS student_hobbies;
DROP TABLE IF EXISTS product_attrs;
SELECT '清理完成' AS result;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 1NF 解释
-- 第一范式（1NF）：每个字段必须是原子值，不可再分
-- 违反 1NF 的例子：
-- | 学生 | 爱好          |
-- | 张三 | 读书,游泳,音乐 |  <-- 爱好字段包含多个值
-- 符合 1NF：
-- | 学生 | 爱好 |
-- | 张三 | 读书 |
-- | 张三 | 游泳 |
-- | 张三 | 音乐 |

-- 题目2（中等）: 3NF 设计
DROP TABLE IF EXISTS sc_scores;
DROP TABLE IF EXISTS sc_courses;
DROP TABLE IF EXISTS sc_students;

-- 学生表
CREATE TABLE sc_students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50) NOT NULL
);

-- 课程表
CREATE TABLE sc_courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(50) NOT NULL,
    teacher VARCHAR(50)
);

-- 成绩表（关联表）
CREATE TABLE sc_scores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    score DECIMAL(5,2),
    FOREIGN KEY (student_id) REFERENCES sc_students(student_id),
    FOREIGN KEY (course_id) REFERENCES sc_courses(course_id)
);

-- 插入测试数据
INSERT INTO sc_students (student_name) VALUES ('张三'), ('李四');
INSERT INTO sc_courses (course_name, teacher) VALUES ('数学', '王老师'), ('英语', '李老师');
INSERT INTO sc_scores (student_id, course_id, score) VALUES (1, 1, 95), (1, 2, 88), (2, 1, 78);

-- 查询
SELECT s.student_name, c.course_name, sc.score
FROM sc_scores sc
INNER JOIN sc_students s ON sc.student_id = s.student_id
INNER JOIN sc_courses c ON sc.course_id = c.course_id
ORDER BY s.student_name, c.course_name;

-- 题目3（中等）: EAV 模型
DROP TABLE IF EXISTS eav_products;
DROP TABLE IF EXISTS eav_attrs;
CREATE TABLE eav_products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100)
);
CREATE TABLE eav_attrs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    attr_name VARCHAR(50),
    attr_value VARCHAR(200)
);

INSERT INTO eav_products (product_name) VALUES ('iPhone 15'), ('MacBook Pro');
INSERT INTO eav_attrs (product_id, attr_name, attr_value) VALUES (1,'颜色','黑色'),(1,'存储','256GB'),(2,'颜色','银色'),(2,'内存','16GB');

-- 转换为行列
SELECT
    p.product_name,
    MAX(CASE WHEN a.attr_name = '颜色' THEN a.attr_value END) AS 颜色,
    MAX(CASE WHEN a.attr_name = '存储' THEN a.attr_value END) AS 存储,
    MAX(CASE WHEN a.attr_name = '内存' THEN a.attr_value END) AS 内存
FROM eav_products p
LEFT JOIN eav_attrs a ON p.id = a.product_id
GROUP BY p.id, p.product_name;
