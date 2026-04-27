SHELL := /bin/bash

# 项目配置
PROJECT ?= $(shell grep -E '^PROJECT_NAME=' .env 2>/dev/null | cut -d= -f2)
DB_ROOT_PASSWORD ?= $(shell grep -E '^DB_ROOT_PASSWORD=' .env 2>/dev/null | cut -d= -f2)
DB_NAME ?= $(shell grep -E '^DB_NAME=' .env 2>/dev/null | cut -d= -f2)
DC := docker compose

# 颜色定义(让输出更优雅)
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m # No Color

.DEFAULT_GOAL := help

.PHONY: help up down restart build ps logs shell-php shell-nginx shell-db \
        stats clean backup restore test nginx-test php-version db-test \
        logs-nginx logs-php logs-db clear-logs rebuild update health

## ========== 基础操作 ==========

help: ## 显示此帮助信息 (本小姐精心设计的命令列表哦～)
	@echo "$(GREEN)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(GREEN)║  🎀 LNMP Docker 运维命令集 - by 哈雷酱 (￣▽￣)／       ║$(NC)"
	@echo "$(GREEN)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(YELLOW)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""

up: ## 启动所有服务
	@echo "$(GREEN)🚀 启动服务中...$(NC)"
	$(DC) up -d
	@echo "$(GREEN)✅ 服务启动成功! 使用 'make ps' 查看状态$(NC)"

down: ## 停止并移除所有容器
	@echo "$(YELLOW)⚠️  停止服务中...$(NC)"
	$(DC) down
	@echo "$(GREEN)✅ 服务已停止$(NC)"

restart: ## 重启所有服务
	@echo "$(YELLOW)🔄 重启服务中...$(NC)"
	$(DC) restart
	@echo "$(GREEN)✅ 服务重启完成$(NC)"

stop: ## 停止服务(不删除容器)
	@echo "$(YELLOW)⏸️  停止服务...$(NC)"
	$(DC) stop

start: ## 启动已停止的服务
	@echo "$(GREEN)▶️  启动服务...$(NC)"
	$(DC) start

ps: ## 查看容器状态
	@echo "$(GREEN)📊 容器状态:$(NC)"
	@$(DC) ps

## ========== 构建与更新 ==========

build: ## 重新构建所有镜像(无缓存)
	@echo "$(YELLOW)🔨 重新构建镜像中(无缓存)...$(NC)"
	$(DC) build --no-cache
	@echo "$(GREEN)✅ 构建完成$(NC)"

build-php: ## 仅重建PHP镜像
	@echo "$(YELLOW)🔨 重建PHP镜像...$(NC)"
	$(DC) build php
	@echo "$(GREEN)✅ PHP镜像构建完成$(NC)"

rebuild: ## 重建并重启服务
	@echo "$(YELLOW)🔨 重建并重启服务...$(NC)"
	$(DC) up -d --build
	@echo "$(GREEN)✅ 完成!$(NC)"

update: ## 拉取最新镜像并重启
	@echo "$(YELLOW)📥 拉取最新镜像...$(NC)"
	$(DC) pull
	$(DC) up -d
	@echo "$(GREEN)✅ 更新完成$(NC)"

## ========== 日志查看 ==========

logs: ## 查看所有服务日志(实时)
	$(DC) logs -f --tail=200

logs-nginx: ## 查看Nginx日志
	@echo "$(GREEN)📋 Nginx日志:$(NC)"
	$(DC) logs -f nginx --tail=100

logs-php: ## 查看PHP日志
	@echo "$(GREEN)📋 PHP日志:$(NC)"
	$(DC) logs -f php --tail=100

logs-db: ## 查看数据库日志
	@echo "$(GREEN)📋 数据库日志:$(NC)"
	$(DC) logs -f db --tail=100

clear-logs: ## 清空日志文件
	@echo "$(YELLOW)🗑️  清空日志文件...$(NC)"
	@sudo sh -c "> ./logs/nginx/access.log"
	@sudo sh -c "> ./logs/nginx/error.log"
	@sudo sh -c "> ./logs/php/error.log" 2>/dev/null || true
	@echo "$(GREEN)✅ 日志已清空$(NC)"

## ========== 进入容器 ==========

shell-php: ## 进入PHP容器Shell
	@echo "$(GREEN)🐚 进入PHP容器...$(NC)"
	@docker exec -it ${PROJECT}_php bash || docker exec -it ${PROJECT}_php sh

shell-nginx: ## 进入Nginx容器Shell
	@echo "$(GREEN)🐚 进入Nginx容器...$(NC)"
	@docker exec -it ${PROJECT}_nginx sh

shell-db: ## 进入数据库容器Shell
	@echo "$(GREEN)🐚 进入数据库容器...$(NC)"
	@docker exec -it ${PROJECT}_db bash || docker exec -it ${PROJECT}_db sh

db-cli: ## 进入数据库命令行(MySQL/MariaDB)
	@echo "$(GREEN)💾 连接数据库...$(NC)"
	@docker exec -it ${PROJECT}_db mariadb -uroot -p${DB_ROOT_PASSWORD} || \
		docker exec -it ${PROJECT}_db mysql -uroot -p${DB_ROOT_PASSWORD}

## ========== 测试与验证 ==========

test: ## 运行所有测试
	@echo "$(GREEN)🧪 运行测试套件...$(NC)"
	@$(MAKE) nginx-test
	@$(MAKE) php-version
	@$(MAKE) db-test
	@$(MAKE) health

nginx-test: ## 测试Nginx配置
	@echo "$(GREEN)🔍 测试Nginx配置...$(NC)"
	@docker exec ${PROJECT}_nginx nginx -t && \
		echo "$(GREEN)✅ Nginx配置正确$(NC)" || \
		echo "$(RED)❌ Nginx配置有误$(NC)"

php-version: ## 显示PHP版本和扩展
	@echo "$(GREEN)🐘 PHP版本信息:$(NC)"
	@docker exec ${PROJECT}_php php -v
	@echo ""
	@echo "$(GREEN)📦 已安装的PHP扩展:$(NC)"
	@docker exec ${PROJECT}_php php -m

db-test: ## 测试数据库连接
	@echo "$(GREEN)💾 测试数据库连接...$(NC)"
	@(docker exec ${PROJECT}_db mariadb -uroot -p${DB_ROOT_PASSWORD} -e "SELECT VERSION();" || \
		docker exec ${PROJECT}_db mysql -uroot -p${DB_ROOT_PASSWORD} -e "SELECT VERSION();") && \
		echo "$(GREEN)✅ 数据库连接正常$(NC)" || \
		echo "$(RED)❌ 数据库连接失败$(NC)"

health: ## 健康检查(检查所有服务是否正常)
	@echo "$(GREEN)🏥 健康检查:$(NC)"
	@echo -n "Nginx: "
	@docker exec ${PROJECT}_nginx sh -c "exit 0" 2>/dev/null && \
		echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"
	@echo -n "PHP:   "
	@docker exec ${PROJECT}_php php -v >/dev/null 2>&1 && \
		echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"
	@echo -n "DB:    "
	@(docker exec ${PROJECT}_db mariadb -uroot -p${DB_ROOT_PASSWORD} -e "SELECT 1;" >/dev/null 2>&1 || \
		docker exec ${PROJECT}_db mysql -uroot -p${DB_ROOT_PASSWORD} -e "SELECT 1;" >/dev/null 2>&1) && \
		echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"

## ========== 监控与统计 ==========

stats: ## 查看容器资源使用情况
	@echo "$(GREEN)📊 容器资源监控:$(NC)"
	@docker stats --no-stream ${PROJECT}_nginx ${PROJECT}_php ${PROJECT}_db

top: ## 查看容器进程
	@echo "$(GREEN)🔝 PHP容器进程:$(NC)"
	@docker top ${PROJECT}_php

network: ## 查看网络信息
	@echo "$(GREEN)🌐 网络信息:$(NC)"
	@docker network inspect ${PROJECT}_net

## ========== 数据库操作 ==========

backup: ## 备份数据库
	@echo "$(YELLOW)💾 备份数据库...$(NC)"
	@mkdir -p ./backups
	@docker exec ${PROJECT}_db mysqldump -uroot -p${DB_ROOT_PASSWORD} --all-databases | \
		gzip > ./backups/backup-$(shell date +%Y%m%d-%H%M%S).sql.gz
	@echo "$(GREEN)✅ 备份完成! 文件位于 ./backups/$(NC)"

backup-db: ## 备份指定数据库
	@echo "$(YELLOW)💾 备份数据库 ${DB_NAME}...$(NC)"
	@mkdir -p ./backups
	@docker exec ${PROJECT}_db mysqldump -uroot -p${DB_ROOT_PASSWORD} ${DB_NAME} | \
		gzip > ./backups/backup-${DB_NAME}-$(shell date +%Y%m%d-%H%M%S).sql.gz
	@echo "$(GREEN)✅ 备份完成!$(NC)"

restore: ## 恢复数据库(需指定文件: make restore FILE=backup.sql.gz)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)❌ 错误: 请指定备份文件! 例如: make restore FILE=./backups/backup-20251019.sql.gz$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)⚠️  准备恢复数据库...$(NC)"
	@echo "$(RED)警告: 这将覆盖现有数据!$(NC)"
	@read -p "确认恢复? [y/N] " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		(gunzip < $(FILE) | docker exec -i ${PROJECT}_db mariadb -uroot -p${DB_ROOT_PASSWORD} || \
		gunzip < $(FILE) | docker exec -i ${PROJECT}_db mysql -uroot -p${DB_ROOT_PASSWORD}); \
		echo "$(GREEN)✅ 数据库恢复完成!$(NC)"; \
	else \
		echo "$(YELLOW)已取消$(NC)"; \
	fi

db-list: ## 列出所有数据库
	@echo "$(GREEN)📋 数据库列表:$(NC)"
	@docker exec ${PROJECT}_db mariadb -uroot -p${DB_ROOT_PASSWORD} -e "SHOW DATABASES;" || \
		docker exec ${PROJECT}_db mysql -uroot -p${DB_ROOT_PASSWORD} -e "SHOW DATABASES;"

db-tables: ## 显示当前数据库的表
	@echo "$(GREEN)📋 数据库 ${DB_NAME} 的表:$(NC)"
	@docker exec ${PROJECT}_db mariadb -uroot -p${DB_ROOT_PASSWORD} -e "USE ${DB_NAME}; SHOW TABLES;" || \
		docker exec ${PROJECT}_db mysql -uroot -p${DB_ROOT_PASSWORD} -e "USE ${DB_NAME}; SHOW TABLES;"

## ========== 清理操作 ==========

clean: ## 清理未使用的资源
	@echo "$(YELLOW)🧹 清理Docker资源...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)✅ 清理完成$(NC)"

clean-all: ## 深度清理(包括卷和镜像)
	@echo "$(RED)⚠️  深度清理(会删除未使用的镜像和卷)$(NC)"
	@read -p "确认执行? [y/N] " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker system prune -af --volumes; \
		echo "$(GREEN)✅ 深度清理完成$(NC)"; \
	else \
		echo "$(YELLOW)已取消$(NC)"; \
	fi

## ========== 开发辅助 ==========

config: ## 显示完整配置(用于调试)
	@echo "$(GREEN)⚙️  当前配置:$(NC)"
	@$(DC) config

env: ## 显示环境变量
	@echo "$(GREEN)🔧 环境变量:$(NC)"
	@cat .env

validate: ## 验证配置文件
	@echo "$(GREEN)✅ 验证Docker Compose配置...$(NC)"
	@$(DC) config --quiet && \
		echo "$(GREEN)✅ 配置文件正确$(NC)" || \
		echo "$(RED)❌ 配置文件有误$(NC)"

