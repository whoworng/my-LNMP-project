# Day 3-4: Docker基础命令精通

**学习日期**: 2025-10-28
**重要程度**: ⭐⭐⭐⭐⭐
**学习状态**: 🔄 进行中

---

## 🎯 学习目标

掌握Docker最常用的5大核心命令:
1. `docker ps` - 查看容器状态
2. `docker logs` - 查看日志
3. `docker exec` - 进入容器执行命令
4. `docker inspect` - 查看详细信息
5. `docker stats` - 监控资源使用

---

## 1️⃣ docker ps - 查看容器状态

### 基础用法

```bash
# 查看运行中的容器
docker ps

# 查看所有容器(包括停止的)
docker ps -a

# 只显示容器ID
docker ps -q

# 只显示最近创建的3个容器
docker ps -n 3
```

### 自定义显示格式

```bash
# 自定义显示列
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 显示容器名和ID
docker ps --format "{{.Names}} ({{.ID}})"

# 显示所有信息(JSON格式)
docker ps --format "{{json .}}"
```

### 过滤查询

```bash
# 按名称过滤
docker ps --filter "name=nginx"

# 按状态过滤
docker ps --filter "status=running"
docker ps --filter "status=exited"

# 按网络过滤
docker ps --filter "network=my_lnmp_net"
```

### 常用格式化选项

| 占位符 | 含义 |
|--------|------|
| `.ID` | 容器ID |
| `.Names` | 容器名称 |
| `.Image` | 镜像名称 |
| `.Status` | 运行状态 |
| `.Ports` | 端口映射 |
| `.Networks` | 所属网络 |
| `.Mounts` | 挂载点 |

---

## 2️⃣ docker logs - 查看日志

### 基础用法

```bash
# 查看容器所有日志
docker logs my_lnmp_nginx

# 实时跟踪日志(像tail -f)
docker logs -f my_lnmp_nginx

# 查看最近100行
docker logs --tail=100 my_lnmp_nginx

# 显示时间戳
docker logs -t my_lnmp_nginx
```

### 时间过滤

```bash
# 查看最近1小时的日志
docker logs --since="1h" my_lnmp_nginx

# 查看最近30分钟的日志
docker logs --since="30m" my_lnmp_nginx

# 查看指定时间之后的日志
docker logs --since="2025-10-28T10:00:00" my_lnmp_nginx

# 查看指定时间范围的日志
docker logs --since="2025-10-28T10:00:00" --until="2025-10-28T12:00:00" my_lnmp_nginx
```

### 实用技巧

```bash
# 实时查看最新100行日志
docker logs -f --tail=100 my_lnmp_nginx

# 查看错误日志(只看stderr)
docker logs my_lnmp_nginx 2>&1 | grep -i error

# 查看访问日志并统计IP
docker logs my_lnmp_nginx | awk '{print $1}' | sort | uniq -c | sort -rn

# 导出日志到文件
docker logs my_lnmp_nginx > nginx_logs.txt
```

---

## 3️⃣ docker exec - 进入容器执行命令

### 交互式进入容器

```bash
# 进入Nginx容器(Alpine Linux使用sh)
docker exec -it my_lnmp_nginx sh

# 进入PHP容器(Debian/Ubuntu使用bash)
docker exec -it my_lnmp_php bash

# 进入MySQL容器
docker exec -it my_lnmp_db bash

# 直接进入MySQL命令行
docker exec -it my_lnmp_db mysql -uroot -p
```

### 直接执行命令(不进入容器)

```bash
# 查看PHP版本
docker exec my_lnmp_php php -v

# 查看PHP已安装的扩展
docker exec my_lnmp_php php -m

# 查看Nginx配置是否正确
docker exec my_lnmp_nginx nginx -t

# 重载Nginx配置(不重启)
docker exec my_lnmp_nginx nginx -s reload

# 查看容器内的进程
docker exec my_lnmp_php ps aux

# 查看容器内的文件
docker exec my_lnmp_nginx ls -la /etc/nginx/
```

### 高级用法

```bash
# 以root用户执行命令
docker exec -u root my_lnmp_php whoami

# 设置环境变量
docker exec -e MY_VAR=test my_lnmp_php env | grep MY_VAR

# 指定工作目录
docker exec -w /var/www/html my_lnmp_php ls -la

# 执行多个命令
docker exec my_lnmp_nginx sh -c "nginx -t && nginx -s reload"

# 在后台执行命令
docker exec -d my_lnmp_php php /var/www/html/cron.php
```

### 常用容器内命令

**Nginx容器内:**
```bash
nginx -v                    # 查看版本
nginx -t                    # 测试配置
nginx -s reload             # 重载配置
cat /etc/nginx/nginx.conf   # 查看配置
ls -la /var/log/nginx/      # 查看日志
```

**PHP容器内:**
```bash
php -v                      # 查看版本
php -m                      # 查看扩展
php -i                      # 查看phpinfo
php --ini                   # 查看配置文件位置
php -r "phpinfo();"         # 执行PHP代码
```

**MySQL容器内:**
```bash
mysql -V                    # 查看版本
mysql -uroot -p             # 登录MySQL
mysqldump -uroot -p db > backup.sql  # 备份数据库
```

---

## 4️⃣ docker inspect - 查看详细信息

### 基础用法

```bash
# 查看容器完整配置(JSON格式)
docker inspect my_lnmp_nginx

# 查看镜像详细信息
docker inspect nginx:1.25-alpine

# 查看网络详细信息
docker inspect my_lnmp_net

# 查看数据卷详细信息
docker volume inspect my_lnmp_data
```

### 使用格式化输出(重要!)

```bash
# 查看容器IP地址
docker inspect -f '{{.NetworkSettings.Networks.my_lnmp_net.IPAddress}}' my_lnmp_php

# 查看容器状态
docker inspect -f '{{.State.Status}}' my_lnmp_nginx

# 查看容器启动时间
docker inspect -f '{{.State.StartedAt}}' my_lnmp_nginx

# 查看端口映射
docker inspect -f '{{.NetworkSettings.Ports}}' my_lnmp_nginx

# 查看环境变量
docker inspect -f '{{.Config.Env}}' my_lnmp_php

# 查看挂载信息
docker inspect -f '{{ range .Mounts }}{{ .Source }} -> {{ .Destination }}{{ println }}{{ end }}' my_lnmp_nginx
```

### 实用查询示例

```bash
# 查看所有容器的IP地址
docker inspect -f '{{.Name}} - {{.NetworkSettings.Networks.my_lnmp_net.IPAddress}}' $(docker ps -q)

# 查看容器使用的镜像
docker inspect -f '{{.Config.Image}}' my_lnmp_nginx

# 查看容器的重启策略
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' my_lnmp_nginx

# 查看容器的资源限制
docker inspect -f '内存限制: {{.HostConfig.Memory}}, CPU配额: {{.HostConfig.CpuQuota}}' my_lnmp_php

# 查看容器的日志配置
docker inspect -f '{{.HostConfig.LogConfig.Type}}' my_lnmp_nginx
```

### 使用jq工具(更强大的JSON处理)

```bash
# 安装jq(如果没有)
# sudo apt install jq

# 查看容器网络配置
docker inspect my_lnmp_nginx | jq '.[0].NetworkSettings.Networks'

# 查看所有挂载点
docker inspect my_lnmp_nginx | jq '.[0].Mounts'

# 查看环境变量
docker inspect my_lnmp_php | jq '.[0].Config.Env'
```

---

## 5️⃣ docker stats - 监控资源使用

### 基础用法

```bash
# 实时监控所有容器
docker stats

# 只看一次(不刷新)
docker stats --no-stream

# 只监控特定容器
docker stats my_lnmp_nginx my_lnmp_php my_lnmp_db

# 不截断输出
docker stats --no-trunc
```

### 自定义显示格式

```bash
# 自定义显示列
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# 显示容器名和内存使用
docker stats --format "{{.Name}}: {{.MemPerc}}"

# 只显示CPU使用率
docker stats --no-stream --format "{{.Name}}: CPU={{.CPUPerc}}"
```

### 输出说明

| 列名 | 含义 |
|------|------|
| CONTAINER ID | 容器ID |
| NAME | 容器名称 |
| CPU % | CPU使用百分比 |
| MEM USAGE / LIMIT | 内存使用/限制 |
| MEM % | 内存使用百分比 |
| NET I/O | 网络输入/输出 |
| BLOCK I/O | 磁盘读写 |
| PIDS | 进程数 |

### 性能分析技巧

```bash
# 找出CPU使用最高的容器
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}" | sort -k 2 -rn

# 找出内存使用最高的容器
docker stats --no-stream --format "table {{.Name}}\t{{.MemPerc}}" | sort -k 2 -rn

# 持续监控并记录到文件
docker stats --no-stream >> stats_log.txt

# 每10秒记录一次(循环监控)
while true; do docker stats --no-stream >> stats_$(date +%Y%m%d).log; sleep 10; done
```

---

## 🎯 实践任务清单

### 任务1: 进入每个容器,熟悉内部环境

```bash
# 1. 进入Nginx容器
docker exec -it my_lnmp_nginx sh
ls -la /etc/nginx/
cat /etc/nginx/nginx.conf | head -20
nginx -v
exit

# 2. 进入PHP容器
docker exec -it my_lnmp_php bash
php -v
php -m | grep mysql
php --ini
exit

# 3. 进入MySQL容器
docker exec -it my_lnmp_db bash
mysql -uroot -p  # 密码: liu20041016
# 在MySQL内:
SHOW DATABASES;
USE liujixaing;
SHOW TABLES;
exit
exit
```

### 任务2: 查看和分析日志

```bash
# 1. 查看Nginx访问日志(最近100条)
docker logs --tail=100 my_lnmp_nginx

# 2. 实时监控PHP日志
docker logs -f my_lnmp_php

# 3. 查找错误日志
docker logs my_lnmp_nginx 2>&1 | grep -i error

# 4. 查看特定时间的日志
docker logs --since="1h" my_lnmp_nginx
```

### 任务3: 监控容器资源

```bash
# 1. 查看所有容器资源使用(一次性)
docker stats --no-stream

# 2. 实时监控特定容器
docker stats my_lnmp_nginx my_lnmp_php my_lnmp_db

# 3. 查看容器详细信息
docker inspect my_lnmp_nginx | grep -A 10 "Memory"
```

### 任务4: 容器状态管理

```bash
# 1. 查看所有容器状态
docker ps -a

# 2. 查看特定网络的容器
docker ps --filter "network=my_lnmp_net"

# 3. 自定义显示格式
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## 🔧 常用命令速查表

### 容器管理
```bash
docker ps                              # 查看运行中的容器
docker ps -a                           # 查看所有容器
docker start <container>               # 启动容器
docker stop <container>                # 停止容器
docker restart <container>             # 重启容器
docker rm <container>                  # 删除容器
docker rm -f <container>               # 强制删除运行中的容器
```

### 日志查看
```bash
docker logs <container>                # 查看日志
docker logs -f <container>             # 实时查看
docker logs --tail=100 <container>     # 最近100行
docker logs --since="1h" <container>   # 最近1小时
```

### 执行命令
```bash
docker exec -it <container> sh         # 进入容器
docker exec <container> <command>      # 执行命令
docker exec -u root <container> <cmd>  # 以root执行
```

### 信息查看
```bash
docker inspect <container>             # 查看详细信息
docker stats                           # 监控资源使用
docker top <container>                 # 查看进程
docker port <container>                # 查看端口映射
```

---

## 💡 实用技巧和最佳实践

### 1. 日志管理技巧

```bash
# 清空容器日志(小心使用!)
sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' my_lnmp_nginx)

# 查看日志文件大小
du -sh $(docker inspect --format='{{.LogPath}}' my_lnmp_nginx)

# 限制日志大小(在docker-compose.yml中配置)
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 2. 调试技巧

```bash
# 查看容器启动失败的原因
docker logs <container>
docker inspect <container> | grep -i error

# 查看容器退出代码
docker inspect <container> --format='{{.State.ExitCode}}'

# 查看容器最近的更改
docker diff <container>
```

### 3. 性能优化

```bash
# 查看容器资源限制
docker inspect <container> --format='Memory: {{.HostConfig.Memory}}, CPUs: {{.HostConfig.NanoCpus}}'

# 实时监控网络流量
docker stats --format "table {{.Name}}\t{{.NetIO}}"

# 查看容器进程
docker top <container>
```

---

## ❓ 常见问题

### Q1: 容器内找不到某些命令怎么办?
**答**: Alpine Linux容器默认命令很少,可以安装:
```bash
docker exec -it my_lnmp_nginx sh
apk add --no-cache curl vim
```

### Q2: 如何在容器内编辑文件?
**答**:
- 方法1: 在宿主机编辑挂载的文件(推荐)
- 方法2: 在容器内安装vi/vim
- 方法3: 使用docker cp复制出来编辑后再复制回去

### Q3: 日志文件太大怎么办?
**答**:
1. 配置日志轮转(在docker-compose.yml中)
2. 定期清理日志
3. 使用日志收集系统(如ELK)

---

## ✅ 学习检查清单

完成以下任务后,就掌握了Docker基础命令:

- [ ] 能够独立查看容器状态
- [ ] 能够进入任意容器执行命令
- [ ] 能够查看和分析容器日志
- [ ] 能够使用inspect查询容器信息
- [ ] 能够监控容器资源使用
- [ ] 理解容器与宿主机的关系
- [ ] 能够排查简单的容器问题

---

## 🎓 哈雷酱的叮嘱

> 笨蛋!这些命令一定要多练习!
> 只有熟练使用这些基础命令,
> 才能快速定位和解决问题!
> 不许偷懒!本小姐会检查的! (￣へ ￣)

---

## 📚 延伸学习

完成基础命令后,可以继续学习:
- docker-compose命令
- 容器网络管理
- 数据卷管理
- 镜像构建

---

**学习笔记由**: 傲娇大小姐 哈雷酱 指导完成 (￣▽￣)／
**上一步**: Day 1-2 LNMP架构理解
**下一步**: Day 5-6 Docker Compose精通
