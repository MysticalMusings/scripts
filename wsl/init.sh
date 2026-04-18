#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以 root 权限运行" 
   exit 1
fi

# 1. 自动检测发行版并设置变量
if [ -f /etc/arch-release ]; then
    PKG_MGR="pacman -S --noconfirm"
    PKG_UPDATE="pacman -Sy"
    PKG_CHECK="pacman -Qs"
    PKGS_BASIC="sudo vim git openssh curl base-devel zsh tmux"
    SUDO_GROUP="wheel"
elif [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    PKG_MGR="apt-get install -y"
    PKG_UPDATE="apt-get update"
    PKG_CHECK="dpkg -l"
    PKGS_BASIC="sudo vim git openssh-client curl build-essential zsh tmux"
    SUDO_GROUP="sudo"
elif [ -f /etc/fedora-release ]; then
    PKG_MGR="dnf install -y"
    PKG_UPDATE="dnf check-update"
    PKG_CHECK="rpm -q"
    PKGS_BASIC="sudo vim git openssh-clients curl @development-tools zsh tmux"
    SUDO_GROUP="wheel"
else
    echo "不支持的发行版"
    exit 1
fi

# 2. 基础环境安装
$PKG_UPDATE
for pkg in $PKGS_BASIC; do
    if ! $PKG_CHECK "$pkg" > /dev/null 2>&1; then
        $PKG_MGR "$pkg"
    fi
done

# 3. 创建用户 aaa
if ! id "aaa" &>/dev/null; then
    useradd -m -G "$SUDO_GROUP" -s /usr/bin/zsh aaa
    echo "aaa:1" | chpasswd
    # 确保 /etc/sudoers.d 存在
    mkdir -p /etc/sudoers.d
    echo "aaa ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aaa
    chmod 440 /etc/sudoers.d/aaa
fi

# 4. WSL 特有配置
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    if ! grep -q "default=aaa" /etc/wsl.conf 2>/dev/null; then
        echo -e "[user]\ndefault=aaa" | tee -a /etc/wsl.conf > /dev/null
    fi
fi

# --------------------------------------------------------------------------
# 5. 用户级配置 (Git, SSH, OhMyZsh, Homebrew)
# 将用户参数通过环境变量传递进入 su 环境
export WIN_USER_PROMPT=$(read -p "宿主机Windows用户名: " u && echo $u)
export SSH_KEY_PROMPT=$(read -p "SSH私钥文件名(如 id_rsa): " k && echo $k)
export GIT_NAME_PROMPT=$(read -p "Git用户名: " n && echo $n)
export GIT_EMAIL_PROMPT=$(read -p "Git邮箱: " e && echo $e)
export REPO_URL_PROMPT=$(read -p "GitHub仓库地址: " r && echo $r)

su - aaa <<EOF
# 配置 SSH
if [ -n "$WIN_USER_PROMPT" ]; then
    SRC="/mnt/c/Users/$WIN_USER_PROMPT/.ssh/$SSH_KEY_PROMPT"
    if [ -f "\$SRC" ]; then
        mkdir -p ~/.ssh
        cp "\$SRC" ~/.ssh/id_rsa
        chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_rsa
    fi
fi

# Git 配置
git config --global user.name "$GIT_NAME_PROMPT"
git config --global user.email "$GIT_EMAIL_PROMPT"

# Config 别名/函数
if ! grep -q "config()" ~/.bashrc; then
    echo 'config() { /usr/bin/git --git-dir=\$HOME/.cfg/ --work-tree=\$HOME "\$@"; }' >> ~/.bashrc
    echo 'alias config=config' >> ~/.zshrc
fi

# Homebrew 安装 (Linuxbrew)
if ! command -v brew &> /dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # 自动添加到当前 shell
    test -d ~/.linuxbrew && eval "\$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
brew install gcc

# TPM 安装
[ ! -d "~/.tmux/plugins/tpm" ] && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Oh My Zsh
if [ ! -d "~/.oh-my-zsh" ]; then
    sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Zsh 插件
ZSH_CUSTOM=\${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
[ ! -d "\$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions \$ZSH_CUSTOM/plugins/zsh-autosuggestions
[ ! -d "\$ZSH_CUSTOM/plugins/zsh-autocomplete" ] && git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git \$ZSH_CUSTOM/plugins/zsh-autocomplete
[ ! -d "\$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# 克隆 dotfiles
if [ -n "$REPO_URL_PROMPT" ] && [ ! -d "\$HOME/.cfg" ]; then
    export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"
    git clone --bare "$REPO_URL_PROMPT" \$HOME/.cfg
    # 使用函数替代别名处理冲突
    config() { /usr/bin/git --git-dir=\$HOME/.cfg/ --work-tree=\$HOME "\$@"; }
    config config --local status.showUntrackedFiles no
    mkdir -p ~/.config-backup
    config checkout 2>&1 | grep -E "\s+\." | awk '{print \$1}' | xargs -I{} mv {} ~/.config-backup/{}
    config checkout
fi
EOF

echo "配置完成！请执行 'wsl --shutdown' 后重新打开。"
