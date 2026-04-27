# Docker 容器外网无法访问 - iptables FORWARD 规则缺失问题

> **文档创建时间：** 2025-10-17
> **问题级别：** 🔴 严重 - 导致服务完全无法对外提供服务
> **解决状态：** ✅ 已解决并持久化
> **文档作者：** 哈雷酱（大小姐）

---

## 📋 问题描述

### 环境信息
- **服务器类型：** 华为云 ECS
- **操作系统：** Debian 12 (Linux 6.1.0-35-amd64)
- **Docker 版本：** Docker Compose 2.40.0
- **网络模式：** 华为云 NAT 模式（公网 IP 不直接绑定网卡）
- **公网 IP：** 150.40.179.0
- **内网 IP：** 172.31.11.134

### 故障现象
1. ✅ 本地访问 `http://localhost` - **正常**
2. ✅ 内网访问 `http://172.31.11.134` - **正常**
3. ❌ 公网访问 `http://150.40.179.0` - **连接超时**
4. ✅ Docker 容器运行状态 - **正常**
5. ✅ 端口映射配置 - **正常** (`0.0.0.0:80->80/tcp`)
6. ✅ 华为云安全组配置 - **已确认无问题**

### 用户误判
- ❌ 误以为是端口映射配置问题
- ❌ 误以为是华为云安全组配置问题

---

## 🔍 问题根因分析

### 核心问题
**iptables FORWARD 链缺少 Docker 自定义网络的转发规则！**

### 详细原因

#### 1. Docker 网络架构
项目使用 Docker Compose 创建了自定义网络：
```yaml
networks:
  backend:
    name: my_lnmp_net
```

对应的 Linux 网桥：`br-adf75b2fa08a`（自定义网桥，非默认的 `docker0`）

#### 2. 数据包流向分析

**正常流程（内网访问）：**
```
客户端 → 172.31.11.134:80 (内网IP)
    ↓ (同网段，不经过 FORWARD 链)
容器响应 ✓
```

**异常流程（公网访问）：**
```
客户端 → 150.40.179.0:80 (公网IP)
    ↓ 华为云 NAT 转换
服务器 eth0 (172.31.11.134)
    ↓ iptables NAT DNAT (目标改写为 172.18.0.4:80)
iptables FORWARD 链检查
    ├─ 规则1: docker0 相关 ❌ 不匹配
    ├─ 规则2: docker0 相关 ❌ 不匹配
    ├─ 规则3: docker0 相关 ❌ 不匹配
    └─ 默认策略: DROP ❌ 数据包被丢弃！
```

#### 3. iptables FORWARD 链状态（修复前）

```bash
Chain FORWARD (policy DROP 434 packets, 24084 bytes)
num  pkts bytes target  prot opt in      out     source      destination
1    0    0     ACCEPT  all  --  docker0 docker0 0.0.0.0/0   0.0.0.0/0
2    115K 367M  ACCEPT  all  --  eth0    docker0 0.0.0.0/0   0.0.0.0/0  state RELATED,ESTABLISHED
3    78K  4429K ACCEPT  all  --  docker0 eth0    0.0.0.0/0   0.0.0.0/0
```

**关键问题：**
- ✅ 有 `docker0` 网桥的规则
- ❌ **缺少 `br-adf75b2fa08a` 网桥的规则**
- ⚠️ 默认策略是 `DROP`（丢弃）
- ⚠️ 已丢弃 434 个数据包

#### 4. 为什么会缺少规则？

可能的原因：
1. **Docker 启动顺序问题** - Docker 服务启动时规则被覆盖
2. **系统初始化脚本** - 华为云镜像的初始化脚本可能重置了 iptables
3. **Docker 版本 bug** - 某些版本处理自定义网络时有缺陷
4. **手动修改** - 之前可能手动清理过 iptables 规则

---

## ✅ 解决方案

### 方案一：手动添加 iptables 规则（临时）

```bash
# 1. 允许外部网卡 → Docker 自定义网桥
sudo iptables -I FORWARD 1 -i eth0 -o br-adf75b2fa08a -j ACCEPT

# 2. 允许 Docker 自定义网桥 → 外部网卡
sudo iptables -I FORWARD 2 -i br-adf75b2fa08a -o eth0 -j ACCEPT

# 3. 允许容器间通信
sudo iptables -I FORWARD 3 -i br-adf75b2fa08a -o br-adf75b2fa08a -j ACCEPT
```

**参数说明：**
- `-I FORWARD 1` - 在 FORWARD 链的第 1 位插入（最高优先级）
- `-i eth0` - 入口网卡（外部网络接口）
- `-o br-adf75b2fa08a` - 出口网卡（Docker 网桥）
- `-j ACCEPT` - 动作：接受（允许通过）

### 方案二：持久化配置（推荐）⭐

#### 步骤 1：安装持久化工具
```bash
sudo apt-get update
sudo apt-get install -y iptables-persistent
```

#### 步骤 2：保存当前规则
```bash
# 导出规则到文件
sudo iptables-save | sudo tee /etc/iptables/rules.v4

# 或者直接保存
sudo netfilter-persistent save
```

#### 步骤 3：启用自动加载
```bash
# 启用服务（开机自动加载规则）
sudo systemctl enable netfilter-persistent

# 检查服务状态
sudo systemctl status netfilter-persistent
```

#### 步骤 4：验证配置
```bash
# 查看规则文件
cat /etc/iptables/rules.v4

# 测试访问
curl http://150.40.179.0
```

---

## 🧪 验证测试

### 测试命令

```bash
# 1. 查看 FORWARD 链规则（修复后）
sudo iptables -L FORWARD -n -v --line-numbers

# 2. 测试本地访问
curl -I http://localhost

# 3. 测试内网访问
curl -I http://172.31.11.134

# 4. 测试公网访问（关键）
curl -I http://150.40.179.0

# 5. 从外部测试（在本地电脑运行）
curl -I http://150.40.179.0
```

### 预期结果

```bash
Chain FORWARD (policy DROP 0 packets, 0 bytes)
num  pkts bytes target  prot opt in                  out                 source      destination
1    0    0     ACCEPT  all  --  eth0                br-adf75b2fa08a     0.0.0.0/0   0.0.0.0/0
2    0    0     ACCEPT  all  --  br-adf75b2fa08a     eth0                0.0.0.0/0   0.0.0.0/0
3    0    0     ACCEPT  all  --  br-adf75b2fa08a     br-adf75b2fa08a     0.0.0.0/0   0.0.0.0/0
4    0    0     ACCEPT  all  --  docker0             docker0             0.0.0.0/0   0.0.0.0/0
5    115K 367M  ACCEPT  all  --  eth0                docker0             0.0.0.0/0   0.0.0.0/0  state RELATED,ESTABLISHED
6    78K  4429K ACCEPT  all  --  docker0             eth0                0.0.0.0/0   0.0.0.0/0
```

所有访问测试均应返回 `HTTP/1.1 200 OK`

---

## 📚 知识扩展

### Linux iptables 基础

#### 四表五链

**四表（Tables）：**
1. **filter** - 过滤表（默认表）⭐
   - 控制数据包是否允许通过
   - 本次问题就在这个表的 FORWARD 链
2. **nat** - 地址转换表
   - SNAT / DNAT / MASQUERADE
3. **mangle** - 修改包头表
4. **raw** - 连接跟踪表

**五链（Chains）：**
1. **PREROUTING** - 路由前
2. **INPUT** - 发往本机
3. **FORWARD** - 转发 ⭐ **本次问题链**
4. **OUTPUT** - 本机发出
5. **POSTROUTING** - 路由后

#### 数据包流向图

```
                               ┌──────────────┐
外部数据包 ──────────────────→ │ PREROUTING   │
                               └──────┬───────┘
                                      │
                        ┌─────────────┴─────────────┐
                        ↓                           ↓
                 ┌─────────────┐           ┌─────────────┐
        本机进程 ← │   INPUT     │           │   FORWARD   │ → 转发
                 └─────────────┘           └──────┬──────┘
                                                   │
                 ┌─────────────┐                  │
        本机进程 → │   OUTPUT    │ ─────────┬──────┘
                 └─────────────┘           ↓
                                    ┌─────────────┐
                                    │ POSTROUTING │ → 外部
                                    └─────────────┘
```

### Docker 网络模式

#### Bridge 模式（本项目使用）

```
宿主机 (172.31.11.134)
    │
    ├─ eth0 (外部网卡)
    │
    ├─ docker0 (默认网桥: 172.17.0.0/16)
    │     └─ 使用默认网络的容器
    │
    └─ br-adf75b2fa08a (自定义网桥: 172.18.0.0/16) ⭐
          ├─ my_lnmp_nginx  (172.18.0.4)
          ├─ my_lnmp_php    (172.18.0.2)
          └─ my_lnmp_db     (172.18.0.3)
```

**关键点：**
- 数据包从 `eth0` 到 `br-adf75b2fa08a` 必须经过 **FORWARD 链**
- FORWARD 链默认策略是 DROP，需要明确允许规则

---

## 🛡️ 安全建议

### 1. 最小权限原则

当前规则允许所有流量转发，更安全的做法是限制端口：

```bash
# 仅允许 80 端口（HTTP）
sudo iptables -I FORWARD 1 -i eth0 -o br-adf75b2fa08a -p tcp --dport 80 -j ACCEPT

# 仅允许 443 端口（HTTPS）
sudo iptables -I FORWARD 2 -i eth0 -o br-adf75b2fa08a -p tcp --dport 443 -j ACCEPT

# 允许已建立的连接返回
sudo iptables -I FORWARD 3 -i br-adf75b2fa08a -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

### 2. 限制数据库端口访问

修改 `docker-compose.yml`，将数据库端口改为仅本地监听：

```yaml
# 修改前（不安全，对外暴露）
ports:
  - "3306:3306"

# 修改后（安全，仅本地访问）
ports:
  - "127.0.0.1:3306:3306"
```

### 3. 使用强密码

`.env` 文件中的密码需要修改：
```bash
# 不安全（看起来像生日）
DB_PASSWORD=liu20041016
DB_ROOT_PASSWORD=liu20041016

# 推荐（强密码）
DB_PASSWORD=$(openssl rand -base64 32)
DB_ROOT_PASSWORD=$(openssl rand -base64 32)
```

### 4. 配置 HTTPS

生产环境务必使用 HTTPS：
```bash
# 使用 Let's Encrypt 免费证书
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

### 5. 删除测试页面

删除或重命名暴露服务器信息的 `phpinfo` 页面：
```bash
mv src/public/index.php src/public/phpinfo.php.bak
```

---

## 🔧 故障排查流程

如果以后遇到类似问题，按以下流程排查：

### 1. 应用层检查
```bash
# 检查容器状态
docker ps -a

# 检查容器日志
docker logs my_lnmp_nginx
docker logs my_lnmp_php

# 检查端口监听
ss -tlnp | grep :80

# 测试本地访问
curl -I http://localhost
```

### 2. 网络层检查
```bash
# 获取服务器 IP
ip addr show

# 测试内网 IP
curl -I http://内网IP

# 测试公网 IP（如果有）
curl -I http://公网IP
```

### 3. 系统层检查
```bash
# 检查防火墙服务
systemctl status firewalld
systemctl status ufw

# 检查 iptables 规则
sudo iptables -L -n -v --line-numbers
sudo iptables -t nat -L -n -v

# 特别检查 FORWARD 链
sudo iptables -L FORWARD -n -v --line-numbers
```

### 4. Docker 网络检查
```bash
# 查看 Docker 网络列表
docker network ls

# 查看网络详情
docker network inspect my_lnmp_net

# 查看容器网络配置
docker inspect my_lnmp_nginx | grep -A 20 "Networks"
```

---

## 📊 诊断决策树

```
外网无法访问 Docker 服务
         │
         ├─ 本地能访问？
         │    ├─ 否 → 检查 Docker 配置、容器状态
         │    └─ 是 ↓
         │
         ├─ 内网 IP 能访问？
         │    ├─ 否 → 检查端口监听、Nginx 配置
         │    └─ 是 ↓
         │
         ├─ 防火墙服务运行中？
         │    ├─ 是 → 检查防火墙规则
         │    └─ 否 ↓
         │
         ├─ iptables FORWARD 链有规则？
         │    ├─ 否 → **添加 FORWARD 规则** ⭐ 本次问题
         │    └─ 是 ↓
         │
         └─ 云服务商安全组配置？
              ├─ 未配置 → 添加安全组规则
              └─ 已配置 → 检查其他网络 ACL
```

---

## 📝 相关命令速查

### iptables 常用命令

```bash
# 查看所有规则
sudo iptables -L -n -v --line-numbers

# 查看 FORWARD 链
sudo iptables -L FORWARD -n -v --line-numbers

# 查看 NAT 表
sudo iptables -t nat -L -n -v

# 添加规则（插入到第 1 位）
sudo iptables -I FORWARD 1 -i eth0 -o br-xxx -j ACCEPT

# 删除规则（按编号）
sudo iptables -D FORWARD 1

# 保存规则
sudo iptables-save | sudo tee /etc/iptables/rules.v4

# 恢复规则
sudo iptables-restore < /etc/iptables/rules.v4

# 清空所有规则（危险！）
sudo iptables -F
```

### Docker 网络命令

```bash
# 查看网络列表
docker network ls

# 查看网络详情
docker network inspect <network_name>

# 查看容器网络配置
docker inspect <container_name> | grep -A 20 "Networks"

# 查看 Docker 创建的 iptables 规则
sudo iptables -t nat -L DOCKER -n -v
sudo iptables -L DOCKER -n -v
```

### 网络测试命令

```bash
# HTTP 测试
curl -I http://IP
curl -v http://IP

# TCP 连接测试
telnet IP 80
nc -zv IP 80

# 端口监听检查
ss -tlnp | grep :80
netstat -tlnp | grep :80

# 路由表查看
ip route show
route -n
```

---

## 📖 参考资料

### 官方文档
- [Docker 网络文档](https://docs.docker.com/network/)
- [iptables 手册](https://linux.die.net/man/8/iptables)
- [Debian 防火墙配置](https://wiki.debian.org/iptables)

### 相关文章
- [理解 Docker 网络](https://github.com/docker/labs/blob/master/networking/README.md)
- [iptables 完全指南](https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html)
- [Linux 网络栈原理](https://www.kernel.org/doc/Documentation/networking/)

---

## 🎯 总结

### 问题本质
Docker 自定义网络的 iptables FORWARD 规则缺失，导致外部流量无法转发到容器。

### 解决要点
1. ✅ 添加 iptables FORWARD 规则允许转发
2. ✅ 使用 iptables-persistent 持久化配置
3. ✅ 验证规则生效并测试访问

### 预防措施
1. 定期备份 iptables 规则：`sudo iptables-save > /root/iptables-backup-$(date +%F).rules`
2. 使用配置管理工具（Ansible、Puppet）管理服务器
3. 监控 iptables 规则变化
4. 在 Docker Compose 启动脚本中添加规则检查

### 关键收获
- 问题排查要分层诊断：应用层 → 网络层 → 系统层
- 对比测试法：通过内网/公网访问差异定位问题
- 理解底层原理：Linux 网络栈、iptables、Docker 网络
- 完整解决问题：不仅修复，还要持久化配置

---

**文档维护信息：**
- 创建日期：2025-10-17
- 最后更新：2025-10-17
- 文档版本：v1.0
- 审核状态：✅ 已验证

**版权声明：**
本文档由哈雷酱（大小姐）精心编写，用于记录和分享技术问题的解决方案。
如有任何疑问或建议，欢迎反馈！(￣▽￣)／
