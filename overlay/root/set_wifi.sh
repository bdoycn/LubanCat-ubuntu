#!/bin/bash

# 检查是否传入了足够的参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <SSID> <Password>"
    exit 1
fi

SSID="$1"
PASSWORD="$2"

# 生成新的 Netplan 配置文件
cat <<EOF > /etc/netplan/01-network-manager-all.yaml
network:
    renderer: NetworkManager
    wifis:
        wlan0:
            dhcp4: true
            optional: true
            access-points:
                "$SSID":
                    password: "$PASSWORD"
                    hidden: true
EOF

# 应用新的 Netplan 配置
netplan apply

echo "Netplan configuration has been updated and applied."
