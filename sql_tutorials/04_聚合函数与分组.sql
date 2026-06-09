-- ============================================================
-- 第4章 聚合函数与分组
-- ============================================================
-- 学习目标:
-- - COUNT、SUM、AVG、MIN、MAX 五大聚合函数
-- - GROUP BY 分组统计
-- - HAVING 过滤分组结果
-- - 聚合函数与 WHERE 的配合使用
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 聚合函数
-- ============================================================
-- 聚合函数对一组值进行计算，返回单个结果
--
-- +----------+----------------+---------------------------+
-- | 函数     | 说明           | 示例                      |
-- +----------+----------------+---------------------------+
-- | COUNT()  | 计数           | COUNT(*) 统计行数         |
-- | SUM()    | 求和           | SUM(price) 价格总和       |
-- | AVG()    | 平均值         | AVG(price) 平均价格       |
-- | MIN()    | 最小值         | MIN(price) 最低价格       |
-- | MAX()    | 最大值         | MAX(price) 最高价格       |
-- +----------+----------------+---------------------------+

-- ============================================================
-- 1.1 COUNT — 计数
-- ============================================================

-- 统计客户总数
SELECT COUNT(*) AS 客户总数 FROM customers;

-- 统计有邮箱的客户数量（NULL 不计入）
SELECT COUNT(email) AS 有邮箱的客户数 FROM customers;

-- 统计不同城市的数量
SELECT COUNT(DISTINCT city) AS 城市数量 FROM customers;

-- ============================================================
-- 1.2 SUM — 求和
-- ============================================================

-- 计算所有订单的总金额
SELECT SUM(total_amount) AS 订单总金额 FROM orders;

-- 计算商品的总库存
SELECT SUM(stock) AS 总库存 FROM products;

-- ============================================================
-- 1.3 AVG — 平均值
-- ============================================================

-- 计算商品的平均价格
SELECT ROUND(AVG(price), 2) AS 平均价格 FROM products;

-- 计算员工的平均工资
SELECT ROUND(AVG(salary), 2) AS 平均工资 FROM employees;

-- ============================================================
-- 1.4 MIN / MAX — 最小值 / 最大值
-- ============================================================

-- 查询价格最高和最低的商品
SELECT
    MIN(price) AS 最低价格,
    MAX(price) AS 最高价格,
    MAX(price) - MIN(price) AS 价格差距
FROM products;

-- 查询工资最高和最低的员工
SELECT
    MIN(salary) AS 最低工资,
    MAX(salary) AS 最高工资
FROM employees;

-- ============================================================
-- 1.5 多个聚合函数一起使用
-- ============================================================

-- 商品价格统计汇总
SELECT
    COUNT(*) AS 商品数量,
    ROUND(AVG(price), 2) AS 平均价格,
    MIN(price) AS 最低价格,
    MAX(price) AS 最高价格,
    SUM(stock) AS 总库存
FROM products;

-- ============================================================
-- 2. GROUP BY 分组
-- ============================================================
-- GROUP BY 将数据按指定列分组，然后对每组应用聚合函数
-- 语法: SELECT 列名, 聚合函数(列名) FROM 表名 GROUP BY 列名;
--
-- 执行顺序:
-- 1. FROM      → 确定表
-- 2. WHERE     → 过滤行
-- 3. GROUP BY  → 分组
-- 4. 聚合函数  → 对每组计算
-- 5. SELECT    → 输出结果

-- 统计每个城市的客户数量
SELECT
    city AS 城市,
    COUNT(*) AS 客户数量
FROM customers
GROUP BY city
ORDER BY 客户数量 DESC;

-- 统计每个分类的商品数量
SELECT
    category_id AS 分类ID,
    COUNT(*) AS 商品数量,
    ROUND(AVG(price), 2) AS 平均价格
FROM products
GROUP BY category_id;

-- 统计每个部门的员工数和平均工资
SELECT
    department AS 部门,
    COUNT(*) AS 员工数,
    ROUND(AVG(salary), 2) AS 平均工资,
    MAX(salary) AS 最高工资
FROM employees
GROUP BY department
ORDER BY 平均工资 DESC;

-- 统计每个客户的订单数和总消费
SELECT
    customer_id AS 客户ID,
    COUNT(*) AS 订单数,
    SUM(total_amount) AS 总消费
FROM orders
GROUP BY customer_id
ORDER BY 总消费 DESC;

-- ============================================================
-- 3. HAVING — 过滤分组
-- ============================================================
-- WHERE 过滤行，HAVING 过滤分组
-- 语法:
-- SELECT 列名, 聚合函数(列名)
-- FROM 表名
-- WHERE 条件        -- 先过滤行
-- GROUP BY 列名     -- 再分组
-- HAVING 分组条件;   -- 最后过滤分组
--
-- WHERE vs HAVING:
-- +--------------+----------------+----------------+
-- |              | WHERE          | HAVING         |
-- +--------------+----------------+----------------+
-- | 作用对象     | 行             | 分组           |
-- | 执行时机     | 分组前         | 分组后         |
-- | 能否用聚合函数 | 不能         | 可以           |
-- +--------------+----------------+----------------+

-- 查询有 2 个以上客户的城市
SELECT
    city AS 城市,
    COUNT(*) AS 客户数量
FROM customers
GROUP BY city
HAVING COUNT(*) >= 2
ORDER BY 客户数量 DESC;

-- 查询平均工资超过 15000 的部门
SELECT
    department AS 部门,
    COUNT(*) AS 员工数,
    ROUND(AVG(salary), 2) AS 平均工资
FROM employees
GROUP BY department
HAVING AVG(salary) > 15000;

-- 查询总消费超过 3000 的客户
SELECT
    customer_id AS 客户ID,
    COUNT(*) AS 订单数,
    SUM(total_amount) AS 总消费
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > 3000
ORDER BY 总消费 DESC;

-- ============================================================
-- 4. 综合示例
-- ============================================================

-- 统计每个分类：商品数 > 3 且平均价格 > 100 的分类
SELECT
    category_id AS 分类ID,
    COUNT(*) AS 商品数量,
    ROUND(AVG(price), 2) AS 平均价格,
    SUM(stock) AS 总库存
FROM products
GROUP BY category_id
HAVING COUNT(*) > 3 AND AVG(price) > 100
ORDER BY 平均价格 DESC;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 统计商品表中一共有多少种商品
SELECT COUNT(*) AS 商品总数 FROM products;

-- 题目2（简单）: 计算所有已完成订单的总金额
SELECT SUM(total_amount) AS 已完成订单总金额 FROM orders WHERE status = '已完成';

-- 题目3（中等）: 统计每个部门的员工人数
SELECT department AS 部门, COUNT(*) AS 员工人数
FROM employees
GROUP BY department
ORDER BY 员工人数 DESC;

-- 题目4（中等）: 查询订单数量超过 2 个的客户ID及其订单数量
SELECT customer_id AS 客户ID, COUNT(*) AS 订单数量
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 2
ORDER BY 订单数量 DESC;

-- 题目5（较难）: 查询平均商品价格超过 500 元的分类
SELECT
    category_id AS 分类ID,
    COUNT(*) AS 商品数量,
    ROUND(AVG(price), 2) AS 平均价格
FROM products
GROUP BY category_id
HAVING AVG(price) > 500
ORDER BY 平均价格 DESC;

-- ============================================================
-- 下一章：05_多表连接查询.sql
-- ============================================================
