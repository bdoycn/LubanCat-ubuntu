# 加载 tb-gateway 镜像
docker load -i /home/bit/images/local-gateway-3.4.4.tar
# 删除镜像
rm /home/bit/images/local-gateway-3.4.4.tar

# 启动 tb-gateway 容器
docker run -it \
    --device /dev/ttyS3:/dev/ttyS3 \
    --device /dev/ttyS4:/dev/ttyS4 \
    --device /dev/ttyS7:/dev/ttyS7 \
    --device /dev/ttyS9:/dev/ttyS9 \
    -v ~/.tb-gateway/logs:/thingsboard_gateway/logs \
    -v ~/.tb-gateway/extensions:/thingsboard_gateway/extensions \
    -v ~/.tb-gateway/config:/thingsboard_gateway/config \
    -v ~/.tb-gateway/data:/thingsboard_gateway/data \
    --cpus="3.5" \
    -m 500m \
    --health-cmd='ls /thingsboard_gateway || exit 1' \
    --health-interval=30s \
    --health-timeout=10s \
    --health-retries=3 \
    --health-start-period=40s \
    --add-host=host.docker.internal:host-gateway \
    --restart always \
    --name tb-gateway \
    local-gateway:3.4.4
