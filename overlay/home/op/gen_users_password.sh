#!/bin/bash

# 生成随机密码并设置给指定的用户
for user in root op bit
do
    # 生成16个字符的随机密码
    password=$(< /dev/urandom tr -dc 'A-Za-z0-9!@#$%^&*_+' | head -c 16)

    # 更新用户密码
    echo "$user:$password" | sudo chpasswd

    # 输出生成的密码（可选）
    echo "User: $user, Password: $password"
done

# 删除自身
rm -- "$0"
