# Hygieia - 智能醫療系統部署工具

**企業級智能部署解決方案，10 秒極速啟動醫療系統**

## 🚀 一鍵安裝

```bash
curl -fsSL https://github.com/WeeMed/hygieia/releases/download/v1.0.0/install.sh | bash
```

## ✨ 核心特色

- **⚡ 極速部署**: 10 秒啟動，0 秒等待資料庫
- **🧠 智能自動化**: 自動檢測並修復 90% 常見問題
- **🌍 多語言界面**: 繁體中文 / English TUI 操作
- **🔧 簡單易用**: 3 步完成部署，無需 DevOps 知識
- **📦 多產品支援**: hi-care, hi-hope, hi-checkup 醫療系統

## 🎯 適用場景

- **醫療機構**: 快速部署電子病歷、健檢系統
- **軟體公司**: 向客戶交付醫療解決方案
- **系統整合商**: 簡化醫療系統部署流程

## 📋 系統需求

- **作業系統**: Linux (Ubuntu 20.04+) 或 macOS
- **記憶體**: 4GB+ RAM (推薦 8GB+)
- **硬碟**: 20GB+ 可用空間
- **容器**: Docker 24.0+ & Docker Compose 2.24+

## 🚀 部署步驟

### 1. 安裝 Hygieia CLI

```bash
curl -fsSL https://github.com/WeeMed/hygieia/releases/download/v1.0.0/install.sh | bash
```

### 2. 初始化配置

```bash
mkdir my-medical-system
cd my-medical-system
hygieia init
```

TUI 介面會引導您：

- 選擇醫療產品（hi-care/hi-hope/hi-checkup）
- 配置域名和 SSL
- 設定組織資訊

### 3. 一鍵部署

```bash
hygieia deploy up
```

**就這麼簡單！系統會自動：**

- 下載所需容器映像
- 配置資料庫和網路
- 設定 SSL 憑證（可選）
- 啟動所有服務

## 📖 詳細文檔

- [📥 下載安裝指南](https://github.com/WeeMed/hygieia/releases/download/v1.0.0/DOWNLOAD.md)
- [📋 版本發布說明](https://github.com/WeeMed/hygieia/releases/download/v1.0.0/RELEASE_NOTES.md)
- [⚙️ 詳細安裝說明](https://github.com/WeeMed/hygieia/releases/download/v1.0.0/INSTALL.md)

## 🔧 常用指令

```bash
hygieia --help          # 查看所有指令
hygieia init            # 初始化專案
hygieia deploy up       # 部署系統
hygieia deploy down     # 停止系統
hygieia dev status      # 查看狀態
hygieia dev logs        # 查看日誌
hygieia backup create   # 備份資料
hygieia snapshot create # 生成快照
```

## 🆘 技術支援

如遇到問題，請查看：

1. **智能診斷**: `hygieia dev status` 自動檢測問題
2. **日誌分析**: `hygieia dev logs` 查看詳細錯誤
3. **重置系統**: `hygieia deploy down && hygieia deploy up`

**內建智能功能會自動解決大部分常見問題！**

## 📊 支援的醫療系統

| 產品           | 功能         | 適用場景           |
| -------------- | ------------ | ------------------ |
| **hi-care**    | 電子病歷管理 | 診所、醫院         |
| **hi-hope**    | 健康風險評估 | 健檢中心、預防醫學 |
| **hi-checkup** | 智能健檢系統 | 企業健檢、個人健康 |

---

## 🏢 關於 WeeMed

WeeMed 致力於提供企業級醫療資訊解決方案，讓複雜的系統部署變得簡單高效。

**企業諮詢與技術支援**: 聯繫 WeeMed 技術團隊

---

_Hygieia - 讓醫療系統部署如呼吸般自然 🌟_
