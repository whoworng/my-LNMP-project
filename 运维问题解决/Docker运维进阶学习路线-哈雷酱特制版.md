# 🎀 Docker LNMP 运维进阶学习路线
## 由傲娇大小姐哈雷酱精心制定 (￣▽￣)／

> 哼,笨蛋!既然你诚心诚意地请求本小姐了,那本小姐就大发慈悲教你成为真正的Docker运维高手吧!
> 不过可别以为这是本小姐在关心你,只是看不惯你这么笨而已! ( ` ///´ )

---

## 📋 目录结构
- [第一阶段:理解你现有的LNMP架构](#第一阶段理解你现有的lnmp架构)
- [第二阶段:Docker核心概念精通](#第二阶段docker核心概念精通)
- [第三阶段:实战运维技能](#第三阶段实战运维技能)
- [第四阶段:进阶优化与安全](#第四阶段进阶优化与安全)
- [第五阶段:生产环境部署](#第五阶段生产环境部署)

---

## 🎯 第一阶段:理解你现有的LNMP架构

### 1.1 你的项目架构解析

```
你的 LNMP 项目结构:
┌─────────────────────────────────────────────────┐
│  宿主机 (你的 Linux 系统)                        │
│  ┌───────────────────────────────────────────┐  │
│  │  Docker 网络: my_lnmp_net (backend)       │  │
│  │  ┌─────────┐  ┌─────────┐  ┌──────────┐  │  │
│  │  │ Nginx   │  │  PHP    │  │ MariaDB  │  │  │
│  │  │ :80     │→ │  :9000  │→ │  :3306   │  │  │
│  │  │ Alpine  │  │  8.2    │  │  11.4    │  │  │
│  │  └────┬────┘  └────┬────┘  └────┬─────┘  │  │
│  │       │            │            │         │  │
│  │       ↓            ↓            ↓         │  │
│  │   ./src/      ./src/       ./data/mysql  │  │
│  │   ./logs/     ./logs/                     │  │
│  └───────────────────────────────────────────┘  │
│         ↑80                              ↑3306  │
│      浏览器访问                       外部DB工具  │
└─────────────────────────────────────────────────┘
```

**关键点理解:**
- **Nginx容器** (`my_lnmp_nginx`): 作为Web服务器,监听80端口,处理HTTP请求
- **PHP容器** (`my_lnmp_php`): 运行PHP-FPM,处理PHP代码执行
- **MariaDB容器** (`my_lnmp_db`): 数据库服务,存储应用数据
- **Docker网络** (`my_lnmp_net`): 容器间通过这个私有网络通信
- **数据卷挂载**: 代码、配置、日志、数据都映射到宿主机

### 1.2 实战任务一:逆向工程你的部署

**任务目标:** 完全理解你是如何部署这个项目的

#### 步骤1: 分析容器运行状态
```bash
# 查看运行中的容器详细信息
docker ps -a

# 查看特定容器的详细配置
docker inspect my_lnmp_nginx
docker inspect my_lnmp_php
docker inspect my_lnmp_db

# 查看容器资源使用情况
docker stats
```

#### 步骤2: 理解网络架构
```bash
# 查看Docker网络列表
docker network ls

# 查看你的后端网络详情
docker network inspect my_lnmp_net

# 测试容器间网络连通性
docker exec -it my_lnmp_php ping db
docker exec -it my_lnmp_nginx ping php
```

#### 步骤3: 分析数据卷挂载
```bash
# 查看卷挂载情况
docker volume ls

# 查看容器的挂载点
docker inspect -f '{{ .Mounts }}' my_lnmp_nginx
docker inspect -f '{{ .Mounts }}' my_lnmp_php
docker inspect -f '{{ .Mounts }}' my_lnmp_db

# 检查实际文件映射
ls -lah ./src/
ls -lah ./data/mysql/
ls -lah ./logs/
```

#### 步骤4: 分析镜像构建过程
```bash
# 查看本地镜像
docker images

# 查看PHP镜像的构建历史
docker history my-lnmp-project-php

# 重新构建PHP镜像(理解构建过程)
docker compose build php --no-cache

# 查看构建日志
docker compose build php 2>&1 | tee build.log
```

---

## 🔧 第二阶段:Docker核心概念精通

### 2.1 Docker Compose 深度理解

#### 核心概念
1. **服务 (Services)**: nginx, php, db 都是独立服务
2. **网络 (Networks)**: backend 网络连接所有服务
3. **数据卷 (Volumes)**: 持久化存储和配置共享
4. **环境变量 (.env)**: 统一配置管理

#### 实战任务二: Docker Compose 操作精通

```bash
# ========== 基础操作 ==========
# 启动所有服务
docker compose up -d

# 查看服务状态
docker compose ps

# 查看服务日志
docker compose logs -f
docker compose logs -f nginx
docker compose logs -f php --tail=100

# 停止服务(不删除容器)
docker compose stop

# 启动已停止的服务
docker compose start

# 重启服务
docker compose restart nginx

# 停止并删除容器
docker compose down

# 停止并删除容器+网络+卷(危险!)
docker compose down -v


# ========== 高级操作 ==========
# 仅重建某个服务
docker compose up -d --build php

# 强制重新创建容器
docker compose up -d --force-recreate nginx

# 扩展服务实例(比如运行3个nginx)
docker compose up -d --scale nginx=3

# 查看服务配置(检查环境变量是否正确加载)
docker compose config

# 验证配置文件语法
docker compose config --quiet
```

### 2.2 容器管理精通

#### 实战任务三: 容器操作大师

```bash
# ========== 进入容器调试 ==========
# 进入Nginx容器
docker exec -it my_lnmp_nginx sh

# 进入PHP容器(bash)
docker exec -it my_lnmp_php bash

# 进入MariaDB容器
docker exec -it my_lnmp_db bash

# 直接在容器内执行命令(不进入shell)
docker exec my_lnmp_php php -v
docker exec my_lnmp_nginx nginx -t
docker exec my_lnmp_db mysql -uroot -p${DB_ROOT_PASSWORD} -e "SHOW DATABASES;"


# ========== 日志调试 ==========
# 实时查看日志
docker logs -f my_lnmp_nginx

# 查看最近100行日志
docker logs --tail=100 my_lnmp_php

# 显示带时间戳的日志
docker logs -t my_lnmp_db

# 查看某个时间段的日志
docker logs --since="2025-10-19T10:00:00" my_lnmp_nginx


# ========== 容器资源监控 ==========
# 查看所有容器资源使用
docker stats

# 查看单个容器资源
docker stats my_lnmp_php

# 查看容器进程
docker top my_lnmp_php


# ========== 文件操作 ==========
# 从容器复制文件到宿主机
docker cp my_lnmp_nginx:/etc/nginx/nginx.conf ./nginx-backup.conf

# 从宿主机复制文件到容器
docker cp ./test.php my_lnmp_php:/var/www/html/

# 查看容器文件系统变化
docker diff my_lnmp_php
```

### 2.3 镜像管理精通

#### 实战任务四: 镜像操作专家

```bash
# ========== 镜像查看 ==========
# 列出所有镜像
docker images

# 查看镜像详细信息
docker inspect nginx:1.25-alpine

# 查看镜像分层历史
docker history my-lnmp-project-php


# ========== 镜像构建 ==========
# 构建PHP镜像
docker build -t my-custom-php:8.2 ./php/

# 构建时传递参数
docker build --build-arg PHP_VERSION=8.3 -t my-php:8.3 ./php/

# 不使用缓存构建
docker build --no-cache -t my-php:latest ./php/


# ========== 镜像清理 ==========
# 删除未使用的镜像
docker image prune

# 删除所有未使用的镜像(包括有标签的)
docker image prune -a

# 删除特定镜像
docker rmi nginx:1.25-alpine

# 强制删除(即使有容器在使用)
docker rmi -f image_id


# ========== 镜像导出导入 ==========
# 导出镜像为tar文件
docker save -o my-lnmp-php.tar my-lnmp-project-php

# 从tar文件导入镜像
docker load -i my-lnmp-php.tar

# 导出容器为镜像
docker commit my_lnmp_php my-lnmp-php:custom

# 推送到私有仓库
docker tag my-lnmp-project-php registry.example.com/my-lnmp-php:1.0
docker push registry.example.com/my-lnmp-php:1.0
```

---

## 💪 第三阶段:实战运维技能

### 3.1 日常运维场景

#### 场景1: 修改Nginx配置并重载

```bash
# 1. 修改配置文件
vim ./nginx/conf.d/default.conf

# 2. 测试配置语法
docker exec my_lnmp_nginx nginx -t

# 3. 重载配置(不停机)
docker exec my_lnmp_nginx nginx -s reload

# 或者重启容器(会有短暂中断)
docker compose restart nginx
```

#### 场景2: 修改PHP配置

```bash
# 1. 修改php.ini
vim ./php/php.ini

# 2. 重启PHP-FPM容器使配置生效
docker compose restart php

# 3. 验证配置
docker exec my_lnmp_php php -i | grep memory_limit
```

#### 场景3: 安装新的PHP扩展

```bash
# 1. 编辑Dockerfile
vim ./php/Dockerfile

# 例如添加 Redis 扩展:
# RUN pecl install redis && docker-php-ext-enable redis

# 2. 重新构建镜像
docker compose build php

# 3. 重启容器
docker compose up -d php

# 4. 验证扩展
docker exec my_lnmp_php php -m | grep redis
```

#### 场景4: 数据库备份与恢复

```bash
# ========== 备份 ==========
# 备份所有数据库
docker exec my_lnmp_db mysqldump -uroot -p${DB_ROOT_PASSWORD} --all-databases > backup-all-$(date +%Y%m%d).sql

# 备份单个数据库
docker exec my_lnmp_db mysqldump -uroot -p${DB_ROOT_PASSWORD} liujixaing > backup-liujixaing-$(date +%Y%m%d).sql

# 备份并压缩
docker exec my_lnmp_db mysqldump -uroot -p${DB_ROOT_PASSWORD} liujixaing | gzip > backup-$(date +%Y%m%d).sql.gz


# ========== 恢复 ==========
# 恢复数据库
docker exec -i my_lnmp_db mysql -uroot -p${DB_ROOT_PASSWORD} liujixaing < backup-liujixaing-20251019.sql

# 从压缩文件恢复
gunzip < backup-20251019.sql.gz | docker exec -i my_lnmp_db mysql -uroot -p${DB_ROOT_PASSWORD} liujixaing


# ========== 定时备份(crontab) ==========
# 创建备份脚本
cat > ./backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/monika/my-LNMP-project/backups"
DATE=$(date +%Y%m%d-%H%M%S)
docker exec my_lnmp_db mysqldump -uroot -pliu20041016 --all-databases | gzip > ${BACKUP_DIR}/backup-${DATE}.sql.gz
# 删除7天前的备份
find ${BACKUP_DIR} -name "backup-*.sql.gz" -mtime +7 -delete
EOF

chmod +x ./backup-db.sh

# 添加到crontab(每天凌晨2点备份)
# (crontab -l ; echo "0 2 * * * /home/monika/my-LNMP-project/backup-db.sh") | crontab -
```

#### 场景5: 日志管理

```bash
# ========== 日志查看 ==========
# 查看Nginx访问日志
tail -f ./logs/nginx/access.log

# 查看Nginx错误日志
tail -f ./logs/nginx/error.log

# 查看PHP错误日志
tail -f ./logs/php/error.log


# ========== 日志清理 ==========
# 手动清空日志(保留文件)
> ./logs/nginx/access.log
> ./logs/nginx/error.log

# 日志轮转(使用logrotate)
cat > ./logrotate.conf << 'EOF'
/home/monika/my-LNMP-project/logs/nginx/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        docker exec my_lnmp_nginx nginx -s reopen
    endscript
}
EOF

# 手动执行日志轮转
# logrotate -f ./logrotate.conf
```

### 3.2 故障排查技能

#### 排查流程图
```
问题发生
    ↓
1. 查看容器状态
   docker compose ps
    ↓
2. 查看容器日志
   docker compose logs
    ↓
3. 检查网络连通性
   docker network inspect
    ↓
4. 进入容器内部调试
   docker exec -it
    ↓
5. 检查配置文件
   nginx -t / php -i
    ↓
6. 检查资源使用
   docker stats
    ↓
解决问题
```

#### 常见问题诊断

**问题1: 网页502错误**
```bash
# 1. 检查PHP容器是否运行
docker ps | grep php

# 2. 查看Nginx错误日志
docker logs my_lnmp_nginx

# 3. 测试PHP-FPM连接
docker exec my_lnmp_nginx ping php

# 4. 检查PHP-FPM进程
docker exec my_lnmp_php ps aux | grep php-fpm

# 5. 查看PHP错误日志
docker logs my_lnmp_php
```

**问题2: 数据库连接失败**
```bash
# 1. 检查数据库容器状态
docker ps | grep db

# 2. 测试网络连通性
docker exec my_lnmp_php ping db

# 3. 测试数据库连接
docker exec my_lnmp_php mysql -h db -u monika -p

# 4. 检查数据库日志
docker logs my_lnmp_db

# 5. 验证环境变量
docker exec my_lnmp_db env | grep MYSQL
```

**问题3: 容器频繁重启**
```bash
# 1. 查看容器重启次数
docker ps -a

# 2. 查看容器日志找原因
docker logs my_lnmp_php --tail=100

# 3. 检查资源限制
docker stats

# 4. 查看系统日志
journalctl -u docker -n 100
```

### 3.3 性能监控

#### 实战任务五: 搭建监控系统

```bash
# ========== 使用cAdvisor监控容器 ==========
# 在docker-compose.yml中添加监控服务
cat >> docker-compose.yml << 'EOF'

  # 容器监控
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: ${PROJECT_NAME}_cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - backend
EOF

# 启动监控
docker compose up -d cadvisor

# 访问 http://localhost:8080 查看监控面板
```

---

## 🛡️ 第四阶段:进阶优化与安全

### 4.1 安全加固

#### 安全检查清单

```bash
# ========== 1. 扫描镜像漏洞 ==========
# 使用Trivy扫描镜像
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image my-lnmp-project-php


# ========== 2. 最小权限运行 ==========
# 修改Dockerfile,使用非root用户运行
# vim ./php/Dockerfile
# 添加:
# RUN useradd -m -u 1000 phpuser
# USER phpuser


# ========== 3. 资源限制 ==========
# 在docker-compose.yml中添加资源限制
# 例如:
#   php:
#     deploy:
#       resources:
#         limits:
#           cpus: '0.5'
#           memory: 512M


# ========== 4. 网络隔离 ==========
# 为敏感服务创建独立网络
# 数据库只允许PHP访问,不暴露到宿主机


# ========== 5. 密码安全 ==========
# 使用Docker Secrets管理敏感信息
# 不要在.env中使用弱密码
# 定期轮换密码
```

### 4.2 性能优化

#### PHP-FPM优化
```bash
# 编辑 ./php/fpm-pool.d/www.conf
# 根据服务器资源调整:
# pm.max_children = 50
# pm.start_servers = 10
# pm.min_spare_servers = 5
# pm.max_spare_servers = 20
```

#### Nginx优化
```bash
# 编辑 ./nginx/nginx.conf
# 调整worker进程数和连接数:
# worker_processes auto;
# worker_connections 1024;
# 启用gzip压缩
# 配置缓存
```

#### MariaDB优化
```bash
# 编辑 ./mysql/my.cnf
# 根据内存调整缓冲区:
# innodb_buffer_pool_size = 1G
# max_connections = 200
```

---

## 🚀 第五阶段:生产环境部署

### 5.1 生产环境准备

#### 配置差异化管理
```bash
# 创建生产环境配置
cp .env .env.production

# 修改生产配置:
# - 关闭调试模式
# - 使用强密码
# - 配置域名
# - 启用HTTPS
# - 优化性能参数
```

#### HTTPS配置
```bash
# 1. 获取SSL证书(Let's Encrypt)
# 2. 在docker-compose.yml中添加证书卷挂载
# 3. 修改nginx配置支持HTTPS
# 4. 配置自动续期
```

### 5.2 持续集成/部署(CI/CD)

#### 基础部署脚本
```bash
# 创建部署脚本 deploy.sh
cat > deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 开始部署..."

# 1. 拉取最新代码
git pull origin main

# 2. 备份数据库
./backup-db.sh

# 3. 构建新镜像
docker compose build

# 4. 滚动更新服务
docker compose up -d --no-deps --build php
docker compose up -d --no-deps --build nginx

# 5. 健康检查
sleep 5
curl -f http://localhost/health || exit 1

echo "✅ 部署成功!"
EOF

chmod +x deploy.sh
```

---

## 📚 学习资源推荐

### 官方文档
- Docker官方文档: https://docs.docker.com/
- Docker Compose文档: https://docs.docker.com/compose/
- Nginx文档: https://nginx.org/en/docs/
- PHP官方文档: https://www.php.net/docs.php
- MariaDB文档: https://mariadb.com/kb/en/documentation/

### 进阶学习
- 《Docker实战》
- 《Docker容器与容器云》
- Kubernetes(容器编排进阶)
- Docker Swarm(集群管理)

---

## 🎯 实战练习任务

### 初级任务(第1-2周)
- [ ] 完成第一阶段所有实战任务
- [ ] 熟练使用docker/docker-compose命令
- [ ] 能够独立排查容器基础问题
- [ ] 理解网络和数据卷概念

### 中级任务(第3-4周)
- [ ] 完成第二、三阶段任务
- [ ] 自己添加Redis服务并配置
- [ ] 编写自动化备份脚本
- [ ] 配置日志轮转和监控

### 高级任务(第5-8周)
- [ ] 完成所有阶段任务
- [ ] 实现HTTPS配置
- [ ] 进行性能优化和压力测试
- [ ] 编写完整的CI/CD流程
- [ ] 学习Docker Swarm或Kubernetes

---

## 💡 本小姐的贴心提示

1. **每天练习**: 熟能生巧,每天至少操作30分钟
2. **记录笔记**: 遇到问题和解决方案都要记录
3. **阅读日志**: 养成查看日志的习惯,日志会告诉你一切
4. **备份习惯**: 任何重要操作前都要备份
5. **安全第一**: 永远不要在生产环境直接测试

哼!本小姐已经把最完整的学习路线都教给你了!
接下来就看你自己的努力了,笨蛋! (￣▽￣)ﾉ

记住,真正的运维高手不是记住所有命令,
而是知道在什么场景下用什么工具解决问题!

加油吧!有问题随时来问本小姐! ( ` ///´ )

---

**版本**: v1.0
**最后更新**: 2025-10-19
**作者**: 傲娇大小姐 哈雷酱 ～ (￣▽￣)／
