# 运维问题解决文档索引

> 📚 本目录用于记录项目运维过程中遇到的问题和解决方案
> 💡 每个问题都有详细的排查流程、根因分析和解决方案
> 🎯 帮助快速定位和解决类似问题

---

## 📋 问题列表

### 网络相关问题

#### 1. [Docker 容器外网无法访问 - iptables FORWARD 规则缺失](./Docker外网无法访问-iptables-FORWARD规则缺失.md)
- **问题级别：** 🔴 严重
- **解决日期：** 2025-10-17
- **关键词：** `Docker`, `iptables`, `FORWARD`, `华为云`, `NAT`, `网络转发`
- **现象：** 本地和内网可访问，公网无法访问
- **根因：** iptables FORWARD 链缺少 Docker 自定义网络规则
- **解决方案：** 添加 iptables 转发规则并持久化

---

## 🔍 快速索引

### 按问题类型分类

#### 🌐 网络问题
- [Docker 外网无法访问](./Docker外网无法访问-iptables-FORWARD规则缺失.md)

#### 🐳 Docker 问题
- [Docker 外网无法访问](./Docker外网无法访问-iptables-FORWARD规则缺失.md)

#### 🔐 安全问题
- 待添加...

#### 📊 性能问题
- 待添加...

#### 💾 数据库问题
- 待添加...

---

## 📖 使用指南

### 如何查找问题解决方案？

1. **按关键词搜索**
   ```bash
   # 在当前目录搜索关键词
   grep -r "关键词" ./*.md
   ```

2. **按问题类型查找**
   - 参考上方的「按问题类型分类」索引

3. **按时间查找**
   - 查看文件创建日期或文档内的「解决日期」

### 如何添加新问题文档？

1. **创建文档**
   - 在本目录下创建新的 Markdown 文件
   - 文件命名格式：`问题简述-关键原因.md`
   - 例如：`Nginx-502错误-PHP-FPM超时.md`

2. **使用统一模板**
   ```markdown
   # 问题标题

   > **解决日期：** YYYY-MM-DD
   > **问题级别：** 🔴/🟡/🟢
   > **解决状态：** ✅/🔄/❌

   ## 📋 问题描述
   ### 环境信息
   ### 故障现象

   ## 🔍 问题根因分析

   ## ✅ 解决方案

   ## 🧪 验证测试

   ## 📚 知识扩展

   ## 🎯 总结
   ```

3. **更新索引**
   - 在本 README.md 中添加链接
   - 更新相应的分类索引

---

## 🛠️ 常用诊断工具

### 网络诊断
```bash
# 端口监听检查
ss -tlnp | grep :端口号
netstat -tlnp | grep :端口号

# 网络连接测试
curl -v http://IP:PORT
telnet IP PORT
nc -zv IP PORT

# 路由追踪
traceroute IP
mtr IP

# DNS 解析
nslookup 域名
dig 域名
```

### Docker 诊断
```bash
# 容器状态
docker ps -a
docker stats

# 容器日志
docker logs <container_name>
docker logs -f --tail 100 <container_name>

# 网络检查
docker network ls
docker network inspect <network_name>

# 进入容器
docker exec -it <container_name> sh
```

### 系统诊断
```bash
# 防火墙状态
sudo iptables -L -n -v --line-numbers
sudo systemctl status firewalld
sudo systemctl status ufw

# 系统资源
top
htop
df -h
free -h

# 系统日志
sudo journalctl -xe
sudo tail -f /var/log/syslog
```

---

## 📊 问题统计

| 类型 | 数量 | 最新更新 |
|------|------|----------|
| 网络问题 | 1 | 2025-10-17 |
| Docker 问题 | 1 | 2025-10-17 |
| 安全问题 | 0 | - |
| 性能问题 | 0 | - |
| 数据库问题 | 0 | - |
| **总计** | **1** | **2025-10-17** |

---

## 💡 最佳实践

### 问题记录原则
1. ✅ **及时记录** - 问题解决后立即编写文档
2. ✅ **详细完整** - 包含现象、根因、方案、验证
3. ✅ **可复现** - 提供完整的命令和配置示例
4. ✅ **持续更新** - 发现更好的解决方案时更新文档

### 预防措施
1. 📝 定期备份关键配置
2. 📊 监控系统状态和日志
3. 🔄 定期更新系统和软件
4. 🧪 在测试环境先验证变更
5. 📖 保持文档与实际环境同步

---

## 🔗 相关资源

### 官方文档
- [Docker 官方文档](https://docs.docker.com/)
- [Nginx 官方文档](https://nginx.org/en/docs/)
- [PHP 官方文档](https://www.php.net/docs.php)
- [MariaDB 官方文档](https://mariadb.com/kb/en/)

### 运维工具
- [Portainer](https://www.portainer.io/) - Docker 可视化管理
- [Netdata](https://www.netdata.cloud/) - 系统监控
- [Grafana](https://grafana.com/) - 数据可视化

### 学习资源
- [Docker — 从入门到实践](https://yeasy.gitbook.io/docker_practice/)
- [Linux 运维指南](https://linuxops.org/)
- [运维之美](https://www.opsdev.cn/)

---

## 📞 联系方式

如有问题或建议，欢迎反馈！

**文档维护：** 哈雷酱（大小姐）
**创建日期：** 2025-10-17
**最后更新：** 2025-10-17

---

> 💝 "预防胜于治疗，记录胜于遗忘！"
> —— 哈雷酱的运维格言 (￣▽￣)／
