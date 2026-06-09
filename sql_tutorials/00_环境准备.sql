-- ============================================================
-- 第0章 环境准备
-- ============================================================
-- 在开始学习 SQL 之前，我们需要先准备好开发环境。
-- 本章将指导你完成以下步骤：
-- 1. 安装 MySQL 数据库
-- 2. 安装 Python 和必要的库
-- 3. 创建示例数据库
-- 4. 在 Jupyter Notebook 中连接 MySQL
-- ============================================================

-- ============================================================
-- 1. 安装 MySQL
-- ============================================================
-- Windows 用户:
--   1. 访问 https://dev.mysql.com/downloads/installer/
--   2. 下载 MySQL Installer（推荐下载较大的完整安装包）
--   3. 运行安装程序，选择 Developer Default 或 Server only
--   4. 设置 root 用户密码（请牢记！）
--   5. 完成安装
--
-- macOS 用户:
--   brew install mysql
--   brew services start mysql
--
-- Linux (Ubuntu) 用户:
--   sudo apt update
--   sudo apt install mysql-server
--   sudo systemctl start mysql
--   sudo systemctl enable mysql
--
-- 验证安装:
--   mysql --version
-- ============================================================

-- ============================================================
-- 2. 创建示例数据库
-- ============================================================
-- 本教程使用示例数据库 shop_db，这是一个简化的电商系统

-- 创建数据库
CREATE DATABASE IF NOT EXISTS shop_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE shop_db;

-- ============================================================
-- 3. 示例数据库结构
-- ============================================================
-- shop_db 包含以下 6 张表：
--
-- +---------------+     +---------------+     +----------------+
-- | categories    |     | products      |     | order_items    |
-- |---------------|     |---------------|     |----------------|
-- | category_id   |<----| category_id   |     | item_id        |
-- | category_name |     | product_id    |<----| product_id     |
-- | description   |     | product_name  |     | order_id       |
-- +---------------+     | price         |     | quantity       |
--                       | stock         |     | unit_price     |
--                       +---------------+     +----------------+
--                                                     |
--                       +---------------+             |
--                       | orders        |<------------+
--                       |---------------|
--                       | order_id      |
--                       | customer_id   |<----+
--                       | employee_id   |<-+  |
--                       | order_date    |  |  |
--                       | status        |  |  |
--                       | total_amount  |  |  |
--                       +---------------+  |  |
--                                          |  |
-- +---------------+     +---------------+  |  |
-- | customers     |     | employees     |  |  |
-- |---------------|     |---------------|  |  |
-- | customer_id   |---->| employee_id   |--+  |
-- | customer_name |     | employee_name |     |
-- | email         |     | department    |     |
-- | phone         |     | salary        |     |
-- | city          |     | hire_date     |     |
-- +---------------+     | manager_id    |     |
--                       +---------------+     |
--                                             |
-- 各表字段说明:
-- +-------------+--------------+------------------------------------------+
-- | 表名        | 说明         | 主要字段                                 |
-- +-------------+--------------+------------------------------------------+
-- | categories  | 商品分类     | category_id, category_name, description  |
-- | products    | 商品信息     | product_id, product_name, category_id,   |
-- |             |              | price, stock                             |
-- | customers   | 客户信息     | customer_id, customer_name, email,       |
-- |             |              | phone, city                              |
-- | employees   | 员工信息     | employee_id, employee_name, department,  |
-- |             |              | salary, hire_date                        |
-- | orders      | 订单信息     | order_id, customer_id, employee_id,      |
-- |             |              | order_date, status, total_amount         |
-- | order_items | 订单明细     | item_id, order_id, product_id,           |
-- |             |              | quantity, unit_price                     |
-- +-------------+--------------+------------------------------------------+

-- ============================================================
-- 4. 测试查询
-- ============================================================
-- 验证数据库连接和表结构

-- 查看所有表
SHOW TABLES;

-- 查看商品表的数据
SELECT * FROM products LIMIT 5;

-- 查看各表的记录数
SELECT 'categories' AS table_name, COUNT(*) AS record_count FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;

-- ============================================================
-- 5. 常见问题
-- ============================================================
-- Q: 连接数据库时报错 Access denied
-- A: 检查用户名和密码是否正确。如果忘记 root 密码，可以重置：
--    sudo mysql_secure_installation
--
-- Q: 报错 Can't connect to MySQL server
-- A: 检查 MySQL 服务是否已启动：
--    Windows: net start mysql
--    macOS:   brew services start mysql
--    Linux:   sudo systemctl start mysql
--
-- Q: 中文显示乱码
-- A: 确保连接时指定了 charset=utf8mb4
-- ============================================================

-- ============================================================
-- 环境检查清单
-- ============================================================
-- [x] MySQL 已安装并启动
-- [x] 示例数据库 shop_db 已创建
-- [x] 能成功执行 SELECT 1
--
-- 全部完成后，我们就可以开始学习 SQL 了！
--
-- 下一章：01_数据库基础概念.sql
-- ============================================================
