---
title: "关于离职后的这一年我做了什么"
date: "2022-09-20T22:14:47+08:00"
draft: false
layout: post
description: "关于离职后的这一年我做了什么"
author: "Wenhao Jiang"
weight: 1
tags:
    - summary
URL: "/2022-09-20/summary"
--- 

# 起子

其实这篇文章本可以叫做《未来的XX时间我要做什么》,用来指导关于技术上的学习计划.

可惜由于某些原因,我选择了离职来完成这部分学习计划.

也由于某些原因, 这部分计划的完成距我2021年8月20日离职至今已经近13个月的时间,
这大大超出了我的预期,对自己的生活也造成了一定的影响.

希望通过这篇文章对过去这13个月的时间进行总结和复盘.

# 我想要做什么?
- 重新梳理大学时期忽略的一些基础知识

尤其是在操作系统原理、计算机体系结构、编译原理、计算机网络等等应该进行大量实验,却统统上成了PPT式的背题考试课程,只知其然,不知其所以然.

所以当我看到南大jyy老师在操作系统这门课的课堂上给讲台下的同学用GDB一步一步调试内核代码的时候,我真的要哭了.他真的在教台下的同学,怎样去一点一点的阅读代码,什么是good practice,什么是bad practice.真的是我大学四年几乎未经历过的.2022的上半年在Bilibili上有幸看到了课程直播并跟着重新学习了一遍操作系统.(**Update**: 墙裂推荐! [2023春季](https://jyywiki.cn/OS/2023/)开始啦!jyyYYDS!)


- 搭建自己的从“输入”到“输出”的知识管理工具体系
  
回顾自己在过去的学习中,确实也做了一些笔记,整理了一些东西,但是都只留在了纸面上.没有经常的整理、回顾、应用,慢慢也就都遗忘掉了.真的是学的多,记的少.回想大学时拿着php帮图书馆老师撸图书馆新生管理系统,到现在php的语法几乎都想不起来了...

所以在过去的一年中我尝试在用博客来整理自己的知识,这样随时能打开翻一翻.这只是一小步,之后应该怎么做还需要继续探索.

之前在微博中看到了好多技术博主分享的微博,当时觉得不错就点了收藏.有很多不错的内容,过后想找出来再看一下,但是收藏的微博太多了,微博收藏又没有搜索的功能.所以写了个爬虫把收藏的微博都爬了下来,都已经收藏了1千多条了.之后考虑搞个前端页面,把这些内容都管理起来.(**Update**: 尝试接入chatGPT把核心内容直接提取出来,打上标签来管理)

# 为什么要这么做?

大学时没有好好的学习基础,过于专注于业务实现,东搞一点西搞一点.Java、php、React Native、Node.js都拿来写过七七八八的应用,但几乎没有碰过系统层面的东西.

大学时期上课清一色的Windows,Linux只是书本上提过的名词,当时因为好奇在笔记本上装了虚拟机,但是面对只有命令行的界面真的手足无措,至今还被女朋友嘲笑当时总是打开虚拟机敲一遍`sudo apt update`和`sudo apt upgrade`就关机.

工作后才开始正式在Linux上做开发,但一开始也就是一些CURD业务上的实现,也没碰到过系统层面的Debug.直到我加入了Teambition并开始负责私有云客户问题处理的时候,这个问题才正式暴露出来.在排查系统和网络层面上的问题时,经常对问题的出现摸不到头脑,要耗费大量的时间在上面,也会导致问题的延期.这让我感觉到困惑和恐惧,决定深入探究这方面的知识,彻底解决疑惑.

因为要随时响应客户问题,所以时间是特别碎片化的,下班后也经常需要和运维同学去搞升级.尤其前期知识层面的空白,学习起来也要耗费大量时间.后来就开始计划离职,这样可以全身心高效地投入,用较短的时间来重新搭建知识框架,重新出发.

# 这一年做了什么?
-  读完《DDIA》
-  读完《现代操作系统 原理与实现》
-  看了6.824
-  看了jyy的操作系统课
-  学了Golang
-  实现操作系统内核
-  实现TCP协议
-  实现Paxos
-  实现Kubernetes Operator
-  玩了PingCAP的tinyKV
-  玩Chaos Mesh
-  玩eBPF

# 总结
**对自己没有清晰的认知,对生活的掌握是失控的**

回想当时特别上头的去离职的决定,其实是有些后悔的,毕竟失去了工作就失去了经济来源.我一直留在出租屋内学习,一年的房租就要四万块,直接覆盖了我上班以来的存款.后面的日子多亏了老爸老妈的救济才撑下来.

当时设想的用大概半年时间完成上面的目标现在想想也十分可笑.确实是有大块的时间来学习了,但是人也懒散了,每天学学玩玩,也没有清晰的计划,偶尔熬个夜刷个剧,第二天睡到中午起,时间很快就过去了.到了半年的时间,想要学的东西才学了三分之一左右.女朋友开始建议我出去工作,家里人也开始关注我找工作的情况,但是我又真的想把这些东西都学完,搭建好知识框架,觉得这样也有助于之后的学习和工作.之后就这样一直拖着,偶尔假装在找工作,回家过了年然后又回到上海继续学习,正好又赶上上海封城,算救了我一把,直到现在才算有了一点成果.

回顾这一段时光,就像开头说的,对自己没有清晰的认知,对生活的掌握是失控的.计划的设定本身就是有问题的,但又一股脑的不考虑自身实际情况的去ALL IN,虽然到最后勉强取得了一些成果,但代价是巨大的.希望自己能在之后的生活和工作中,吸取教训.

最后,总算是推倒了之前摇摇晃晃的危楼,重新搭起了基本的知识结构.玩过内核,实现过协议,也勉强算是合格的计算机专业科班出身了...

现在,就重新起航吧!