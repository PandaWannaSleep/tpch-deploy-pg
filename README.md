# tpch-deploy-pg

快捷自动化部署tpch数据至postgres或者opengauss

## 使用方法

1. 使用官方工具tpch-kit生成表数据，放置与data目录下。

   当前data目录下放置的是总体大小为20M的数据。新生成的数据将该目录下以tbl结尾的文件替换即可。

2. 切换至数据库用户，如postgres

   ```bash
   su - postgres
   ```

3. 在本项目根目录下执行tpch_deploy_pg.sh脚本，向postgres中导入数据。执行tpch_deploy_gauss.sh脚本，向opengauss中导入数据。

   ```bash
   bash tpch_deploy_pg.sh <数据和SQL文件的父目录> <被赋予权限的数据库用户>
   ```

   - <数据和SQL文件的父目录>：生成的tbl文件和dss.sql及dss_ri.sql所在目录绝对路径
   - <被赋予权限的数据库用户>：赋予创建的数据库、表的权限给指定用户

   e.g.

   ```bash
   bash tpch_deploy_pg.sh /home/omm/tpch-deploy-pg/data postgres
   ```

   