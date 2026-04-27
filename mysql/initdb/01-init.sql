-- 初始化脚本样例：容器首次启动会自动执行 docker-entrypoint-initdb.d 下的脚本
-- 如已通过环境变量创建了 ${DB_NAME} 与 ${DB_USER}，这里可新增更多库/用户/权限

-- 提示：请按需修改/取消注释，避免生产环境意外复用默认值

-- CREATE DATABASE IF NOT EXISTS `your_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- CREATE USER IF NOT EXISTS 'your_user'@'%' IDENTIFIED BY 'your_password';
-- GRANT ALL PRIVILEGES ON `your_db`.* TO 'your_user'@'%';
-- FLUSH PRIVILEGES;

