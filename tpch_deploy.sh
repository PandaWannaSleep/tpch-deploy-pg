#!/bin/bash

# 检查用户是否提供了足够的参数
if [ $# -ne 2 ]; then
    echo "用法: $0 <数据和SQL文件的父目录> <被赋予权限的数据库用户>"
    exit 1
fi

# 获取用户输入的参数
DATA_DIR="$1"
USERNAME="$2"

# 数据库名称
DB_NAME="tpch_copy"

# 检查数据库是否已经存在
DB_EXISTS=$(psql -t -c "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME';" | tr -d '[:space:]')
echo "数据库 $DB_NAME 是否存在: $DB_EXISTS"
if [ "$DB_EXISTS" = "1" ]; then
    echo "数据库 $DB_NAME 已经存在，脚本退出。"
    exit 1
fi

# 创建数据库
psql -c "CREATE DATABASE $DB_NAME;"

# 连接到新创建的数据库
psql -d $DB_NAME << EOF
-- 创建表
\i $DATA_DIR/dss.sql

-- 导入数据
COPY customer FROM '$DATA_DIR/customer.tbl' WITH DELIMITER AS '|' NULL '';
COPY lineitem FROM '$DATA_DIR/lineitem.tbl' WITH DELIMITER AS '|' NULL '';
COPY nation FROM '$DATA_DIR/nation.tbl' WITH DELIMITER AS '|' NULL '';
COPY orders FROM '$DATA_DIR/orders.tbl' WITH DELIMITER AS '|' NULL '';
COPY part FROM '$DATA_DIR/part.tbl' WITH DELIMITER AS '|' NULL '';
COPY partsupp FROM '$DATA_DIR/partsupp.tbl' WITH DELIMITER AS '|' NULL '';
COPY region FROM '$DATA_DIR/region.tbl' WITH DELIMITER AS '|' NULL '';
COPY supplier FROM '$DATA_DIR/supplier.tbl' WITH DELIMITER AS '|' NULL '';

-- 导入关系
\i $DATA_DIR/dss_ri.sql

-- 赋予使用用户tpch数据库的权限
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $USERNAME;

-- 赋予schema权限
GRANT ALL PRIVILEGES ON SCHEMA public TO $USERNAME;

-- 赋予表格权限
DO \$\$
DECLARE
    -- 定义一个变量用于存储表名
    table_record record;
BEGIN
    -- 遍历 public 模式下的所有表
    FOR table_record IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
        -- 动态执行授予权限的 SQL 语句
        EXECUTE format('GRANT ALL PRIVILEGES ON TABLE public.%I TO $USERNAME;', table_record.tablename);
    END LOOP;
END \$\$;
EOF

echo "TPCH 负载已成功载入 $DB_NAME 数据库，并为用户 $USERNAME 赋予了相应权限。"