# 目标
用docker实现在任意PC上以指定Ubuntu版本编译AOSP代码

# 当前状态
docker_compile目录下是相关的脚本
- build_env.sh: 构建docker image
- start_env.sh: 启动docker环境
- Dockerfile.18.04: ubuntu 18.04的image构建脚本
- entry.sh: image的entrypoint脚本

> 已完成ubuntu18.04环境的开发。
> - 高通基线QSSI部分编译没有问题
> - Target部分编译失败

# 问题 
编译失败log位于log.kernel# docker_aosp_env
