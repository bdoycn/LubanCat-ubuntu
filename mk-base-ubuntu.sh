#!/bin/bash -e

if [ ! $TARGET ]; then
	echo "---------------------------------------------------------"
	echo "please enter TARGET version number:"
	echo "请输入要构建的根文件系统版本:"
	echo "[0] Exit Menu"
	echo "[1] gnome"
	echo "[2] xfce"
	echo "[3] lite"
	echo "[4] gnome-full"
	echo "[5] xfce-full"
	echo "---------------------------------------------------------"
	read input

	case $input in
		0)
			exit;;
		1)
			TARGET=gnome
			;;
		2)
			TARGET=xfce
			;;
		3)
			TARGET=lite
			;;
		4)
			TARGET=gnome-full
			;;
		5)
			TARGET=xfce-full
			;;
		*)
			echo -e "\033[47;36m input TARGET version number error, exit ! \033[0m"
			exit;;
	esac
    echo -e "\033[47;36m set TARGET=$TARGET...... \033[0m"
fi

if [ "$ARCH" == "armhf" ]; then
	ARCH='armhf'
elif [ "$ARCH" == "arm64" ]; then
	ARCH='arm64'
else
    ARCH="arm64"
    echo -e "\033[47;36m set default ARCH=arm64...... \033[0m"
fi

TARGET_ROOTFS_DIR="binary"
DISTRIBUTION_VERSION="focal"

sudo rm -rf $TARGET_ROOTFS_DIR/

if [ ! -d $TARGET_ROOTFS_DIR ] ; then
    sudo mkdir -p $TARGET_ROOTFS_DIR

    if [ ! -e ubuntu-base-20.04.5-base-$ARCH.tar.gz ]; then
        echo -e "\033[47;36m wget ubuntu-base-20.04-base-x.tar.gz \033[0m"
        wget -c http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.5-base-$ARCH.tar.gz
    fi
    sudo tar -xzf ubuntu-base-20.04.5-base-$ARCH.tar.gz -C $TARGET_ROOTFS_DIR/
    sudo cp sources.list $TARGET_ROOTFS_DIR/etc/apt/sources.list
    sudo cp -b /etc/resolv.conf $TARGET_ROOTFS_DIR/etc/resolv.conf

    if [ "$ARCH" == "armhf" ]; then
	    sudo cp -b /usr/bin/qemu-arm-static $TARGET_ROOTFS_DIR/usr/bin/
    elif [ "$ARCH" == "arm64"  ]; then
	    sudo cp -b /usr/bin/qemu-aarch64-static $TARGET_ROOTFS_DIR/usr/bin/
    fi
fi

finish() {
    ./ch-mount.sh -u $TARGET_ROOTFS_DIR
    echo -e "error exit"
    exit -1
}
trap finish ERR

echo -e "\033[47;36m Change root.................... \033[0m"

./ch-mount.sh -m $TARGET_ROOTFS_DIR

cat <<EOF | sudo chroot $TARGET_ROOTFS_DIR/

export APT_INSTALL="apt-get install -fy --allow-downgrades"

export LC_ALL=C.UTF-8

apt-get -y update
apt-get -f -y upgrade

if [ "$TARGET" == "gnome" ]; then
    DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop-minimal rsyslog sudo dialog apt-utils ntp evtest onboard
    mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/
    mkdir /var/lib/dpkg/info/
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop-minimal rsyslog sudo dialog apt-utils ntp evtest onboard
    mv /var/lib/dpkg/info_old/* /var/lib/dpkg/info/
elif [ "$TARGET" == "xfce" ]; then
    DEBIAN_FRONTEND=noninteractive apt install -y xubuntu-core onboard rsyslog sudo dialog apt-utils ntp evtest udev
    mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/
    mkdir /var/lib/dpkg/info/
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt install -y xubuntu-core onboard rsyslog sudo dialog apt-utils ntp evtest udev
    mv /var/lib/dpkg/info_old/* /var/lib/dpkg/info/
elif [ "$TARGET" == "lite" ]; then
    DEBIAN_FRONTEND=noninteractive apt install -y rsyslog sudo dialog apt-utils ntp evtest acpid
elif [ "$TARGET" == "gnome-full" ]; then
    DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop-minimal rsyslog sudo dialog apt-utils ntp evtest onboard
    mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/
    mkdir /var/lib/dpkg/info/
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop-minimal rsyslog sudo dialog apt-utils ntp evtest onboard
    mv /var/lib/dpkg/info_old/* /var/lib/dpkg/info/
elif [ "$TARGET" == "xfce-full" ]; then
    DEBIAN_FRONTEND=noninteractive apt install -y xubuntu-desktop onboard rsyslog sudo dialog apt-utils ntp evtest udev
    mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/
    mkdir /var/lib/dpkg/info/
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt install -y xubuntu-desktop onboard rsyslog sudo dialog apt-utils ntp evtest udev
    mv /var/lib/dpkg/info_old/* /var/lib/dpkg/info/
fi

\${APT_INSTALL} net-tools openssh-server ifupdown alsa-utils ntp network-manager gdb inetutils-ping libssl-dev \
    vsftpd tcpdump can-utils i2c-tools strace vim iperf3 ethtool netplan.io toilet htop pciutils usbutils curl \
    whiptail gnupg bc xinput gdisk parted gcc sox libsox-fmt-all gpiod libgpiod-dev python3-pip python3-libgpiod \
    guvcview

\${APT_INSTALL} ttf-wqy-zenhei xfonts-intl-chinese

if [[ "$TARGET" == "gnome-full" ||  "$TARGET" == "xfce-full" ]]; then
    apt purge ibus firefox -y

    echo -e "\033[47;36m Install Chinese fonts.................... \033[0m"
    \${APT_INSTALL} language-pack-zh-hans fonts-noto-cjk-extra gnome-user-docs-zh-hans language-pack-gnome-zh-hans

    # set default xinput for fcitx
    \${APT_INSTALL} fcitx fcitx-table fcitx-googlepinyin fcitx-pinyin fcitx-config-gtk
    sed -i 's/default/fcitx/g' /etc/X11/xinit/xinputrc

    \${APT_INSTALL} ipython3 jupyter
fi

if [[ "$TARGET" == "gnome-full" ||  "$TARGET" == "xfce-full" ]]; then
    # Uncomment zh_CN.UTF-8 for inclusion in generation
    sed -i 's/^# *\(zh_CN.UTF-8\)/\1/' /etc/locale.gen
    echo "LANG=zh_CN.UTF-8" >> /etc/default/locale

    # Generate locale
    locale-gen zh_CN.UTF-8

    # Export env vars
    echo "LC_ALL=zh_CN.UTF-8" >> /etc/environment    
    echo "LANG=zh_CN.UTF-8" >> /etc/environment
    echo "LANGUAGE=zh_CN:zh:en_US:en" >> /etc/environment

    echo "export LC_ALL=zh_CN.UTF-8" >> /etc/profile.d/zh_CN.sh
    echo "export LANG=zh_CN.UTF-8" >> /etc/profile.d/zh_CN.sh
    echo "export LANGUAGE=zh_CN:zh:en_US:en" >> /etc/profile.d/zh_CN.sh

    \${APT_INSTALL} $(check-language-support)
fi

if [[ "$TARGET" == "gnome" || "$TARGET" == "gnome-full" ]]; then
    \${APT_INSTALL} mpv acpid gnome-sound-recorder
elif [[ "$TARGET" == "xfce" || "$TARGET" == "xfce-full" ]]; then
    \${APT_INSTALL} mpv acpid gnome-sound-recorder
elif [ "$TARGET" == "lite" ]; then
    \${APT_INSTALL}  
fi

pip3 install python-periphery Adafruit-Blinka -i https://mirrors.aliyun.com/pypi/simple/

# 安装 Docker
echo -e "\033[47;36m Install Docker \033[0m"
# 安装依赖包
\${APT_INSTALL} ca-certificates curl gnupg
# 添加 GPG 秘钥
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# 设置 Docker Stable 存储库
echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $DISTRIBUTION_VERSION stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
chmod a+r /etc/apt/keyrings/docker.gpg
# 开始安装
apt-get -y update
\${APT_INSTALL} docker-ce docker-ce-cli containerd.io

HOST=bitiot-gateway

# Create User:bit
useradd -m -s /bin/bash bit
passwd bit <<IEOF
temppwd
temppwd
IEOF
gpasswd -a bit video
gpasswd -a bit audio
passwd root <<IEOF
root
root
IEOF

# Create User:op
useradd -G sudo -m -s /bin/bash op
passwd op <<IEOF
temppwd
temppwd
IEOF

# 将 bit 加入到 docker 用户组
usermod -aG docker bit

# allow root login
# sed -i '/pam_securetty.so/s/^/# /g' /etc/pam.d/login

# 只允许 op 用户通过 shell 登录
echo "AllowUsers op" >> /etc/ssh/sshd_config

# hostname
echo bitiot-gateway > /etc/hostname

# set localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# workaround 90s delay
services=(NetworkManager systemd-networkd)
for service in ${services[@]}; do
  systemctl mask ${service}-wait-online.service
done

# disbale the wire/nl80211
systemctl mask wpa_supplicant-wired@
systemctl mask wpa_supplicant-nl80211@
systemctl mask wpa_supplicant@

# Make systemd less spammy

sed -i 's/#LogLevel=info/LogLevel=warning/' \
  /etc/systemd/system.conf

sed -i 's/#LogTarget=journal-or-kmsg/LogTarget=journal/' \
  /etc/systemd/system.conf

# check to make sure sudoers file has ref for the sudo group
SUDOEXISTS="$(awk '$1 == "%sudo" { print $1 }' /etc/sudoers)"
if [ -z "$SUDOEXISTS" ]; then
  # append sudo entry to sudoers
  echo "# Members of the sudo group may gain root privileges" >> /etc/sudoers
  echo "%sudo	ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

# make sure that NOPASSWD is set for %sudo
# expecially in the case that we didn't add it to /etc/sudoers
# just blow the %sudo line away and force it to be NOPASSWD
sed -i -e '
/\%sudo/ c \
%sudo    ALL=(ALL) NOPASSWD: ALL
' /etc/sudoers

apt-get clean
rm -rf /var/lib/apt/lists/*

sync

EOF

./ch-mount.sh -u $TARGET_ROOTFS_DIR

DATE=$(date +%Y%m%d)
echo -e "\033[47;36m Run tar pack ubuntu-base-$TARGET-$ARCH-$DATE.tar.gz \033[0m"
sudo tar zcf ubuntu-base-$TARGET-$ARCH-$DATE.tar.gz $TARGET_ROOTFS_DIR

# sudo rm $TARGET_ROOTFS_DIR -r

echo -e "\033[47;36m normal exit \033[0m"
