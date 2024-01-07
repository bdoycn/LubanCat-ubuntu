# 根据 serial-number 生成主机名
echo bitiot-gateway-$(cat /proc/device-tree/serial-number) > /etc/hostname
echo "init ok, please reboot"

# 启动 categraf
sudo /projects/categraf/categraf --start

# 删除自身
rm -- "$0"
