# 使用更小的基础镜像进行构建
FROM golang:1.22-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制源代码
COPY . .

# 启用 Go 模块并下载依赖
ENV GO111MODULE=on
RUN go mod download

# 构建静态二进制文件，并减少大小
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o override

# 使用一个更小的基础镜像
FROM scratch

# 将证书从alpine复制到最终镜像中
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# 复制编译后的二进制文件
COPY --from=builder /app/override /usr/local/bin/override

# 如果需要配置文件，也可以复制过来
COPY config.json /app/config.json

# 设置工作目录
WORKDIR /app

# 暴露端口
EXPOSE 8080

# 设置入口点
ENTRYPOINT ["/usr/local/bin/override"]
