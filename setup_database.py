"""
SQL 教程 - 数据库初始化脚本
运行此脚本将创建示例数据库 shop_db 并填充测试数据
"""

from typing import TYPE_CHECKING
import sys

# 帮助静态类型检查器识别 pymysql，同时在运行时提供友好的提示
if TYPE_CHECKING:
    import pymysql  # pragma: no cover
else:
    try:
        import pymysql
    except ImportError:
        print("模块 pymysql 未安装。请运行: pip install pymysql")
        sys.exit(1)

# 数据库连接配置（请根据你的实际情况修改）
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "314159",  # ← 修改为你的 MySQL 密码
    "charset": "utf8mb4",
}


def create_database(cursor):
    """创建数据库"""
    cursor.execute("DROP DATABASE IF EXISTS shop_db")
    cursor.execute(
        "CREATE DATABASE shop_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    )
    cursor.execute("USE shop_db")
    print("✅ 数据库 shop_db 创建成功")


def create_tables(cursor):
    """创建所有表"""
    tables = [
        # 分类表
        """
        CREATE TABLE categories (
            category_id   INT PRIMARY KEY AUTO_INCREMENT,
            category_name VARCHAR(50)  NOT NULL,
            description   VARCHAR(200)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        # 商品表
        """
        CREATE TABLE products (
            product_id    INT PRIMARY KEY AUTO_INCREMENT,
            product_name  VARCHAR(100) NOT NULL,
            category_id   INT,
            price         DECIMAL(10, 2) NOT NULL,
            stock         INT DEFAULT 0,
            created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        # 客户表
        """
        CREATE TABLE customers (
            customer_id   INT PRIMARY KEY AUTO_INCREMENT,
            customer_name VARCHAR(50)  NOT NULL,
            email         VARCHAR(100),
            phone         VARCHAR(20),
            city          VARCHAR(50),
            created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        # 员工表
        """
        CREATE TABLE employees (
            employee_id   INT PRIMARY KEY AUTO_INCREMENT,
            employee_name VARCHAR(50)  NOT NULL,
            department    VARCHAR(50),
            salary        DECIMAL(10, 2),
            hire_date     DATE,
            manager_id    INT,
            FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        # 订单表
        """
        CREATE TABLE orders (
            order_id      INT PRIMARY KEY AUTO_INCREMENT,
            customer_id   INT,
            employee_id   INT,
            order_date    DATETIME DEFAULT CURRENT_TIMESTAMP,
            status        VARCHAR(20) DEFAULT '待处理',
            total_amount  DECIMAL(12, 2),
            FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
            FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        # 订单明细表
        """
        CREATE TABLE order_items (
            item_id       INT PRIMARY KEY AUTO_INCREMENT,
            order_id      INT,
            product_id    INT,
            quantity      INT NOT NULL,
            unit_price    DECIMAL(10, 2) NOT NULL,
            FOREIGN KEY (order_id)   REFERENCES orders(order_id),
            FOREIGN KEY (product_id) REFERENCES products(product_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
    ]

    for ddl in tables:
        cursor.execute(ddl)

    print("✅ 所有表创建成功")


def insert_data(cursor):
    """插入示例数据"""

    # ---- 分类 ----
    cursor.executemany(
        "INSERT INTO categories (category_id, category_name, description) VALUES (%s, %s, %s)",
        [
            (1, "电子产品", "手机、电脑、平板等电子设备"),
            (2, "服装", "男装、女装、童装"),
            (3, "食品", "零食、饮料、生鲜"),
            (4, "图书", "文学、科技、教育类图书"),
            (5, "家居", "家具、家纺、厨具"),
        ],
    )

    # ---- 商品 ----
    cursor.executemany(
        "INSERT INTO products (product_id, product_name, category_id, price, stock) VALUES (%s, %s, %s, %s, %s)",
        [
            (1, "iPhone 15", 1, 6999.00, 50),
            (2, "MacBook Pro 14", 1, 14999.00, 30),
            (3, "iPad Air", 1, 4399.00, 80),
            (4, "AirPods Pro", 1, 1899.00, 200),
            (5, "华为 Mate 60", 1, 5999.00, 60),
            (6, "男士纯棉T恤", 2, 99.00, 500),
            (7, "女士连衣裙", 2, 299.00, 300),
            (8, "儿童运动鞋", 2, 199.00, 150),
            (9, "牛仔裤", 2, 259.00, 400),
            (10, "进口巧克力礼盒", 3, 128.00, 100),
            (11, "有机牛奶（12盒）", 3, 79.90, 200),
            (12, "坚果大礼包", 3, 168.00, 120),
            (13, "SQL入门经典", 4, 59.00, 300),
            (14, "Python编程从入门到实践", 4, 79.00, 250),
            (15, "人类简史", 4, 49.90, 180),
            (16, "北欧风台灯", 5, 189.00, 80),
            (17, "纯棉四件套", 5, 399.00, 60),
            (18, "不锈钢保温杯", 5, 89.00, 300),
            (19, "智能扫地机器人", 1, 2599.00, 40),
            (20, "羽绒服", 2, 799.00, 100),
        ],
    )

    # ---- 客户 ----
    cursor.executemany(
        "INSERT INTO customers (customer_id, customer_name, email, phone, city) VALUES (%s, %s, %s, %s, %s)",
        [
            (1, "张三", "zhangsan@email.com", "13800001111", "北京"),
            (2, "李四", "lisi@email.com", "13800002222", "上海"),
            (3, "王五", "wangwu@email.com", "13800003333", "广州"),
            (4, "赵六", "zhaoliu@email.com", "13800004444", "深圳"),
            (5, "钱七", "qianqi@email.com", "13800005555", "杭州"),
            (6, "孙八", "sunba@email.com", "13800006666", "成都"),
            (7, "周九", "zhoujiu@email.com", "13800007777", "武汉"),
            (8, "吴十", "wushi@email.com", "13800008888", "南京"),
            (9, "郑强", "zhengqiang@email.com", "13800009999", "北京"),
            (10, "陈芳", "chenfang@email.com", "13800000000", "上海"),
        ],
    )

    # ---- 员工 ----
    cursor.executemany(
        "INSERT INTO employees (employee_id, employee_name, department, salary, hire_date, manager_id) VALUES (%s, %s, %s, %s, %s, %s)",
        [
            (1, "刘总", "管理层", 50000.00, "2015-01-01", None),
            (2, "王经理", "销售部", 25000.00, "2016-03-15", 1),
            (3, "李经理", "技术部", 28000.00, "2016-06-01", 1),
            (4, "张明", "销售部", 12000.00, "2018-07-10", 2),
            (5, "陈静", "销售部", 13000.00, "2019-03-20", 2),
            (6, "赵伟", "技术部", 18000.00, "2017-09-01", 3),
            (7, "黄丽", "技术部", 16000.00, "2020-01-15", 3),
            (8, "林峰", "客服部", 10000.00, "2021-04-01", 1),
            (9, "何敏", "客服部", 9500.00, "2022-06-15", 8),
            (10, "杨帆", "销售部", 11000.00, "2023-01-10", 2),
        ],
    )

    # ---- 订单 ----
    cursor.executemany(
        "INSERT INTO orders (order_id, customer_id, employee_id, order_date, status, total_amount) VALUES (%s, %s, %s, %s, %s, %s)",
        [
            (1, 1, 4, "2024-01-15 10:30:00", "已完成", 8898.00),
            (2, 2, 5, "2024-01-20 14:20:00", "已完成", 14999.00),
            (3, 3, 4, "2024-02-05 09:15:00", "已完成", 599.00),
            (4, 1, 5, "2024-02-14 16:45:00", "已完成", 2599.00),
            (5, 4, 4, "2024-03-01 11:00:00", "已发货", 4399.00),
            (6, 5, 10, "2024-03-10 13:30:00", "已发货", 358.00),
            (7, 2, 5, "2024-03-15 08:20:00", "待处理", 1899.00),
            (8, 6, 4, "2024-03-20 15:10:00", "已完成", 799.00),
            (9, 7, 10, "2024-04-01 10:00:00", "待处理", 227.90),
            (10, 8, 5, "2024-04-05 17:30:00", "已完成", 138.00),
            (11, 9, 4, "2024-04-10 09:45:00", "已发货", 15188.00),
            (12, 10, 10, "2024-04-15 14:00:00", "已完成", 549.00),
            (13, 3, 5, "2024-05-01 11:20:00", "待处理", 168.00),
            (14, 1, 4, "2024-05-05 16:00:00", "已完成", 79.90),
            (15, 5, 10, "2024-05-10 10:30:00", "已发货", 399.00),
        ],
    )

    # ---- 订单明细 ----
    cursor.executemany(
        "INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price) VALUES (%s, %s, %s, %s, %s)",
        [
            (1, 1, 1, 1, 6999.00),
            (2, 1, 4, 1, 1899.00),
            (3, 2, 2, 1, 14999.00),
            (4, 3, 7, 2, 299.00),
            (5, 4, 19, 1, 2599.00),
            (6, 5, 3, 1, 4399.00),
            (7, 6, 10, 1, 128.00),
            (8, 6, 12, 1, 168.00),
            (9, 6, 6, 1, 99.00),
            (10, 7, 4, 1, 1899.00),
            (11, 8, 20, 1, 799.00),
            (12, 9, 11, 1, 79.90),
            (13, 9, 15, 1, 49.90),
            (14, 9, 13, 1, 59.00),
            (15, 9, 18, 1, 89.00),
            (16, 10, 10, 1, 128.00),
            (17, 11, 2, 1, 14999.00),
            (18, 11, 18, 2, 89.00),
            (19, 12, 9, 1, 259.00),
            (20, 12, 7, 1, 299.00),
            (21, 13, 12, 1, 168.00),
            (22, 14, 11, 1, 79.90),
            (23, 15, 17, 1, 399.00),
        ],
    )

    print("✅ 所有示例数据插入成功")


def verify_data(cursor):
    """验证数据"""
    tables = [
        "categories",
        "products",
        "customers",
        "employees",
        "orders",
        "order_items",
    ]
    print("\n📊 数据验证：")
    print("-" * 30)
    for table in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"  {table:15s} → {count} 条记录")
    print("-" * 30)


def main():
    print("=" * 50)
    print("  SQL 教程 - 示例数据库初始化")
    print("=" * 50)
    print()

    try:
        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor()

        create_database(cursor)
        create_tables(cursor)
        insert_data(cursor)
        conn.commit()

        verify_data(cursor)

        cursor.close()
        conn.close()

        print("\n🎉 初始化完成！现在可以开始学习 SQL 了。")
        print("   请打开 Jupyter Notebook，从 00_环境准备.ipynb 开始。")

    except pymysql.err.OperationalError as e:
        print(f"\n❌ 数据库连接失败: {e}")
        print("   请检查：")
        print("   1. MySQL 服务是否已启动")
        print("   2. 用户名和密码是否正确（请修改本脚本顶部的 DB_CONFIG）")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 发生错误: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
