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
如果使用云服务器或 VPS，需要使用隧道工具将本地端口暴露到外网：

1. **保持项目运行**
   - 确保 Gensyn 项目在后台运行
   - 项目应该监听在 `localhost:3000`

2. **打开新终端窗口**
   - 不要关闭运行 Gensyn 的终端
   - 在新终端中执行以下步骤

3. **安装 localtunnel**
```bash
npm install -g localtunnel
```
如果安装失败，可以尝试：
```bash
sudo npm install -g localtunnel
```

4. **获取隧道密码**
```bash
curl https://loca.lt/mytunnelpassword
```
**重要说明**：
- 返回的密码实际上就是您的 VPS 公网 IP 地址
- 例如：如果您的 VPS IP 是 `123.45.67.89`，密码就是 `123.45.67.89`
- 请记住这个密码，稍后访问网站时需要输入

5. **创建隧道**
```bash
lt --port 3000
```
命令执行后会显示类似这样的输出：
```
your url is: https://smooth-goose-12.loca.lt
```

6. **访问项目**
   - 复制上面显示的 URL（例如：`https://smooth-goose-12.loca.lt`）
   - 在浏览器中打开这个 URL
   - 首次访问会要求输入密码，输入步骤4获取的密码（您的VPS IP）
   - 验证通过后即可看到 Gensyn 登录页面

**注意事项**：
- 隧道 URL 每次都不同，重新运行会生成新的随机 URL
- 保持终端运行，关闭终端隧道会断开
- 如果隧道断开，重新执行 `lt --port 3000` 即可

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