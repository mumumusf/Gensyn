# Gensyn 环境安装指南

快速部署 Gensyn 的安装指南，适用于 Ubuntu/Linux 系统。

## 系统要求

- **CPU**: ARM64 或 x86，32GB RAM
- **GPU**: RTX 3090/4090/5090, A100, H100（推荐 ≥24GB 显存）
- **CUDA**: ≥12.4 驱动版本

## 快速安装

**第一步：安装基础环境**
```bash
sudo apt update
sudo apt install -y screen curl wget build-essential
```

**第二步：安装 Node.js 22**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
```

**第三步：安装 Docker**
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

**第四步：安装 NVIDIA Container Toolkit（GPU用户）**
```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

**第五步：安装 NVIDIA 驱动（包含 CUDA 支持）**
```bash
sudo apt install -y cuda-drivers
```

**安装完成后，请重启系统：**
```bash
sudo reboot
```

**第六步：克隆项目**
```bash
git clone https://github.com/gensyn-ai/rl-swarm
cd rl-swarm
```

## 运行项目

```bash
# 创建新的 screen 会话
screen -S swarm

# 在会话中运行以下命令：
cd rl-swarm

# CPU 模式
docker compose run --rm --build -Pit swarm-cpu

# 或 GPU 模式
docker compose run --rm --build -Pit swarm-gpu
```

**Screen 会话管理：**
```bash
# Ctrl+A 然后按 D              # 分离会话（保持后台运行）
screen -list                    # 查看所有会话
screen -r swarm                 # 重新连接到会话
```

## 访问项目

**本地访问：** `http://localhost:3000/`

**云服务器访问：**
```bash
# 安装隧道工具
npm install -g localtunnel

# 获取密码（即您的VPS IP）
curl https://loca.lt/mytunnelpassword

# 创建隧道
lt --port 3000

# 访问显示的URL，输入VPS IP作为密码
```

## HuggingFace 设置

1. 注册账号：[https://huggingface.co/](https://huggingface.co/)
2. 创建 Access Token（需要写入权限）
3. 在项目中配置 Token

## 常见问题

```bash
# 检查GPU状态
nvidia-smi

# Docker权限问题
newgrp docker

# 重启服务
sudo systemctl restart docker
```

---
⚠️ **重要：安装完成后必须重启系统以激活 NVIDIA 驱动** 