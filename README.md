# 📚 SQL 入门教程 —— 从零开始学数据库

> 面向初学者的系统化 SQL 教程，基于 MySQL，采用 Jupyter Notebook 交互式学习

## 🎯 教程特色

- **循序渐进**：从基础概念到高级特性，由浅入深
- **动手实践**：每个章节都有可运行的代码示例
- **配套练习**：每章附带练习题和参考答案，巩固所学
- **完整案例**：使用电商数据库贯穿全教程，贴近真实场景

## 📋 目录

### 基础篇

| 章节 | 文件 | 内容概要 |
|------|------|----------|
| 准备篇 | [00_环境准备.ipynb](00_环境准备.ipynb) | 安装 MySQL、Python 环境配置、创建示例数据库 |
| 第1章 | [01_数据库基础概念.ipynb](01_数据库基础概念.ipynb) | 数据库、表、行、列、主键、外键、ER 图 |
| 第2章 | [02_基本查询_SELECT.ipynb](02_基本查询_SELECT.ipynb) | SELECT、FROM、WHERE、DISTINCT、LIMIT |
| 第3章 | [03_排序与过滤.ipynb](03_排序与过滤.ipynb) | ORDER BY、AND/OR/NOT、IN、BETWEEN、LIKE、IS NULL |
| 第4章 | [04_聚合函数与分组.ipynb](04_聚合函数与分组.ipynb) | COUNT、SUM、AVG、MIN、MAX、GROUP BY、HAVING |
| 第5章 | [05_多表连接查询.ipynb](05_多表连接查询.ipynb) | INNER JOIN、LEFT JOIN、RIGHT JOIN、自连接 |
| 第6章 | [06_子查询.ipynb](06_子查询.ipynb) | 标量子查询、IN 子查询、EXISTS、关联子查询 |
| 第7章 | [07_数据操作_DML.ipynb](07_数据操作_DML.ipynb) | INSERT、UPDATE、DELETE、批量操作 |
| 第8章 | [08_数据定义_DDL.ipynb](08_数据定义_DDL.ipynb) | CREATE TABLE、ALTER TABLE、数据类型 |
| 第9章 | [09_约束与索引.ipynb](09_约束与索引.ipynb) | PRIMARY KEY、FOREIGN KEY、UNIQUE、CHECK、INDEX |
| 第10章 | [10_视图与存储过程.ipynb](10_视图与存储过程.ipynb) | VIEW、存储过程、函数、触发器 |
| 第11章 | [11_事务与并发控制.ipynb](11_事务与并发控制.ipynb) | ACID、事务控制、隔离级别 |
| 第12章 | [12_综合实战.ipynb](12_综合实战.ipynb) | 综合练习题、真实场景分析 |

### 进阶篇

| 章节 | 文件 | 内容概要 |
|------|------|----------|
| 进阶1 | [进阶教程/A01_窗口函数.ipynb](进阶教程/A01_窗口函数.ipynb) | ROW_NUMBER、RANK、DENSE_RANK、LAG/LEAD |
| 进阶2 | [进阶教程/A02_CTE公用表表达式.ipynb](进阶教程/A02_CTE公用表表达式.ipynb) | WITH 子句、递归 CTE |
| 进阶3 | [进阶教程/A03_高级JOIN技巧.ipynb](进阶教程/A03_高级JOIN技巧.ipynb) | CROSS JOIN、自连接、UNION |
| 进阶4 | [进阶教程/A04_高级子查询.ipynb](进阶教程/A04_高级子查询.ipynb) | 派生表、相关子查询优化 |
| 进阶5 | [进阶教程/A05_性能优化与执行计划.ipynb](进阶教程/A05_性能优化与执行计划.ipynb) | EXPLAIN、索引优化、慢查询分析 |
| 进阶6 | [进阶教程/A06_高级数据操作.ipynb](进阶教程/A06_高级数据操作.ipynb) | INSERT INTO SELECT、MERGE、批量操作 |
| 进阶7 | [进阶教程/A07_JSON数据操作.ipynb](进阶教程/A07_JSON数据操作.ipynb) | JSON 函数、JSON 字段查询 |
| 进阶8 | [进阶教程/A08_存储过程高级特性.ipynb](进阶教程/A08_存储过程高级特性.ipynb) | 游标、异常处理、动态 SQL |
| 进阶9 | [进阶教程/A09_数据库设计与范式.ipynb](进阶教程/A09_数据库设计与范式.ipynb) | 三大范式、反范式设计、ER 建模 |
| 进阶10 | [进阶教程/A10_综合实战.ipynb](进阶教程/A10_综合实战.ipynb) | 进阶综合练习、真实场景分析 |

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/lilightspeed/Tutorial-of-sql-by-ai.git
cd Tutorial-of-sql-by-ai
```

### 2. 创建 conda 环境并安装依赖

```bash
conda create -n learn python=3.13
conda activate learn
pip install pymysql pandas python-dotenv jupyter
```

### 3. 配置数据库密码

在项目根目录创建 `.env` 文件，写入你的 MySQL 密码：

```
MYSQL_PASSWORD=你的MySQL密码
```

> ⚠️ `.env` 文件已被 `.gitignore` 忽略，不会被提交到 Git。

### 4. 初始化示例数据库

```bash
python setup_database.py
```

该脚本会创建 `shop_db` 数据库，并填充示例数据（商品、客户、订单等）。

### 5. 启动 Jupyter

```bash
jupyter notebook
```

然后按照目录顺序依次学习各章节。

## 📖 学习建议

1. **按顺序学习**：各章节内容前后衔接，建议从头开始
2. **动手敲代码**：不要只看，把示例代码都运行一遍
3. **先做练习再看答案**：独立完成练习效果最好
4. **遇到问题多查文档**：[MySQL 官方文档](https://dev.mysql.com/doc/) 是最好的参考资料

## 🗄️ 示例数据库

本教程使用一个**电商系统**数据库 `shop_db`，包含以下表：

```
customers (客户) ──┐
                   ├── orders (订单) ──── order_items (订单明细)
employees (员工) ──┘                          │
                                          products (商品) ──── categories (分类)
```

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| categories | 商品分类 | category_id, category_name |
| products | 商品 | product_id, product_name, price, stock |
| customers | 客户 | customer_id, customer_name, city |
| employees | 员工 | employee_id, employee_name, department, manager_id |
| orders | 订单 | order_id, customer_id, employee_id, total_amount |
| order_items | 订单明细 | item_id, order_id, product_id, quantity, unit_price |

## 📝 许可

本教程仅供学习使用。
