# 📚 SQL 入门教程 —— 从零开始学数据库

> 面向初学者的系统化 SQL 教程，基于 MySQL，采用 Jupyter Notebook 交互式学习

## 🎯 教程特色

- **循序渐进**：从基础概念到高级特性，由浅入深
- **动手实践**：每个章节都有可运行的代码示例
- **配套练习**：每章附带练习题和参考答案，巩固所学
- **完整案例**：使用电商数据库贯穿全教程，贴近真实场景

## 📋 目录

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

## 🚀 快速开始

### 1. 安装依赖

```bash
pip install pymysql pandas jupyter
```

### 2. 安装 MySQL

请参考 [00_环境准备.ipynb](00_环境准备.ipynb) 中的详细安装指南。

### 3. 初始化示例数据库

```bash
python setup_database.py
```

### 4. 启动 Jupyter

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

## 📝 许可

本教程仅供学习使用。
