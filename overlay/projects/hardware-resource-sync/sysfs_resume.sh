#!/bin/bash

### sysfs_resume 的 shell 实现版本

# 检查是否提供了目录路径
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_scripts_directory>"
    exit 1
fi

SCRIPTS_DIR=$1

# 转换为绝对路径
if [[ ! "$SCRIPTS_DIR" = /* ]]; then
    SCRIPTS_DIR="$PWD/$SCRIPTS_DIR"
fi

# 找到所有 .sh 文件并按权重排序后执行
find "$SCRIPTS_DIR" -type f -name '*.sh' | awk -F/ '{ n=split($NF, a, "_"); print $0, a[1] }' | sort -k2,2nr | cut -d' ' -f1 | while read -r script; do
    echo "Executing $script"
    bash "$script" || { echo "Execution of $script failed"; exit 1; }
done