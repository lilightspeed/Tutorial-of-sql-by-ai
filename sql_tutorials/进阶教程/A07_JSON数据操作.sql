-- ============================================================
-- 第7章 JSON 数据操作
-- ============================================================
-- 学习目标:
-- - JSON 数据类型
-- - JSON 函数：提取、修改、查询
-- - JSON 索引
-- - JSON 聚合函数
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. JSON 数据类型
-- ============================================================
-- MySQL 5.7+ 支持原生 JSON 类型，可以存储和查询 JSON 文档
-- 语法: CREATE TABLE t (id INT PRIMARY KEY, data JSON);

-- 创建带 JSON 列的表
DROP TABLE IF EXISTS json_demo;
CREATE TABLE json_demo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_data JSON NOT NULL
);

-- 插入 JSON 数据
INSERT INTO json_demo (user_data) VALUES
('{"name": "张三", "age": 25, "hobbies": ["读书", "游泳"]}'),
('{"name": "李四", "age": 30, "hobbies": ["音乐", "旅行", "摄影"]}'),
('{"name": "王五", "age": 28, "hobbies": ["编程"]}');

SELECT * FROM json_demo;

-- ============================================================
-- 2. JSON 提取函数
-- ============================================================
-- +-----------------------------+----------------+---------------------------+
-- | 函数                        | 说明           | 示例                      |
-- +-----------------------------+----------------+---------------------------+
-- | JSON_EXTRACT(json, path)    | 提取值         | JSON_EXTRACT(data,'$.name') |
-- | ->                          | 提取（带引号） | data->'$.name'            |
-- | ->>                         | 提取（不带引号）| data->>'$.name'           |
-- | JSON_KEYS(json)             | 获取所有键     | JSON_KEYS(data)           |
-- | JSON_LENGTH(json)           | 获取长度       | JSON_LENGTH(data)         |
-- +-----------------------------+----------------+---------------------------+

-- JSON_EXTRACT 提取
SELECT
    JSON_EXTRACT(user_data, '$.name') AS name_with_quotes,
    user_data->>'$.name' AS name_clean,
    user_data->>'$.age' AS age,
    user_data->'$.hobbies' AS hobbies
FROM json_demo;

-- 提取数组元素
SELECT
    user_data->>'$.name' AS name,
    user_data->'$.hobbies[0]' AS first_hobby,
    JSON_LENGTH(user_data->'$.hobbies') AS hobby_count
FROM json_demo;

-- JSON_KEYS：获取所有键
SELECT JSON_KEYS(user_data) AS keys FROM json_demo LIMIT 1;

-- ============================================================
-- 3. JSON 查询与过滤
-- ============================================================

-- WHERE 中使用 JSON 提取
SELECT user_data->>'$.name' AS name, user_data->>'$.age' AS age
FROM json_demo
WHERE user_data->>'$.age' > '25';

-- JSON_CONTAINS：检查数组是否包含某值
SELECT user_data->>'$.name' AS name
FROM json_demo
WHERE JSON_CONTAINS(user_data->'$.hobbies', '"读书"');

-- JSON_SEARCH：搜索值
SELECT
    user_data->>'$.name' AS name,
    JSON_SEARCH(user_data, 'one', '旅行') AS found_path
FROM json_demo
WHERE JSON_SEARCH(user_data, 'one', '旅行') IS NOT NULL;

-- ============================================================
-- 4. JSON 修改函数
-- ============================================================
-- +-------------------------------+---------------------------+
-- | 函数                          | 说明                      |
-- +-------------------------------+---------------------------+
-- | JSON_SET(json, path, val)     | 设置值（已存在则更新）    |
-- | JSON_INSERT(json, path, val)  | 插入值（已存在则忽略）    |
-- | JSON_REPLACE(json, path, val) | 替换值（不存在则忽略）    |
-- | JSON_REMOVE(json, path)       | 删除值                    |
-- +-------------------------------+---------------------------+

-- JSON_SET：添加/更新字段
SELECT
    user_data->>'$.name' AS name,
    JSON_SET(user_data, '$.city', '北京') AS updated
FROM json_demo
WHERE id = 1;

-- JSON_ARRAY_APPEND：向数组追加元素
SELECT
    user_data->>'$.name' AS name,
    JSON_ARRAY_APPEND(user_data, '$.hobbies', '游泳') AS updated_hobbies
FROM json_demo
WHERE id = 3;

-- ============================================================
-- 5. JSON 聚合函数
-- ============================================================

-- JSON_ARRAYAGG：将多行聚合为 JSON 数组
SELECT
    category_id,
    JSON_ARRAYAGG(product_name) AS products
FROM products
GROUP BY category_id;

-- JSON_OBJECTAGG：将多行聚合为 JSON 对象
SELECT
    category_id,
    JSON_OBJECTAGG(product_name, price) AS price_map
FROM products
GROUP BY category_id;

-- ============================================================
-- 6. 清理
-- ============================================================

DROP TABLE IF EXISTS json_demo;
SELECT '清理完成' AS result;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: JSON 基本操作
DROP TABLE IF EXISTS json_test;
CREATE TABLE json_test (id INT PRIMARY KEY AUTO_INCREMENT, info JSON);
INSERT INTO json_test (info) VALUES ('{"name": "测试用户", "email": "test@test.com", "address": "北京市"}');

SELECT
    info->>'$.name' AS name,
    info->>'$.email' AS email
FROM json_test;
DROP TABLE IF EXISTS json_test;

-- 题目2（中等）: JSON_ARRAYAGG
SELECT
    c.category_name,
    JSON_ARRAYAGG(p.product_name) AS products
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name;

-- 题目3（中等）: JSON_CONTAINS
DROP TABLE IF EXISTS json_test;
CREATE TABLE json_test (id INT PRIMARY KEY AUTO_INCREMENT, data JSON);
INSERT INTO json_test (data) VALUES ('{"name": "张三", "hobbies": ["读书", "游泳"]}');
INSERT INTO json_test (data) VALUES ('{"name": "李四", "hobbies": ["音乐", "旅行"]}');

SELECT data->>'$.name' AS name
FROM json_test
WHERE JSON_CONTAINS(data->'$.hobbies', '"读书"');
DROP TABLE IF EXISTS json_test;
