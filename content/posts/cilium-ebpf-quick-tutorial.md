---
title: "MacOS用户快速上手Cilium eBPF"
date: 2022-03-06T20:41:30+08:00
layout: post
description: "Cilium eBPF quick tutorial for MacOS users"
author: "Wenhao Jiang"
draft: false
showFullContent: false
tags:
    - eBPF
    - Cilium
URL: "/2022-03-06/cilium-ebpf-quick-tutorial"
---
机器: Macbook Pro 13inch 2015款

系统: macOS Mojave 10.14.6

# 安装虚拟机

首先需要一个linux发行版,选择安装一个虚拟机来装Ubuntu,找到了multipass.

multipass是Ubuntu旗下一款虚拟机产品,适用个各个平台,可以在本地快速的开启一个虚拟机

[Multipass orchestrates virtual Ubuntu instances](https://multipass.run/)

版本: 1.8.1+mac

```text
multipass version
```

安装完成后,指定VirtualBox为vm driver

```text
sudo multipass set local.driver=virtualbox
```

[Using VirtualBox in Multipass on macOS | Multipass documentation](https://multipass.run/docs/using-virtualbox-in-multipass-macos)

快速启动一台当前最新LTS版的Ubuntu虚拟机并等待启动完成

```text
$ multipass launch --name ubuntu
```

# 配置ssh

这一步主要是为了能够使用开发机上vscode来连接到虚拟机进行coding,毕竟如果不是很熟悉使用vim的开发者,在terminal内编程还是有点困难

multipass启动的虚拟机默认开放22端口,也内置了ssh server.但是,因为处于不同网段,如果想要公开这个端口供开发机连接,需要使用[__VirtualBox的端口转发__](https://www.virtualbox.org/manual/ch06.html#natforward)功能,将22端口映射到宿主机的某个端口,这样就提供了外部访问的能力.在终端输入:

```text
sudo VBoxManage controlvm "ubuntu" natpf1 "myservice,tcp,,22,,2222"
```

该命令为ubuntu实例(也就是虚拟机)在natpf1网卡上添加了一条转发规则,规则名叫做"myservice",tcp协议,将所有到达宿主机2222端口的流量转发到实例的22端口上

局域网记得锁定ip

# 安装go

```text
sudo snap install go --classic
```

# 克隆cilium/ebpf项目

```text
git clone https://github.com/cilium/ebpf.git
```

# 运行example

```text
cd ebpf/examples/
go run -exec sudo ./kprobe
```



