---
date: 2022-09-21T09:20:17+08:00
draft: false
url: "/2022-09-21/consistent-hashing"
layout: post
description: "Chaos Mesh上手"
author: "Wenhao Jiang"
tags:
    - Chaos Mesh
title: "Chaos Mesh上手"
---

# 安装kind
注意科学上网

# 安装chaos-mesh
测试用 install.sh
需要指定k8s&&kind版本

# 安装kubernetes Dashboard
[Kubernetes Dashboard](https://github.com/kubernetes/dashboard)

base dashboard@2.6.1
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml


```
kubectl proxy
```

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

create an authentication token(RBAC)

# 访问Chaos Mesh Dashboard

> https://chaos-mesh.org/zh/docs/1.2.4/user_guides/dashboard/

访问 Chaos Dashboard 的典型方法是使用kubectl port-forward：

```
kubectl port-forward -n chaos-mesh --address localhost,...ip svc/chaos-dashboard 2333:2333
```

http://localhost:2333


