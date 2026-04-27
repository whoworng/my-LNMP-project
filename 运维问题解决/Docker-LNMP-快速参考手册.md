# ⚡ Docker LNMP 快速参考手册
## 哈雷酱的运维速查表 (￣▽￣)／

> 哼,笨蛋!忘记命令就来这里查!
> 本小姐把所有常用命令都整理好了! (*/ω\*)

---

## 📋 目录

- [日常运维命令](#日常运维命令)
- [容器管理](#容器管理)
- [日志查看](#日志查看)
- [网络调试](#网络调试)
- [数据库操作](#数据库操作)
- [性能监控](#性能监控)
- [故障排查](#故障排查)
- [Makefile快捷命令](#makefile快捷命令)

---

## 🚀 日常运维命令

### 启动/停止/重启服务

```bash
# ========== 使用Docker Compose ==========
docker compose up -d              # 启动所有服务(后台)
docker compose down               # 停止并删除容器
docker compose stop               # 停止服务(保留容器)
docker compose start              # 启动已停止的服务
docker compose restart            # 重启服务
docker compose restart nginx      # 重启单个服务

# ========== 使用Makefile(推荐) ==========
make up                          # 启动服务
make down                        # 停止服务
make restart                     # 重启服务
make ps                          # 查看状态
```

### 查看服务状态

```bash
docker compose ps                # 查看服务状态
docker ps                        # 查看所有运行的容器
docker ps -a                     # 查看所有容器(包括停止的)
docker stats                     # 实时资源监控

# 使用Makefile
make ps                          # 查看状态
make stats                       # 资源监控
make health                      # 健康检查
```

---

## 🐳 容器管理

### 进入容器

```bash
# ========== 直接使用docker命令 ==========
docker exec -it my_lnmp_nginx sh      # 进入Nginx容器
docker exec -it my_lnmp_php bash      # 进入PHP容器
docker exec -it my_lnmp_db bash       # 进入数据库容器

# ========== 使用Makefile(推荐) ==========
make shell-nginx                      # 进入Nginx
make shell-php                        # 进入PHP
make shell-db                         # 进入数据库
make db-cli                           # 直接进入MySQL命令行
```

### 在容器内执行命令(不进入shell)

```bash
# Nginx相关
docker exec my_lnmp_nginx nginx -v                    # 查看Nginx版本
docker exec my_lnmp_nginx nginx -t                    # 测试配置
docker exec my_lnmp_nginx nginx -s reload             # 重载配置

# PHP相关
docker exec my_lnmp_php php -v                        # 查看PHP版本
docker exec my_lnmp_php php -m                        # 查看PHP扩展
docker exec my_lnmp_php php -i                        # 查看phpinfo
docker exec my_lnmp_php php /var/www/html/test.php   # 执行PHP文件

# 数据库相关
docker exec my_lnmp_db mysql -uroot -p -e "SHOW DATABASES;"

# 使用Makefile
make nginx-test                       # 测试Nginx配置
make php-version                      # 显示PHP版本和扩展
make db-test                          # 测试数据库连接
make db-list                          # 列出所有数据库
make db-tables                        # 显示当前数据库的表
```

### 文件复制

```bash
# 从容器复制到宿主机
docker cp my_lnmp_nginx:/etc/nginx/nginx.conf ./nginx-backup.conf
docker cp my_lnmp_php:/usr/local/etc/php/php.ini ./php.ini.bak

# 从宿主机复制到容器
docker cp ./test.php my_lnmp_php:/var/www/html/
docker cp ./config.json my_lnmp_nginx:/etc/nginx/
```

### 重建镜像

```bash
# 重建所有镜像
docker compose build --no-cache
make build

# 重建单个服务
docker compose build php
make build-php

# 重建并重启
docker compose up -d --build
make rebuild
```

---

## 📋 日志查看

### 容器日志

```bash
# ========== 查看所有日志 ==========
docker compose logs                    # 查看所有服务日志
docker compose logs -f                 # 实时跟踪日志
docker compose logs --tail=100         # 查看最近100行

# ========== 查看单个服务日志 ==========
docker compose logs nginx              # 查看Nginx日志
docker compose logs -f php             # 实时查看PHP日志
docker compose logs --tail=50 db       # 查看数据库最近50行

# ========== 使用docker logs ==========
docker logs my_lnmp_nginx              # 查看Nginx容器日志
docker logs -f my_lnmp_php             # 实时查看PHP日志
docker logs --tail=100 my_lnmp_db      # 最近100行数据库日志
docker logs --since="1h" my_lnmp_nginx # 查看最近1小时日志
docker logs -t my_lnmp_php             # 显示时间戳

# ========== 使用Makefile ==========
make logs                              # 查看所有日志
make logs-nginx                        # Nginx日志
make logs-php                          # PHP日志
make logs-db                           # 数据库日志
```

### 应用日志文件

```bash
# 查看Nginx日志文件
tail -f ./logs/nginx/access.log        # 访问日志
tail -f ./logs/nginx/error.log         # 错误日志

# 查看PHP日志
tail -f ./logs/php/error.log           # PHP错误日志

# 清空日志
make clear-logs
```

---

## 🌐 网络调试

### 网络信息查看

```bash
# 查看网络列表
docker network ls

# 查看特定网络详情
docker network inspect my_lnmp_net

# 使用Makefile
make network
```

### 网络连通性测试

```bash
# 测试容器间网络
docker exec my_lnmp_php ping db        # PHP -> DB
docker exec my_lnmp_php ping nginx     # PHP -> Nginx
docker exec my_lnmp_nginx ping php     # Nginx -> PHP

# 测试外网连接
docker exec my_lnmp_php ping -c 3 8.8.8.8
docker exec my_lnmp_php ping -c 3 baidu.com

# DNS解析测试
docker exec my_lnmp_php nslookup db
docker exec my_lnmp_php nslookup nginx

# 端口连通性测试(需要telnet)
docker exec my_lnmp_php telnet db 3306
```

### 查看端口映射

```bash
# 查看所有端口映射
docker ps --format "table {{.Names}}\t{{.Ports}}"

# 查看特定容器端口
docker port my_lnmp_nginx
docker port my_lnmp_db
```

---

## 💾 数据库操作

### 连接数据库

```bash
# 进入MySQL命令行
docker exec -it my_lnmp_db mysql -uroot -pliu20041016

# 使用Makefile
make db-cli

# 从PHP容器连接数据库
docker exec -it my_lnmp_php mysql -h db -u monika -pliu20041016
```

### 常用SQL操作

```bash
# ========== 数据库管理 ==========
# 显示所有数据库
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "SHOW DATABASES;"
make db-list

# 创建数据库
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "CREATE DATABASE test_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 删除数据库
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "DROP DATABASE test_db;"

# 显示表
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "USE liujixaing; SHOW TABLES;"
make db-tables


# ========== 用户管理 ==========
# 创建用户
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "CREATE USER 'newuser'@'%' IDENTIFIED BY 'password';"

# 授权
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "GRANT ALL PRIVILEGES ON dbname.* TO 'user'@'%';"

# 刷新权限
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "FLUSH PRIVILEGES;"


# ========== 查看状态 ==========
# 查看版本
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "SELECT VERSION();"

# 查看当前连接
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "SHOW PROCESSLIST;"

# 查看数据库大小
docker exec my_lnmp_db mysql -uroot -pliu20041016 -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.tables GROUP BY table_schema;"
```

### 备份与恢复

```bash
# ========== 备份 ==========
# 备份所有数据库
docker exec my_lnmp_db mysqldump -uroot -pliu20041016 --all-databases > backup-all.sql
make backup

# 备份单个数据库
docker exec my_lnmp_db mysqldump -uroot -pliu20041016 liujixaing > backup-liujixaing.sql
make backup-db

# 备份并压缩
docker exec my_lnmp_db mysqldump -uroot -pliu20041016 --all-databases | gzip > backup.sql.gz


# ========== 恢复 ==========
# 恢复所有数据库
docker exec -i my_lnmp_db mysql -uroot -pliu20041016 < backup-all.sql

# 恢复单个数据库
docker exec -i my_lnmp_db mysql -uroot -pliu20041016 liujixaing < backup-liujixaing.sql

# 从压缩文件恢复
gunzip < backup.sql.gz | docker exec -i my_lnmp_db mysql -uroot -pliu20041016

# 使用Makefile恢复
make restore FILE=./backups/backup-20251019.sql.gz
```

---

## 📊 性能监控

### 资源使用监控

```bash
# 实时监控所有容器
docker stats

# 监控特定容器
docker stats my_lnmp_nginx my_lnmp_php my_lnmp_db

# 不实时显示(快照)
docker stats --no-stream

# 使用Makefile
make stats
```

### 容器进程查看

```bash
# 查看容器内进程
docker top my_lnmp_php
docker top my_lnmp_nginx
docker top my_lnmp_db

# 使用Makefile
make top
```

### 磁盘使用情况

```bash
# 查看Docker占用的磁盘空间
docker system df

# 详细信息
docker system df -v

# 查看容器文件系统变化
docker diff my_lnmp_php

# 查看数据卷占用
docker volume ls
du -sh ./data/mysql
du -sh ./logs
```

### 系统信息

```bash
# Docker信息
docker info

# 容器详细信息
docker inspect my_lnmp_nginx
docker inspect my_lnmp_php
docker inspect my_lnmp_db

# 查看特定信息(JSON格式)
docker inspect -f '{{ .NetworkSettings.IPAddress }}' my_lnmp_php
docker inspect -f '{{ .State.Status }}' my_lnmp_nginx
docker inspect -f '{{ .Mounts }}' my_lnmp_db
```

---

## 🔍 故障排查

### 问题诊断流程

```bash
# ========== 第一步:检查容器状态 ==========
docker ps -a                           # 查看所有容器
make ps
make health                            # 健康检查

# ========== 第二步:查看日志 ==========
docker compose logs                    # 查看所有日志
docker compose logs -f php             # 重点查看出问题的服务
make logs

# ========== 第三步:进入容器调试 ==========
docker exec -it my_lnmp_php bash       # 进入容器
make shell-php

# 在容器内检查:
ps aux                                 # 查看进程
netstat -tunlp                         # 查看端口
ls -la /var/www/html                   # 检查文件权限
cat /var/log/nginx/error.log           # 查看错误日志

# ========== 第四步:测试网络 ==========
docker exec my_lnmp_php ping db        # 测试网络连通性
make network                           # 查看网络配置

# ========== 第五步:检查配置 ==========
docker exec my_lnmp_nginx nginx -t     # 测试Nginx配置
make nginx-test
docker exec my_lnmp_php php -i         # 查看PHP配置
make php-version
```

### 常见问题速查

```bash
# ========== 502 Bad Gateway ==========
# 1. 检查PHP容器是否运行
docker ps | grep php
# 2. 查看Nginx错误日志
docker logs my_lnmp_nginx
# 3. 测试PHP-FPM
docker exec my_lnmp_php ps aux | grep php-fpm
# 4. 重启PHP容器
docker compose restart php


# ========== 数据库连接失败 ==========
# 1. 检查数据库容器
docker ps | grep db
# 2. 测试网络连通性
docker exec my_lnmp_php ping db
# 3. 测试数据库连接
docker exec my_lnmp_php mysql -h db -u monika -pliu20041016
make db-test
# 4. 查看数据库日志
docker logs my_lnmp_db


# ========== 容器频繁重启 ==========
# 1. 查看重启次数和状态
docker ps -a
# 2. 查看容器日志找原因
docker logs --tail=100 my_lnmp_php
# 3. 检查资源使用
docker stats
# 4. 检查系统日志
journalctl -u docker -n 100


# ========== 权限问题 ==========
# 查看文件权限
ls -la ./src/
# 修改权限(在宿主机)
sudo chown -R 1000:1000 ./src/
sudo chmod -R 755 ./src/
# 或在容器内修改
docker exec my_lnmp_php chown -R www-data:www-data /var/www/html


# ========== 磁盘空间不足 ==========
# 查看磁盘使用
df -h
docker system df
# 清理未使用资源
make clean
# 深度清理(谨慎!)
make clean-all
```

---

## 🎯 Makefile 快捷命令

### 查看所有可用命令

```bash
make help                            # 显示所有命令和说明
make                                 # 默认显示帮助(同上)
```

### 基础操作

```bash
make up                              # 启动服务
make down                            # 停止服务
make restart                         # 重启服务
make stop                            # 停止(不删除容器)
make start                           # 启动已停止的服务
make ps                              # 查看状态
```

### 构建相关

```bash
make build                           # 重建所有镜像
make build-php                       # 仅重建PHP
make rebuild                         # 重建并重启
make update                          # 拉取最新镜像
```

### 日志管理

```bash
make logs                            # 查看所有日志
make logs-nginx                      # Nginx日志
make logs-php                        # PHP日志
make logs-db                         # 数据库日志
make clear-logs                      # 清空日志
```

### 容器访问

```bash
make shell-nginx                     # 进入Nginx
make shell-php                       # 进入PHP
make shell-db                        # 进入数据库
make db-cli                          # MySQL命令行
```

### 测试验证

```bash
make test                            # 运行所有测试
make nginx-test                      # 测试Nginx配置
make php-version                     # 查看PHP版本
make db-test                         # 测试数据库
make health                          # 健康检查
make validate                        # 验证配置
```

### 监控统计

```bash
make stats                           # 资源监控
make top                             # 进程查看
make network                         # 网络信息
```

### 数据库操作

```bash
make backup                          # 备份所有数据库
make backup-db                       # 备份指定数据库
make restore FILE=xxx.sql.gz         # 恢复数据库
make db-list                         # 列出数据库
make db-tables                       # 显示表
```

### 清理操作

```bash
make clean                           # 清理未使用资源
make clean-all                       # 深度清理(谨慎!)
```

### 其他工具

```bash
make config                          # 显示完整配置
make env                             # 显示环境变量
```

---

## 🔐 安全相关

### 查看敏感信息

```bash
# 查看环境变量(包含密码)
cat .env
make env

# 查看容器环境变量
docker exec my_lnmp_db env | grep MYSQL
```

### 修改密码

```bash
# 修改数据库root密码
docker exec -it my_lnmp_db mysql -uroot -p
# 在MySQL中执行:
ALTER USER 'root'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;

# 同时修改.env文件
vim .env
# 修改 DB_ROOT_PASSWORD=new_password

# 重启数据库容器
docker compose restart db
```

---

## 📝 配置修改

### 修改Nginx配置

```bash
# 1. 编辑配置文件
vim ./nginx/conf.d/default.conf

# 2. 测试配置
make nginx-test

# 3. 重载配置(不停机)
docker exec my_lnmp_nginx nginx -s reload

# 或重启容器
docker compose restart nginx
```

### 修改PHP配置

```bash
# 1. 编辑配置
vim ./php/php.ini

# 2. 重启PHP容器
docker compose restart php

# 3. 验证配置
docker exec my_lnmp_php php -i | grep memory_limit
make php-version
```

### 添加PHP扩展

```bash
# 1. 编辑Dockerfile
vim ./php/Dockerfile

# 2. 重新构建镜像
make build-php

# 3. 重启容器
docker compose up -d php

# 4. 验证扩展
docker exec my_lnmp_php php -m
```

---

## 🌟 本小姐的贴心提示

### 命令速记技巧

1. **高频命令用Makefile**: `make logs` 比 `docker compose logs -f --tail=200` 简单多了!
2. **善用Tab补全**: 输入命令时按Tab键自动补全
3. **使用历史记录**: 按↑↓箭头翻找历史命令,Ctrl+R搜索历史
4. **创建别名**: 在 `~/.bashrc` 中添加:
   ```bash
   alias dps='docker ps'
   alias dlogs='docker compose logs -f'
   alias dexec='docker exec -it'
   ```

### 危险操作警示

⚠️ **以下命令要慎用!**

```bash
docker compose down -v              # 会删除数据卷!
make clean-all                      # 会删除所有未使用资源!
docker system prune -af --volumes   # 会清空一切!
rm -rf ./data/mysql                 # 直接删除数据库文件!
```

### 最佳实践

✅ **推荐做法:**

1. 修改配置前先备份
2. 重要操作前先 `make backup`
3. 定期运行 `make health` 检查
4. 查看日志用 `make logs-xxx` 而不是直接删日志文件
5. 进入容器用 `make shell-xxx` 统一入口

---

## 🎓 学习建议

1. **每天练习**: 至少使用3-5个不同的命令
2. **记录笔记**: 遇到新命令记录下来
3. **理解原理**: 不只记命令,更要理解为什么
4. **实际操作**: 看十遍不如做一遍
5. **善用help**: 不确定时查看 `--help`

```bash
docker --help
docker compose --help
docker exec --help
make help
```

---

## 📚 参考资源

- Docker官方文档: https://docs.docker.com/
- Docker Compose文档: https://docs.docker.com/compose/
- 本项目完整教程: `./Docker运维进阶学习路线-哈雷酱特制版.md`
- 运维脚本集合: `./常用运维脚本集合.md`

---

哼!这份速查表可是本小姐的精华总结!
忘记命令就来这里查,不要总是问本小姐! (￣▽￣)ノ

不过...如果真的遇到困难,本小姐还是会帮你的啦! ( ` ///´ )
才、才不是因为关心你呢!只是...只是不想看到你太笨而已!

加油吧,笨蛋! 💪(￣ω￣)

---

**版本**: v1.0
**作者**: 傲娇大小姐 哈雷酱 ～ (￣▽￣)／
**最后更新**: 2025-10-19
