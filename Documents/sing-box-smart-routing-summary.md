# Sing-box 智能分流配置总结

## 概述
本文档总结了在 Arch Linux 系统上配置 Sing-box 代理并实现智能分流（国内直连/国外代理）的完整过程。配置已通过测试验证，所有功能正常工作。

## 系统环境
- **操作系统**: Arch Linux
- **代理软件**: Sing-box
- **配置文件**: `/etc/sing-box/config.json`
- **原始配置**: `/run/media/zane/Data/txt/config.json`

## 关键配置修改

### 1. DNS 配置修复（Sing-box 1.12.0+ 新格式）
**问题**: 原始配置使用已弃用的 `address_resolver` 字段
**修复**: 改为新的 `type` + `server` 格式

```json
// 修复前（已弃用）:
{
  "type": "https",
  "server": "1.1.1.1",
  "address_resolver": "dns_resolver",  // 已弃用
  "detour": "手动切换"
}

// 修复后（新格式）:
{
  "type": "https",
  "server": "1.1.1.1",
  "tag": "dns_proxy",
  "detour": "手动切换"
}
```

### 2. TUN 配置修复（Sing-box 1.10.0+ 新格式）
**问题**: 使用已弃用的 `inet4_address`/`inet6_address` 字段
**修复**: 合并为 `address` 数组格式

```json
// 修复前（已弃用）:
{
  "type": "tun",
  "inet4_address": "172.19.0.1/30",
  "inet6_address": "fdfe:dcba:9876::1/126"
}

// 修复后（新格式）:
{
  "type": "tun",
  "address": ["172.19.0.1/30", "fdfe:dcba:9876::1/126"]
}
```

### 3. 智能分流关键修复
**问题**: 所有流量都走代理，智能分流失效
**修复步骤**:

1. **修改 Clash API 模式**:
   ```json
   // 修复前:
   "default_mode": "global"  // 全局代理模式

   // 修复后:
   "default_mode": "rule"    // 智能分流模式
   ```

2. **移除 DNS 配置中的 clash_mode 规则**:
   ```json
   // 移除这两条规则:
   {
     "clash_mode": "direct",
     "server": "dns_cn"
   },
   {
     "clash_mode": "global",
     "server": "dns_proxy"
   }
   ```

3. **保留基于规则集的 DNS 分流**:
   ```json
   {
     "rule_set": ["geosite-cn", "geoip-cn"],
     "server": "dns_cn"  // 中国域名使用国内DNS
   },
   {
     "rule_set": "geosite-geolocation-!cn",
     "server": "dns_proxy"  // 非中国域名使用代理DNS
   }
   ```

### 4. 路由规则配置
智能分流的核心路由规则：

```json
"rules": [
  // 广告拦截
  {
    "action": "reject",
    "rule_set": "geosite-category-ads-all"
  },

  // 特定服务专用代理
  {"outbound": "Telegram", "rule_set": "geosite-telegram"},
  {"outbound": "YouTube", "rule_set": "geosite-youtube"},
  {"outbound": "Netflix", "rule_set": "geosite-netflix"},
  {"outbound": "OpenAI", "rule_set": "geosite-openai"},

  // 私有网络直连
  {
    "ip_cidr": ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"],
    "outbound": "direct"
  },

  // TUN 网络直连
  {
    "ip_cidr": ["172.19.0.0/30", "fdfe:dcba:9876::/126"],
    "outbound": "direct"
  },

  // 中国流量直连
  {
    "outbound": "direct",
    "rule_set": ["geosite-cn", "geoip-cn"]
  },

  // 非中国流量走代理
  {
    "outbound": "手动切换",
    "rule_set": "geosite-geolocation-!cn"
  }
]
```

## 安装和配置步骤

### 1. 安装 Sing-box
```bash
# Arch Linux
sudo pacman -S sing-box

# 其他系统请参考官方文档
```

### 2. 配置文件位置
```bash
# 主配置文件
/etc/sing-box/config.json

# 数据目录
/var/lib/sing-box/
```

### 3. 服务管理
```bash
# 启动服务
sudo systemctl start sing-box

# 启用开机自启
sudo systemctl enable sing-box

# 查看状态
systemctl status sing-box

# 查看日志
journalctl -u sing-box -f
```

## 使用说明

### 1. 代理接入方式
- **TUN 模式（推荐）**: 透明代理，所有流量自动路由
  - 接口: `tun0`
  - IP: `172.19.0.1/30`
  - 自动生效，无需应用配置

- **SOCKS5 代理**:
  - 地址: `127.0.0.1:12080`
  - 注意: `set_system_proxy: false`，需手动配置系统代理

### 2. 管理界面
- **Yacd 面板**: http://127.0.0.1:12081
- **功能**: 连接管理、代理切换、流量统计
- **默认模式**: `rule`（智能分流）

### 3. 规则集更新
规则集自动更新频率：
- 中国规则: 每天更新
- 服务规则（Telegram/YouTube等）: 每周更新
- 广告规则: 每天更新

## 测试验证方法

### 1. 基本功能测试
```bash
# 测试国内网站（应走直连）
curl -I https://www.baidu.com
curl -I https://www.taobao.com

# 测试国外网站（应走代理）
curl -I https://www.google.com
curl -I https://www.youtube.com
```

### 2. 分流效果验证
```bash
# 查看直连流量日志
journalctl -u sing-box | grep "outbound/direct"

# 查看代理流量日志
journalctl -u sing-box | grep "outbound/shadowsocks"

# 实时监控日志
journalctl -u sing-box -f
```

### 3. DNS 解析测试
```bash
# 测试DNS解析（需要dig工具）
# 国内域名应解析到国内IP
# 国外域名应解析到国外IP
```

## 故障排除

### 常见问题

#### 1. 服务启动失败
```bash
# 检查配置文件语法
sudo sing-box check -C /etc/sing-box

# 查看详细错误日志
sudo systemctl status sing-box --no-pager
```

#### 2. 智能分流失效（所有流量走代理）
**可能原因**:
- DNS 配置中还有 `clash_mode` 规则
- Clash API 模式不是 `"rule"`
- DNS 解析全部走代理

**解决方法**:
1. 检查并移除 DNS 规则中的 `clash_mode`
2. 确认 `default_mode` 设置为 `"rule"`
3. 验证 DNS 分流规则

#### 3. 国内网站无法访问
**可能原因**:
- 国内 DNS 服务器不可用
- 规则集下载失败
- 路由规则配置错误

**解决方法**:
```bash
# 检查规则集下载
ls -la /var/lib/sing-box/*.srs

# 测试国内DNS连通性
curl -I https://dns.alidns.com  # 检查HTTP响应头
# 或使用更详细的测试
curl -s -o /dev/null -w "状态码: %{http_code}\n" https://dns.alidns.com

# 重启服务重新下载规则集
sudo systemctl restart sing-box
```

#### 4. TUN 模式不工作
**检查项目**:
```bash
# 检查tun接口
ip addr show tun0

# 检查路由表
ip route show

# 检查系统日志
dmesg | grep tun
```

## 配置文件备份和恢复

### 备份配置
```bash
# 备份当前配置
sudo cp /etc/sing-box/config.json ~/sing-box-config-backup-$(date +%Y%m%d).json

# 备份规则集
sudo tar -czf ~/sing-box-data-backup-$(date +%Y%m%d).tar.gz /var/lib/sing-box/
```

### 恢复配置
```bash
# 恢复配置文件
sudo cp ~/sing-box-config-backup.json /etc/sing-box/config.json

# 恢复后重启服务
sudo systemctl restart sing-box
```

## 性能优化建议

### 1. 缓存配置
```json
"experimental": {
  "cache_file": {
    "enabled": true  // 启用缓存提升性能
  }
}
```

### 2. 连接参数优化
```json
{
  "idle_timeout": "10m",
  "interrupt_exist_connections": true,
  "interval": "3m"
}
```

### 3. MTU 设置
```json
{
  "mtu": 9000  // 根据网络环境调整
}
```

## 安全注意事项

1. **配置文件权限**: 确保配置文件只有 root 可写
   ```bash
   sudo chmod 644 /etc/sing-box/config.json
   sudo chown root:root /etc/sing-box/config.json
   ```

2. **服务权限**: Sing-box 以非特权用户运行
3. **日志管理**: 定期清理日志文件
4. **规则集验证**: 只使用可信的规则集源

## 更新和维护

### 定期维护任务
1. **检查更新**: `sudo pacman -Syu`
2. **清理缓存**: `sudo journalctl --vacuum-time=7d`
3. **验证配置**: `sudo sing-box check -C /etc/sing-box`
4. **备份配置**: 每月备份一次配置文件

### 版本升级注意事项
- 主要版本升级可能涉及配置格式变更
- 升级前务必备份配置和数据
- 参考官方迁移指南：https://sing-box.sagernet.org

## 参考资料
1. [Sing-box 官方文档](https://sing-box.sagernet.org)
2. [规则集仓库](https://github.com/SagerNet/sing-geosite)
3. [Yacd 管理面板](https://github.com/haishanh/yacd)
4. [Arch Linux 包信息](https://archlinux.org/packages/extra/x86_64/sing-box/)

---
*文档最后更新: 2026-01-10*
*配置已验证通过，所有功能正常工作*