#!/bin/bash

# ===============================================
# Gensyn 一键安装脚本
# ===============================================

set -e  # 遇到错误时退出

# 显示横幅
show_banner() {
    echo -e "${GREEN}"
    cat << 'EOF'
██╗  ██╗██╗ █████╗  ██████╗ ██╗     ██╗███╗   ██╗
╚██╗██╔╝██║██╔══██╗██╔═══██╗██║     ██║████╗  ██║
 ╚███╔╝ ██║███████║██║   ██║██║     ██║██╔██╗ ██║
 ██╔██╗ ██║██╔══██║██║   ██║██║     ██║██║╚██╗██║
██╔╝ ██╗██║██║  ██║╚██████╔╝███████╗██║██║ ╚████║
╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝

    === Gensyn 自动化工具 ===
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}** ====================================== **${NC}"
    echo -e "${YELLOW}*         此脚本仅供免费使用              *${NC}"
    echo -e "${YELLOW}*         禁止出售或用于盈利              *${NC}"
    echo -e "${YELLOW}** ====================================== **${NC}"
    echo ""
    echo -e "${BLUE}* 作者: @YOYOMYOYOA${NC}"
    echo -e "${BLUE}* 空投玩家 | 现货玩家 | meme收藏${NC}"
    echo -e "${BLUE}* Github: github.com/mumumusf${NC}"
    echo ""
    echo -e "${RED}** ====================================== **${NC}"
    echo -e "${RED}*            免责声明                      *${NC}"
    echo -e "${RED}* 此脚本仅供学习交流使用                  *${NC}"
    echo -e "${RED}* 使用本脚本所产生的任何后果由用户自行承担 *${NC}"
    echo -e "${RED}* 如果因使用本脚本造成任何损失，作者概不负责*${NC}"
    echo -e "${RED}** ====================================== **${NC}"
    echo ""
}

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "请不要使用 root 用户运行此脚本"
        exit 1
    fi
}

# 检查系统是否为Ubuntu
check_ubuntu() {
    if ! grep -q "ubuntu" /etc/os-release; then
        log_error "此脚本仅支持 Ubuntu 系统"
        exit 1
    fi
}

# 检查并处理 Docker 权限
check_docker_permissions() {
    if ! groups | grep -q docker 2>/dev/null; then
        log_warning "当前用户不在 docker 组中"
        return 1
    fi
    return 0
}

# 安全删除目录（处理权限问题）
safe_remove_directory() {
    local dir_path="$1"
    local dir_name=$(basename "$dir_path")
    
    if [ -d "$dir_path" ]; then
        log_warning "$dir_name 目录已存在，正在删除..."
        # 尝试普通删除，如果失败则使用 sudo
        if ! rm -rf "$dir_path" 2>/dev/null; then
            log_warning "需要管理员权限删除文件..."
            if ! sudo rm -rf "$dir_path"; then
                log_error "无法删除 $dir_path 目录"
                return 1
            fi
        fi
        log_info "$dir_name 目录删除成功"
    fi
    return 0
}

# 安装基础工具
install_basic_tools() {
    log_info "开始安装基础工具..."
    
    # 安装 screen
    if ! command -v screen &> /dev/null; then
        log_info "安装 screen..."
        sudo apt update
        sudo apt install -y screen
        log_success "Screen 安装完成"
    else
        log_info "Screen 已安装，跳过"
    fi
    
    # 安装 curl 和其他基础工具
    log_info "安装基础依赖工具..."
    sudo apt update
    sudo apt install -y curl wget build-essential
    
    log_success "基础工具安装完成"
}

# 安装 NVM 和 Node.js
install_nvm_nodejs() {
    log_info "开始安装 NVM 和 Node.js 22..."
    
    # 1. 下载并安装 NVM
    log_info "下载并安装 NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    
    # 2. 重载环境变量
    log_info "重载环境变量..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # 3. 安装 Node.js 22
    log_info "安装 Node.js 22..."
    nvm install 22
    
    # 4. 使用 Node.js 22
    log_info "设置 Node.js 22 为默认版本..."
    nvm use 22
    nvm alias default 22
    
    # 5. 验证安装
    log_info "验证安装..."
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    NVM_CURRENT=$(nvm current)
    
    log_success "Node.js 安装完成"
    echo -e "  ${GREEN}Node.js 版本: ${NODE_VERSION}${NC}"
    echo -e "  ${GREEN}NPM 版本: ${NPM_VERSION}${NC}"
    echo -e "  ${GREEN}当前 NVM 版本: ${NVM_CURRENT}${NC}"
    
    # 6. 将 NVM 添加到 shell 配置文件
    log_info "配置 shell 环境..."
    
    # 检查是否已经添加到 .bashrc
    if ! grep -q "NVM_DIR" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# NVM configuration" >> ~/.bashrc
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
        log_info "已添加 NVM 配置到 ~/.bashrc"
    fi
    
    # 如果存在 .zshrc，也添加到 zsh 配置
    if [ -f ~/.zshrc ]; then
        if ! grep -q "NVM_DIR" ~/.zshrc; then
            echo "" >> ~/.zshrc
            echo "# NVM configuration" >> ~/.zshrc
            echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zshrc
            log_info "已添加 NVM 配置到 ~/.zshrc"
        fi
    fi
    
    log_success "NVM 和 Node.js 22 安装完成"
}

# 第一步：安装 Docker
install_docker() {
    log_info "开始安装 Docker..."
    
    # 1. 更新系统软件包
    log_info "更新系统软件包..."
    sudo apt update
    
    # 2. 安装依赖工具
    log_info "安装依赖工具..."
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
    
    # 3. 添加 Docker GPG 公钥
    log_info "添加 Docker GPG 公钥..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
    
    # 4. 添加 Docker 软件源
    log_info "添加 Docker 软件源..."
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 5. 更新软件包索引
    log_info "更新软件包索引..."
    sudo apt update
    
    # 6. 安装 Docker CE
    log_info "安装 Docker CE..."
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # 7. 设置 Docker 开机启动 & 立即启动
    log_info "设置 Docker 开机启动..."
    sudo systemctl enable --now docker
    
    # 8. 将当前用户添加到 docker 组
    log_info "将当前用户添加到 docker 组..."
    sudo usermod -aG docker $USER
    
    log_success "Docker 安装完成"
}

# 第二步：安装 NVIDIA Container Toolkit
install_nvidia_container_toolkit() {
    log_info "开始安装 NVIDIA Container Toolkit..."
    
    # 1. 添加 NVIDIA GPG 公钥
    log_info "添加 NVIDIA GPG 公钥..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    
    # 2. 添加 NVIDIA Container Toolkit 软件源
    log_info "添加 NVIDIA Container Toolkit 软件源..."
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
      | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
      | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
    
    # 3. 更新软件包索引
    log_info "更新软件包索引..."
    sudo apt update
    
    # 4. 安装 nvidia-container-toolkit
    log_info "安装 nvidia-container-toolkit..."
    sudo apt install -y nvidia-container-toolkit
    
    # 5. 配置 Docker 使用 NVIDIA Runtime
    log_info "配置 Docker 使用 NVIDIA Runtime..."
    sudo nvidia-ctk runtime configure --runtime=docker
    
    # 6. 重启 Docker 服务
    log_info "重启 Docker 服务..."
    sudo systemctl restart docker
    
    log_success "NVIDIA Container Toolkit 安装完成"
}

# 第三步：安装 NVIDIA 驱动
install_nvidia_drivers() {
    log_info "开始安装 NVIDIA 驱动..."
    
    # 1. 清除旧版 NVIDIA 驱动（可选）
    log_info "清除旧版 NVIDIA 驱动..."
    sudo apt remove --purge -y '^nvidia-.*' || true
    sudo apt autoremove -y || true
    
    # 2. 安装官方 CUDA keyring
    log_info "下载并安装 CUDA keyring..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    
    # 清理下载的文件
    log_info "清理临时文件..."
    rm -f cuda-keyring_1.1-1_all.deb
    
    # 3. 更新软件包索引
    log_info "更新软件包索引..."
    sudo apt update
    
    # 4. 安装 NVIDIA 驱动（包含 CUDA 支持）
    log_info "安装 NVIDIA 驱动..."
    sudo apt install -y cuda-drivers
    
    log_success "NVIDIA 驱动安装完成"
}

# 第四步：克隆 RL-Swarm 项目
clone_gensyn() {
    log_info "开始克隆 RL-Swarm 项目..."
    
    # 使用安全删除函数处理已存在的目录
    if ! safe_remove_directory "rl-swarm"; then
        log_error "无法删除已存在的 rl-swarm 目录"
        return 1
    fi
    
    log_info "正在克隆项目..."
    if ! git clone https://github.com/gensyn-ai/rl-swarm; then
        log_error "克隆 RL-Swarm 项目失败"
        return 1
    fi
    
    log_success "RL-Swarm 项目克隆完成"
}

# 第五步：设置 Screen 会话并运行
setup_and_run() {
    log_info "设置 RL-Swarm 运行环境..."
    
    # 确保 screen 已安装（基础工具安装时应该已经安装）
    if ! command -v screen &> /dev/null; then
        log_warning "Screen 未安装，正在安装..."
        sudo apt update
        sudo apt install -y screen
    fi
    
    # 检测 GPU 状态
    GPU_AVAILABLE=false
    if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
        GPU_AVAILABLE=true
        log_info "检测到 NVIDIA GPU"
    else
        log_warning "未检测到 NVIDIA GPU"
    fi
    
    # 让用户选择运行模式
    echo ""
    log_info "请选择运行模式："
    if [ "$GPU_AVAILABLE" = true ]; then
        echo "1) GPU 模式 (推荐，性能更好)"
        echo "2) CPU 模式"
        echo ""
        read -p "请输入选择 (1-2): " run_choice
        
        case $run_choice in
            1)
                DOCKER_COMMAND="docker compose run --rm --build -Pit swarm-gpu"
                RUN_MODE="GPU"
                log_info "已选择 GPU 模式运行"
                ;;
            2)
                DOCKER_COMMAND="docker compose run --rm --build -Pit swarm-cpu"
                RUN_MODE="CPU"
                log_info "已选择 CPU 模式运行"
                ;;
            *)
                log_warning "无效选择，默认使用 GPU 模式"
                DOCKER_COMMAND="docker compose run --rm --build -Pit swarm-gpu"
                RUN_MODE="GPU"
                ;;
        esac
    else
        echo "1) CPU 模式 (唯一可用选项)"
        echo ""
        read -p "按回车键继续使用 CPU 模式..."
        DOCKER_COMMAND="docker compose run --rm --build -Pit swarm-cpu"
        RUN_MODE="CPU"
        log_info "将使用 CPU 模式运行"
    fi
    
    log_info "创建启动脚本..."
    
    # 检查当前目录写权限
    if ! touch .test_write 2>/dev/null; then
        log_error "当前目录无写权限，无法创建启动脚本"
        return 1
    fi
    rm -f .test_write
    
    # 创建 CPU 模式启动脚本
    cat > start_swarm_cpu.sh << EOF
#!/bin/bash
echo "启动 RL-Swarm (CPU 模式)..."
screen -S swarm -dm bash -c "cd rl-swarm && docker compose run --rm --build -Pit swarm-cpu"
echo "RL-Swarm 已在 screen 会话 'swarm' 中启动 (CPU 模式)"
echo "使用 'screen -r swarm' 来连接到会话"
echo "使用 'screen -list' 来查看所有会话"
EOF
    
    # 创建 GPU 模式启动脚本（如果 GPU 可用）
    if [ "$GPU_AVAILABLE" = true ]; then
        cat > start_swarm_gpu.sh << EOF
#!/bin/bash
echo "启动 RL-Swarm (GPU 模式)..."
screen -S swarm -dm bash -c "cd rl-swarm && docker compose run --rm --build -Pit swarm-gpu"
echo "RL-Swarm 已在 screen 会话 'swarm' 中启动 (GPU 模式)"
echo "使用 'screen -r swarm' 来连接到会话"
echo "使用 'screen -list' 来查看所有会话"
EOF
        chmod +x start_swarm_gpu.sh
    fi
    
    # 创建默认启动脚本（基于用户选择）
    cat > start_swarm.sh << EOF
#!/bin/bash
echo "启动 RL-Swarm ($RUN_MODE 模式)..."
screen -S swarm -dm bash -c "cd rl-swarm && $DOCKER_COMMAND"
echo "RL-Swarm 已在 screen 会话 'swarm' 中启动 ($RUN_MODE 模式)"
echo "使用 'screen -r swarm' 来连接到会话"
echo "使用 'screen -list' 来查看所有会话"
EOF
    
    chmod +x start_swarm_cpu.sh
    chmod +x start_swarm.sh
    
    log_success "准备完成！"
    
    # 询问是否立即启动
    echo ""
    log_info "是否立即启动 RL-Swarm ($RUN_MODE 模式)？"
    echo "1) 是，立即启动"
    echo "2) 否，稍后手动启动"
    echo ""
    read -p "请输入选择 (1-2): " start_choice
    
    case $start_choice in
        1)
            log_info "正在启动 RL-Swarm ($RUN_MODE 模式)..."
            
            # 检查 Docker 权限
            if ! check_docker_permissions; then
                log_info "正在使用 sg 命令获取 docker 组权限..."
                echo ""
                log_info "即将进入 RL-Swarm 运行界面 ($RUN_MODE 模式)"
                echo -e "  ${YELLOW}提示：${NC}"
                echo -e "  - 使用 ${GREEN}Ctrl+A 然后按 D${NC} 来分离会话（不关闭程序）"
                echo -e "  - 使用 ${GREEN}exit${NC} 或 ${GREEN}Ctrl+C${NC} 来完全退出程序"
                echo -e "  - 分离后可用 ${GREEN}screen -r swarm${NC} 重新连接"
                echo ""
                read -p "按回车键启动并进入 RL-Swarm..."
                
                # 在新的 shell 中启动，避免权限问题
                exec sg docker -c "cd rl-swarm && exec screen -S swarm bash -c '$DOCKER_COMMAND'"
            else
                log_info "Docker 组权限已生效"
            fi
            
            # 检查是否已有同名会话
            if screen -list 2>/dev/null | grep -q "swarm"; then
                log_warning "检测到已存在的 'swarm' 会话，正在终止..."
                screen -S swarm -X quit 2>/dev/null || true
                sleep 2
            fi
            
                         # 启动 RL-Swarm
            cd rl-swarm
            
            log_success "RL-Swarm 正在启动..."
            echo ""
            log_info "即将进入 RL-Swarm 运行界面 ($RUN_MODE 模式)"
            echo -e "  ${YELLOW}提示：${NC}"
            echo -e "  - 使用 ${GREEN}Ctrl+A 然后按 D${NC} 来分离会话（不关闭程序）"
            echo -e "  - 使用 ${GREEN}exit${NC} 或 ${GREEN}Ctrl+C${NC} 来完全退出程序"
            echo -e "  - 分离后可用 ${GREEN}screen -r swarm${NC} 重新连接"
            echo ""
            read -p "按回车键启动并进入 RL-Swarm..."
            
            # 直接启动并连接，不使用后台模式
            exec screen -S swarm bash -c "$DOCKER_COMMAND"
            ;;
        2)
            log_info "您可以稍后使用以下命令启动："
            echo -e "  ${GREEN}./start_swarm.sh${NC}           # 启动 RL-Swarm ($RUN_MODE 模式)"
            echo -e "  ${GREEN}./start_swarm_cpu.sh${NC}       # 强制使用 CPU 模式"
            if [ "$GPU_AVAILABLE" = true ]; then
                echo -e "  ${GREEN}./start_swarm_gpu.sh${NC}       # 强制使用 GPU 模式"
            fi
            echo -e "  ${GREEN}screen -r swarm${NC}           # 连接到运行中的会话"
            echo -e "  ${GREEN}screen -list${NC}              # 查看所有 screen 会话"
            echo ""
            log_info "或者手动运行："
            echo -e "  ${GREEN}screen -S swarm${NC}"
            echo -e "  ${GREEN}cd rl-swarm${NC}"
            echo -e "  ${GREEN}# CPU 模式：${NC}docker compose run --rm --build -Pit swarm-cpu"
            if [ "$GPU_AVAILABLE" = true ]; then
                echo -e "  ${GREEN}# GPU 模式：${NC}docker compose run --rm --build -Pit swarm-gpu"
            fi
            ;;
        *)
            log_warning "无效选择，默认不启动。您可以稍后手动启动。"
            ;;
    esac
}

# 主函数
main() {
    # 显示横幅
    show_banner
    
    log_info "开始 Gensyn 一键安装..."
    
    # 检查系统
    check_root
    check_ubuntu
    
    # 开始完整安装
    log_info "开始一键安装 RL-Swarm 完整环境..."
    echo ""
    log_info "将安装以下组件："
    echo "  ✓ 基础开发工具 (Screen、Curl、Build-essential)"
    echo "  ✓ NVM 和 Node.js 22"
    echo "  ✓ Docker CE"
    echo "  ✓ NVIDIA Container Toolkit"
    echo "  ✓ NVIDIA 驱动程序"
    echo "  ✓ RL-Swarm 项目"
    echo ""
    read -p "按回车键开始安装，或按 Ctrl+C 取消..."
    
    # 执行完整安装
    install_basic_tools
    install_nvm_nodejs
    install_docker
    install_nvidia_container_toolkit
    install_nvidia_drivers
    clone_gensyn
    setup_and_run
    
    echo ""
    log_success "安装完成！"
    log_warning "注意：如果安装了新的 Docker 或 NVIDIA 驱动，建议重启系统以确保所有组件正常工作"
    
    log_info "由于用户被添加到 docker 组，您可能需要重新登录或运行以下命令："
    echo -e "  ${GREEN}newgrp docker${NC}"
    
    echo ""
    log_info "Node.js 开发环境已配置完成！"
    log_info "使用 'node -v' 和 'npm -v' 验证安装"
}

# 运行主函数
main "$@"