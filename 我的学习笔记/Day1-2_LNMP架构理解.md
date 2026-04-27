# Day 1-2: LNMP架构完全理解

**学习日期**: 2025-10-28
**重要程度**: ⭐⭐⭐⭐⭐
**学习状态**: ✅ 已完成

---

## 📁 项目目录结构完全解析

### 🔧 核心配置文件

#### 1. **docker-compose.yml** ⭐⭐⭐⭐⭐
- **作用**: 整个项目的指挥中心!
- 定义了所有服务(Nginx、PHP、MySQL、Redis)
- 配置容器间的网络连接
- 设置端口映射和数据卷挂载
- **类比**: 就像是乐队的总谱,指挥所有乐器如何配合!

#### 2. **.env** (环境变量配置文件) ⭐⭐⭐⭐⭐
- **作用**: 存储敏感信息和可变配置
- 数据库密码、端口号等配置
- 不同环境(开发/生产)的配置切换
- **重要**: 这个文件包含密码,不能提交到Git!
- **类比**: 就像是你的私人日记,只有你能看!

#### 3. **.env.example** (环境变量模板) ⭐⭐⭐
- **作用**: .env的示例模板
- 新人拿到项目后复制成.env使用
- 可以安全地提交到Git(不含真实密码)

#### 4. **.gitignore** (Git忽略清单) ⭐⭐⭐⭐
- **作用**: 告诉Git哪些文件不要追踪
- 忽略.env、日志文件、数据库数据等
- 防止敏感信息泄露

#### 5. **Makefile** (命令快捷方式) ⭐⭐⭐⭐⭐
- **作用**: 简化Docker命令的执行
- 把复杂的命令变成简单的`make up`、`make down`
- 提高运维效率

#### 6. **README.md** (项目说明书) ⭐⭐⭐⭐
- **作用**: 项目的使用说明
- 介绍项目功能和使用方法

---

### 📂 服务配置目录

#### 7. **nginx/** (Nginx配置) ⭐⭐⭐⭐⭐
```
nginx/
├── conf.d/          # 虚拟主机配置(网站配置)
└── nginx.conf       # Nginx主配置文件
```
**作用:**
- 配置网站如何处理HTTP请求
- 配置反向代理到PHP
- 配置域名、SSL证书等
- **会挂载到容器内**: `/etc/nginx/`

#### 8. **php/** (PHP配置) ⭐⭐⭐⭐⭐
```
php/
├── Dockerfile       # PHP镜像构建文件
├── php.ini          # PHP配置文件
└── fpm-pool.d/      # PHP-FPM进程池配置
```
**作用:**
- `Dockerfile`: 定义如何构建PHP镜像,安装扩展
- `php.ini`: PHP运行时配置(内存限制、上传大小等)
- `fpm-pool.d/`: 配置PHP-FPM性能参数
- **会挂载到容器内**: `/usr/local/etc/php/`

#### 9. **mysql/** (MySQL配置) ⭐⭐⭐⭐⭐
```
mysql/
├── my.cnf           # MySQL配置文件
├── initdb/          # 初始化SQL脚本
└── data/            # MySQL数据文件(一般不用)
```
**作用:**
- `my.cnf`: MySQL性能优化配置
- `initdb/`: 容器首次启动时执行的SQL(建库建表等)
- **会挂载到容器内**: `/etc/mysql/conf.d/`

#### 10. **redis/** (Redis配置) ⭐⭐⭐
```
redis/
└── redis.conf       # Redis配置文件
```
**作用:**
- 配置Redis缓存策略、持久化等
- **会挂载到容器内**: `/usr/local/etc/redis/`

---

### 📂 数据和日志目录

#### 11. **data/** (持久化数据) ⭐⭐⭐⭐⭐
```
data/
└── mysql/           # MySQL数据库文件
```
**作用:**
- 存储MySQL的真实数据
- 即使容器删除,数据也不会丢失
- **这是数据持久化的关键!**

#### 12. **logs/** (日志文件) ⭐⭐⭐⭐⭐
```
logs/
├── nginx/           # Nginx日志(access.log, error.log)
└── php/             # PHP日志(php-fpm.log, error.log)
```
**作用:**
- 记录访问日志和错误日志
- 故障排查的重要依据
- 性能分析的数据源

---

### 📂 应用代码目录

#### 13. **src/** (源代码) ⭐⭐⭐⭐⭐
```
src/
└── public/          # 网站根目录
    ├── index.php    # 入口文件
    └── ...
```
**作用:**
- 存放你的PHP网站代码
- 会挂载到Nginx和PHP容器中
- **这是你写代码的地方!**
- **会挂载到容器内**: `/var/www/html/`

---

## 🔄 完整的数据流转图

```
┌─────────────────────────────────────────────────┐
│              用户浏览器                           │
│         http://localhost/index.php              │
└──────────────────┬──────────────────────────────┘
                   │ HTTP请求
                   ↓
┌─────────────────────────────────────────────────┐
│           Nginx容器 (my_lnmp_nginx)              │
│  配置文件: ./nginx/nginx.conf                    │
│  配置文件: ./nginx/conf.d/*.conf                 │
│  网站代码: ./src → /var/www/html                 │
│  日志: ./logs/nginx/ ← /var/log/nginx           │
│  端口映射: 80:80                                 │
└──────────────────┬──────────────────────────────┘
                   │ FastCGI请求 (php:9000)
                   ↓
┌─────────────────────────────────────────────────┐
│           PHP-FPM容器 (my_lnmp_php)              │
│  镜像构建: ./php/Dockerfile                      │
│  配置文件: ./php/php.ini                         │
│  配置文件: ./php/fpm-pool.d/www.conf            │
│  网站代码: ./src → /var/www/html                 │
│  日志: ./logs/php/ ← /var/log/php-fpm           │
│  内部端口: 9000                                  │
└──────────────────┬──────────────────────────────┘
                   │ MySQL连接 (db:3306)
                   ↓
┌─────────────────────────────────────────────────┐
│          MySQL容器 (my_lnmp_db)                  │
│  配置文件: ./mysql/my.cnf                        │
│  初始化: ./mysql/initdb/*.sql                    │
│  数据持久化: ./data/mysql → /var/lib/mysql      │
│  端口映射: 3306:3306                             │
└─────────────────────────────────────────────────┘

               (可选) Redis容器
┌─────────────────────────────────────────────────┐
│          Redis容器 (my_lnmp_redis)               │
│  配置文件: ./redis/redis.conf                    │
│  端口映射: 6379:6379                             │
└─────────────────────────────────────────────────┘
```

---

## 📊 实际挂载关系(我的系统)

### Nginx容器的挂载
```
宿主机路径                                     容器内路径
─────────────────────────────────────────────────────────────
./src                                    →    /var/www/html
./nginx/nginx.conf                       →    /etc/nginx/nginx.conf
./nginx/conf.d                           →    /etc/nginx/conf.d
./logs/nginx                             →    /var/log/nginx
```

### PHP容器的挂载
```
宿主机路径                                     容器内路径
─────────────────────────────────────────────────────────────
./src                                    →    /var/www/html
./php/php.ini                            →    /usr/local/etc/php/php.ini
./logs/php                               →    /var/log/php
```

### MySQL容器的挂载
```
宿主机路径                                     容器内路径
─────────────────────────────────────────────────────────────
./data/mysql                             →    /var/lib/mysql
./mysql/my.cnf                           →    /etc/mysql/conf.d/my.cnf
./mysql/initdb                           →    /docker-entrypoint-initdb.d
```

---

## 💡 关键概念:什么是挂载(Mount)?

**简单理解**: 把宿主机的文件夹连接到容器里!

```
./nginx/nginx.conf  →  容器内的 /etc/nginx/nginx.conf
(宿主机文件)            (容器内路径)
```

**好处:**
- ✅ 修改宿主机文件,容器内立即生效
- ✅ 容器删除后,文件还在宿主机上
- ✅ 方便编辑和备份

**类比**: 就像是在容器里放了一个"传送门",直接连到宿主机的文件!

---

## 🔐 环境变量配置(.env)

```bash
# 项目基础配置
PROJECT_NAME=my_lnmp          # 项目名称
BASE_DOMAIN=localhost         # 基础域名
WEB_PORT=80                   # Web端口
TZ=Asia/Shanghai             # 时区设置

# PHP配置
PHP_VERSION=8.2              # PHP版本
XDEBUG_MODE=off              # Xdebug调试模式

# Nginx配置
NGINX_VERSION=1.25           # Nginx版本

# 数据库配置
DB_ENGINE=mariadb            # 数据库引擎
DB_VERSION=11.4              # 数据库版本
DB_HOST=db                   # 数据库主机名(容器名)
DB_PORT=3306                 # 数据库端口
DB_NAME=liujixaing           # 数据库名
DB_USER=monika               # 数据库用户名
DB_PASSWORD=liu20041016      # 数据库密码
DB_ROOT_PASSWORD=liu20041016 # Root密码

# Redis配置
REDIS_PORT=6379              # Redis端口
```

**安全提示:**
- ⚠️ 生产环境一定要改成复杂密码!
- ⚠️ `.env`文件绝对不能提交到Git!
- ⚠️ 不同环境要用不同的密码!

---

## 🎯 知识点自测

### Q1: 如果我要修改Nginx配置,应该改哪个文件?
**答案**: `./nginx/nginx.conf` 或 `./nginx/conf.d/` 目录下的配置文件

修改后需要重启Nginx容器:
```bash
docker restart my_lnmp_nginx
# 或
make restart
```

### Q2: 如果我要写一个新的PHP页面,应该放在哪里?
**答案**: `./src/public/` 目录下

例如创建 `./src/public/test.php`,访问 `http://localhost/test.php` 即可

### Q3: 数据库的真实数据存在哪里?删除容器会丢失吗?
**答案**: 存在 `./data/mysql/` 目录

不会丢失!因为使用了数据卷挂载,只要宿主机的文件还在,数据就在!

但是如果执行 `docker compose down -v`(带`-v`参数),会删除数据卷,那就真的丢了!

---

## 📝 重要命令记录

```bash
# 查看项目结构
tree -L 2 -a

# 查看文件列表
ls -la

# 查看环境变量
cat .env

# 查看挂载关系
docker inspect my_lnmp_nginx --format '{{ range .Mounts }}{{ println .Source " -> " .Destination }}{{ end }}'

# 查看网络配置
docker network inspect my_lnmp_net
```

---

## ✅ 学习成果

通过Day 1-2的学习,我已经理解了:

- [x] 项目的完整目录结构
- [x] 每个目录和文件的作用
- [x] 挂载(Mount)机制的原理
- [x] 环境变量的配置方法
- [x] 从浏览器到数据库的完整数据流程
- [x] 如何修改各个服务的配置

---

## 🎓 哈雷酱的叮嘱

> 哼!笨蛋,Day 1-2完成得不错嘛!
> 记住这些基础知识,后面的学习会越来越容易!
> 本小姐会一直陪着...监督你的! ( ` ///´ )

---

**学习笔记由**: 傲娇大小姐 哈雷酱 指导完成 (￣▽￣)／
**下一步**: Day 3-4 Docker基础命令
