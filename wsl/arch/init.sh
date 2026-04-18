#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以 root 权限运行" 
   exit 1
fi

# 检查软件包并安装的函数
check_and_install() {
    for pkg in "$@"; do
        if pacman -Qs "^$pkg$" > /dev/null; then
            echo "软件包 $pkg 已安装，跳过。"
        else
            echo "正在安装 $pkg ..."
            pacman -S --noconfirm "$pkg"
        fi
    done
}

echo "--- 1. 更新系统和安装基础软件包 ---"
pacman -Sy --noconfirm
check_and_install sudo vim git openssh lazygit tmux zsh thefuck

echo "--- 2. 创建用户 aaa ---"
if id "aaa" &>/dev/null; then
    echo "用户 aaa 已存在，跳过创建。"
else
    useradd -m -G wheel -s /bin/bash aaa
    echo "aaa:1" | chpasswd
    echo "用户 aaa 创建成功。"
fi

echo "--- 3. 配置 visudo ---"
# 使用 grep 检查是否已经取消了注释，防止重复写入
if grep -q "^%wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
    echo "sudoers 配置已存在，跳过。"
else
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi

echo "--- 4. 配置 SSH 密钥 ---"
read -p "请输入宿主机Windows用户名: " win_user
read -p "请输入SSH私钥文件名(如 id_rsa): " ssh_key_name
SSH_SOURCE_DIR="/mnt/c/Users/${win_user}/.ssh"
TARGET_DIR="/home/aaa/.ssh"

if [ -f "${SSH_SOURCE_DIR}/${ssh_key_name}" ]; then
    mkdir -p "${TARGET_DIR}"
    cp "${SSH_SOURCE_DIR}/${ssh_key_name}" "${TARGET_DIR}/id_rsa"
    chmod 700 "${TARGET_DIR}"
    chmod 600 "${TARGET_DIR}/id_rsa"
    chown -R aaa:aaa /home/aaa
    echo "SSH 密钥已配置。"
else
    echo "警告: 未找到密钥文件，跳过 SSH 配置。"
fi

echo "--- 5. 设置 Git 用户信息 ---"
read -p "请输入 Git 用户名: " git_name
read -p "请输入 Git 邮箱: " git_email

echo "--- 6. 配置 Git dotfiles 环境 ---"
read -p "请输入 GitHub 仓库地址 (git@github.com:username/repo.git): " repo_url

su - aaa <<EOF
git config --global user.name "$git_name"
git config --global user.email "$git_email"

# 定义 config 函数
config() { /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"; }

export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"

# 克隆仓库
if [ ! -d "\$HOME/.cfg" ]; then
    git clone --bare "$repo_url" \$HOME/.cfg
else
    echo "仓库目录已存在，跳过克隆。"
fi

# 使用配置命令
config config --local status.showUntrackedFiles no
echo ".cfg" >> \$HOME/.gitignore

# 备份与检出
mkdir -p \$HOME/.config-backup
config checkout 2>&1 | grep -E "\s+\." | awk {'print \$1'} | xargs -I{} mv {} .config-backup/{}
config checkout
EOF

echo "--- 7. 安装 Homebrew、Tmux 环境及 Oh My Zsh ---"
su - aaa <<EOF
# 1. 安装 Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 2. 安装 Brew 依赖 (需 sudo 权限，假设aaa已在wheel组)
# 注意：base-devel 在 Arch 中可能部分已装，此处确保全覆盖
sudo pacman -S --noconfirm base-devel
brew install gcc

# 3. 安装 Tmux TPM
if [ ! -d "~/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# 4. 安装 Oh My Zsh (需提前安装 zsh)
sudo pacman -S --noconfirm zsh
if [ ! -d "~/.oh-my-zsh" ]; then
    sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 5. 安装 Zsh 插件
ZSH_CUSTOM=\${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

git clone https://github.com/zsh-users/zsh-autosuggestions \$ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git \$ZSH_CUSTOM/plugins/zsh-autocomplete
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting

echo "环境补充配置完成。"
EOF

echo "配置完成！"
