# Gensyn 一键安装脚本

这是一个用于快速部署 Gensyn 的一键安装脚本，**专为 Ubuntu/Linux 系统设计**。

## 系统要求

### CPU 模式
- **处理器**: ARM64 或 x86 CPU
- **内存**: 32GB RAM（推荐）
- **注意**: 训练期间请避免运行其他应用程序，以免导致训练崩溃

### GPU 模式（推荐）
- **支持的 GPU**:
  - RTX 3090
  - RTX 4090
  - RTX 5090
  - A100
  - H100
- **显存要求**: 
  - 推荐 ≥24GB vRAM
  - 也支持 <24GB vRAM 的 GPU
- **CUDA 驱动**: ≥12.4 版本

## 快速开始

### 1. 克隆 Gensyn 项目
```bash
git clone https://github.com/mumumusf/Gensyn
cd Gensyn
```

### 2. 运行安装脚本
```bash
chmod +x install_swarm.sh
./install_swarm.sh
```

### 3. 运行项目
```bash
# 按照项目说明启动服务
npm install
npm start
```

## 访问项目

### 本地访问
成功启动后，在浏览器中打开：
```
http://localhost:3000/
```

### 云服务器/VPS 访问
如果使用云服务器或 VPS，需要使用隧道工具：

1. **打开新终端**

2. **安装 localtunnel**
```bash
npm install -g localtunnel
```

3. **获取隧道密码**
```bash
curl https://loca.lt/mytunnelpassword
```
注意：密码就是您的 VPS IP 地址

4. **创建隧道**
```bash
lt --port 3000
```

5. **访问项目**
打开提示的 URL，进入 Gensyn 登录页面

## HuggingFace 设置

### 1. 注册账号
访问 [https://huggingface.co/](https://huggingface.co/) 注册账号

### 2. 获取 Access Token
1. 登录 HuggingFace
2. 前往设置页面
3. 创建新的 Access Token
4. **重要**: 确保令牌具有**写入权限**

### 3. 在项目中配置
将获取的 Token 配置到 Gensyn 项目中

## 故障排除

### CUDA 驱动检查
```bash
nvidia-smi
```

### GPU 状态确认
```bash
nvidia-ml-py3
```

### Docker 权限问题
```bash
newgrp docker
```

## 支持

如遇问题，请检查：
1. 系统是否满足最低要求
2. CUDA 驱动版本是否 ≥12.4
3. 网络连接是否稳定
4. HuggingFace Token 是否具有写入权限 