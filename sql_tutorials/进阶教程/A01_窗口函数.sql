-- ============================================================
-- 第1章 窗口函数（Window Functions）
-- ============================================================
-- 学习目标:
-- - 窗口函数的概念和语法
-- - 排名函数：ROW_NUMBER、RANK、DENSE_RANK
-- - 偏移函数：LAG、LEAD
-- - 聚合窗口函数：SUM/AVG/COUNT OVER
-- - 分区和排序：PARTITION BY、ORDER BY
-- - 帧（Frame）定义：ROWS、RANGE
-- ============================================================

-- 使用数据库
USE shop_db;

-- ============================================================
-- 1. 什么是窗口函数？
-- ============================================================
-- 窗口函数在不合并行的前提下，对一组相关行进行计算
-- 与 GROUP BY 不同，窗口函数保留每一行
--
-- 窗口函数 vs 聚合函数:
-- +----------+------------------+------------------+
-- | 特性     | GROUP BY 聚合    | 窗口函数         |
-- +----------+------------------+------------------+
-- | 行数     | 合并为一行       | 保留所有行       |
-- | 语法     | GROUP BY         | OVER()           |
-- | 用途     | 汇总统计         | 排名、累计、对比 |
-- +----------+------------------+------------------+
--
-- 基本语法:
-- 函数名() OVER (
--     [PARTITION BY 分区列]   -- 按什么分组
--     [ORDER BY 排序列]       -- 按什么排序
--     [ROWS/RANGE 帧定义]     -- 窗口范围
-- )

-- ============================================================
-- 2. 排名函数
-- ============================================================
-- +----------------+----------------+------------------+
-- | 函数           | 说明           | 遇到并列时       |
-- +----------------+----------------+------------------+
-- | ROW_NUMBER()   | 连续编号       | 不同编号(1,2,3)  |
-- | RANK()         | 排名           | 同名次跳号(1,1,3)|
-- | DENSE_RANK()   | 排名           | 同名次不跳号(1,1,2)|
-- +----------------+----------------+------------------+

-- ROW_NUMBER：给商品按价格排名
SELECT
    product_name,
    category_id,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS 排名
FROM products;

-- ROW_NUMBER + PARTITION BY：每个分类内按价格排名
SELECT
    product_name,
    category_id,
    price,
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS 分类内排名
FROM products
ORDER BY category_id, 分类内排名;

-- RANK vs DENSE_RANK vs ROW_NUMBER 对比
SELECT
    employee_name,
    department,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num,
    RANK()       OVER (ORDER BY salary DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank_num
FROM employees
ORDER BY salary DESC;

-- 实战：查询每个分类中价格最高的前2个商品
SELECT *
FROM (
    SELECT
        product_name,
        category_id,
        price,
        ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS rn
    FROM products
) ranked
WHERE rn <= 2
ORDER BY category_id, rn;

-- ============================================================
-- 3. 偏移函数：LAG 和 LEAD
-- ============================================================
-- +----------------+------------------+
-- | 函数           | 说明             |
-- +----------------+------------------+
-- | LAG(expr, n)   | 取前第 n 行的值  |
-- | LEAD(expr, n)  | 取后第 n 行的值  |
-- +----------------+------------------+
-- 常用于计算环比、同比等

-- LAG：查看当前订单和上一个订单的金额差异
SELECT
    order_id,
    order_date,
    total_amount AS 当前订单,
    LAG(total_amount, 1) OVER (ORDER BY order_date) AS 上一订单,
    total_amount - LAG(total_amount, 1) OVER (ORDER BY order_date) AS 差异
FROM orders
ORDER BY order_date;

-- LEAD：查看下一个订单的日期
SELECT
    customer_id,
    order_date AS 当前订单日期,
    LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 下一订单日期
FROM orders
ORDER BY customer_id, order_date;

-- ============================================================
-- 4. 聚合窗口函数
-- ============================================================
-- 将 SUM、AVG、COUNT、MIN、MAX 与 OVER() 结合使用
-- 实现累计和滑动聚合

-- 累计求和：每个订单的累计消费金额
SELECT
    order_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (ORDER BY order_date) AS 累计金额
FROM orders
ORDER BY order_date;

-- 分区内累计：每个客户的累计消费
SELECT
    c.customer_name,
    o.order_date,
    o.total_amount,
    SUM(o.total_amount) OVER (
        PARTITION BY o.customer_id
        ORDER BY o.order_date
    ) AS 客户累计消费
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY c.customer_name, o.order_date;

-- 每个客户订单金额与该客户平均订单金额的对比
SELECT
    c.customer_name,
    o.order_date,
    o.total_amount,
    ROUND(AVG(o.total_amount) OVER (PARTITION BY o.customer_id), 2) AS 客户平均订单,
    o.total_amount - ROUND(AVG(o.total_amount) OVER (PARTITION BY o.customer_id), 2) AS 与平均的差异
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY c.customer_name, o.order_date;

-- ============================================================
-- 5. 帧（Frame）定义
-- ============================================================
-- 帧定义了窗口函数计算的精确范围
-- 语法: ROWS BETWEEN 起点 AND 终点
--
-- +-------------------------+--------------------------+
-- | 帧选项                  | 说明                     |
-- +-------------------------+--------------------------+
-- | UNBOUNDED PRECEDING     | 从分区的第一行           |
-- | N PRECEDING             | 前 N 行                  |
-- | CURRENT ROW             | 当前行                   |
-- | N FOLLOWING             | 后 N 行                  |
-- | UNBOUNDED FOLLOWING     | 到分区的最后一行         |
-- +-------------------------+--------------------------+

-- 滑动平均：当前行和前2行的平均值
SELECT
    order_id,
    order_date,
    total_amount,
    ROUND(AVG(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS 滑动3期平均
FROM orders
ORDER BY order_date;

-- 累计最小值和最大值
SELECT
    order_id,
    order_date,
    total_amount,
    MIN(total_amount) OVER (ORDER BY order_date) AS 累计最小金额,
    MAX(total_amount) OVER (ORDER BY order_date) AS 累计最大金额
FROM orders
ORDER BY order_date;

-- ============================================================
-- 6. NTILE — 分桶函数
-- ============================================================
-- NTILE(n) 将数据均匀分成 n 组

-- 将商品按价格分为 4 档
SELECT
    product_name,
    price,
    NTILE(4) OVER (ORDER BY price) AS 价格档位
FROM products
ORDER BY price;

-- ============================================================
-- 7. FIRST_VALUE 和 LAST_VALUE
-- ============================================================
-- 获取窗口中第一行或最后一行的值

-- 每个分类中最贵和最便宜的商品价格
SELECT
    product_name,
    category_id,
    price,
    FIRST_VALUE(price) OVER (
        PARTITION BY category_id ORDER BY price DESC
    ) AS 分类最高价,
    LAST_VALUE(price) OVER (
        PARTITION BY category_id ORDER BY price DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS 分类最低价
FROM products
ORDER BY category_id, price DESC;

-- ============================================================
-- 练习题
-- ============================================================

-- 题目1（简单）: 使用 ROW_NUMBER 给所有员工按工资降序编号
SELECT
    employee_name,
    department,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS 排名
FROM employees
ORDER BY salary DESC;

-- 题目2（简单）: 使用 LAG 查看每个客户相邻两次订单的金额变化
SELECT
    c.customer_name,
    o.order_date,
    o.total_amount AS 当前金额,
    LAG(o.total_amount, 1) OVER (
        PARTITION BY o.customer_id ORDER BY o.order_date
    ) AS 上次金额,
    o.total_amount - LAG(o.total_amount, 1) OVER (
        PARTITION BY o.customer_id ORDER BY o.order_date
    ) AS 变化金额
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY c.customer_name, o.order_date;

-- 题目3（中等）: 查询每个部门工资排名第1的员工
SELECT *
FROM (
    SELECT
        employee_name,
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees
) ranked
WHERE rn = 1
ORDER BY salary DESC;

-- 题目4（中等）: 计算每个订单的累计消费金额（按客户分组）
SELECT
    c.customer_name,
    o.order_date,
    o.total_amount,
    SUM(o.total_amount) OVER (
        PARTITION BY o.customer_id ORDER BY o.order_date
    ) AS 累计消费
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY c.customer_name, o.order_date;

-- 题目5（较难）: 计算每个订单金额与该客户平均订单金额的差异
SELECT
    c.customer_name,
    o.order_date,
    o.total_amount,
    ROUND(AVG(o.total_amount) OVER (PARTITION BY o.customer_id), 2) AS 平均金额,
    CASE
        WHEN o.total_amount > AVG(o.total_amount) OVER (PARTITION BY o.customer_id)
        THEN '高于平均'
        ELSE '低于平均'
    END AS 标记
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY c.customer_name, o.order_date;
