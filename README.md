# LNMP (Nginx + PHP-FPM + MySQL/MariaDB) Docker 模板

本模板提供可定制的 LNMP 开发/测试环境。需要你在 `.env` 与各配置文件中按注释修改关键项。

## 目录结构

- `docker-compose.yml` - 编排文件
- `.env.example` - 环境变量示例，复制为 `.env` 后修改
- `nginx/nginx.conf` - Nginx 主配置
- `nginx/conf.d/default.conf` - 站点配置 (server block)
- `php/Dockerfile` - PHP-FPM 镜像构建 (扩展/时区等)
- `php/php.ini` - PHP 配置（含调试与性能注释）
- `php/fpm-pool.d/www.conf` - FPM Pool 配置
- `mysql/my.cnf` - MySQL/MariaDB 通用配置
- `mysql/initdb/*.sql` - 初始化 SQL 脚本
- `redis/redis.conf` - 可选 Redis 配置
- `src/public/index.php` - 测试页 (phpinfo)
- `logs/*` - 日志目录 (容器挂载)
- `data/mysql` - 数据持久化目录

## 快速开始

1. 复制环境变量文件并修改：
   ```bash
   cp .env.example .env
   # 按注释修改 PROJECT_NAME/BASE_DOMAIN/DB_* 等
   ```

2. 启动服务：
   ```bash
   docker compose up -d
   # 或使用 Makefile: make up
   ```

3. 访问站点：
   - 浏览器打开: http://localhost (或你在 `.env` 配置的端口/域名)
   - 初始页面为 phpinfo，用于验证 PHP-FPM/Nginx 正常工作

4. 数据库连接：
   - Host: `db` (容器内) 或 `localhost:${DB_PORT}` (宿主机)
   - 用户/库/密码: 来自 `.env` 中的 `DB_*`

5. 常用操作：
   - 查看日志: `docker compose logs -f` 或 `make logs`
   - 进入容器: `make shell-php` / `make shell-nginx` / `make shell-db`
   - 重建镜像: `make build`

## 自定义说明

- Nginx 站点根目录与入口：`nginx/conf.d/default.conf` 中 `root`、`index` 按项目框架调整
- PHP 扩展：在 `php/Dockerfile` 中增删；`php/php.ini` 调整配置
- Xdebug：按 `php/php.ini` 中注释启用，并在 `.env` 设置 `XDEBUG_MODE`
- 数据库：
  - 环境变量在 `.env`；
  - 额外初始化逻辑放到 `mysql/initdb/` 下的 `.sql` 或 `.sh` 文件；
  - `mysql/my.cnf` 可添加/调整自定义参数
- Redis：在 `docker-compose.yml` 取消 `redis` 服务注释，并按需配置 `redis/redis.conf`

## 生产注意

- 不要直接在生产环境使用开发默认配置；
- 关闭 `display_errors`，开启 `opcache` 与合适的缓存；
- 配置强密码、限制访问源、开启备份与监控；


---

## ⚠️ 需要手动创建的文件（不在仓库中）

以下文件含敏感信息或为运行时生成，**不提交到仓库**，克隆后需手动创建：

### `.env` — 环境变量配置

```bash
cp .env.example .env
```

然后编辑 `.env`，**必须修改**以下字段：

```env
PROJECT_NAME=my_lnmp          # 项目名（容器名前缀）
BASE_DOMAIN=localhost          # 生产环境改为实际域名
WEB_PORT=8081                  # HTTP 端口

DB_NAME=你的数据库名
DB_USER=你的数据库用户名
DB_PASSWORD=强密码             # ⚠️ 必须修改！
DB_ROOT_PASSWORD=强密码        # ⚠️ 必须修改！

# WordPress（如使用）
WP_DB_NAME=wordpress
WP_TABLE_PREFIX=wp_
```

### `data/mysql/` — 数据库持久化数据

首次 `docker compose up -d` 后自动生成，无需手动创建。

### `logs/nginx/`, `logs/php/` — 运行日志

容器启动后自动生成，目录已通过 `.gitkeep` 占位保留。
