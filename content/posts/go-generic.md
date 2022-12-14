---
date: 2022-10-01T15:16:17+08:00
draft: false
url: "/2022-10-01/go-goroutine"
layout: post
description: "Go Generic"
author: "Wenhao Jiang"
tags:
    - Go
title: "Go Generic"
---

# 什么是泛型
# 类型系统
## 类型内存布局
## 类型检查
- 强类型、弱类型
- 静态检查、动态检查

静态检查: 编译阶段
动态检查: 运行时阶段
Go的类型检查发生在编译阶段

- 类型推导

编译器来做类型推导
## 非泛型突破类型的限制

### 手工复制
### 代码生成

[genny](https://github.com/cheekybits/genny)
- 需要一些集成的手段去使用这些库，可能让代码构建变的更复杂。
- 增加了编译时间。
- 增加了二进制包的体积。

### 类型断言
通过将函数中的参数类型转换为根类型(interface{}),然后对根类型进行期望的类型断言
```go
// source: https://github.com/danielfurman/presentations/blob/master/lets-go-generic/max.go
package main

import (
	"errors"
	"fmt"
)

func MaxNumber(s []interface{}) (interface{}, error) { // HL
	if len(s) == 0 {
		return nil, errors.New("no values given")
	}
	switch first := s[0].(type) { // HL
	case int: // HL
		max := first
		for _, rawV := range s[1:] {
			v := rawV.(int) // HL
			if v > max {
				max = v
			}
		}
		return max, nil
	case float64: // HL
		max := first
		for _, rawV := range s[1:] {
			v := rawV.(float64) // HL
			if v > max {
				max = v
			}
		}
		return max, nil
	default:
		return nil, fmt.Errorf("unsupported element type of given slice: %T", first)
	}
}

func main() {
	m1, err1 := MaxNumber([]interface{}{4, -8, 15})       // HL
	m2, err2 := MaxNumber([]interface{}{4.1, -8.1, 15.1}) // HL
	fmt.Println(err1, err2)                               // <nil> <nil>
	fmt.Println(m1, m2)                                   // 15 15.1
}
```
- 调用方需要将参数包装或转换成根类型。
- 实现方代码中耦合了大量的类型断言代码。
- 失去了编译器的类型安全保障。

### 反射
用反射的技术在运行时获取类型信息,通过对类型的枚举判断来实现
```go
// source: https://github.com/danielfurman/presentations/blob/master/lets-go-generic/max.go
package main

import (
	"errors"
	"fmt"
	"reflect"
)

func MaxNumber(s []interface{}) (interface{}, error) { // HL
	if len(s) == 0 {
		return nil, errors.New("no values given")
	}

	first := reflect.ValueOf(s[0])
	if first.CanInt() {
		max := first.Int()
		for _, ifV := range s[1:] {
			v := reflect.ValueOf(ifV)
			if v.CanInt() {
				intV := v.Int()
				if intV > max {
					max = intV
				}
			}
		}
		return max, nil
	}

	if first.CanFloat() {
		max := first.Float()
		for _, ifV := range s[1:] {
			v := reflect.ValueOf(ifV)
			if v.CanFloat() {
				intV := v.Float()
				if intV > max {
					max = intV
				}
			}
		}
		return max, nil
	}

	return nil, fmt.Errorf("unsupported element type of given slice: %T", s[0])
}

func main() {
	m1, err1 := MaxNumber([]interface{}{4, -8, 15})       // HL
	m2, err2 := MaxNumber([]interface{}{4.1, -8.1, 15.1}) // HL
	fmt.Println(err1, err2)                               // <nil> <nil>
	fmt.Println(m1, m2)                                   // 15 15.1
}
```
- 可读性可能不太好，因为用到了复杂的反射技术。
- 会导致运行时性能差。运行时反射要比直接的代码多了很多指令操作，所以性能要慢很多。
- 失去了编译器的类型安全保障。
### 接口
SOLID设计模式中的依赖倒置原则（Dependency Inversion Principle）要求软件接口在设计中应该依赖抽象而不是具体。
- 可能需要定义很多数据类型。

# 实现泛型
通常意义下的泛型也叫参数多态，指的是声明与定义函数、复合类型、变量时不指定其具体的类型，而把这部分类型作为参数使用，使得该定义对各种具体类型都适用。参数化多态使得语言更具表达力，同时保持了完全的静态类型安全。这被称为泛化函数、泛化数据类型、泛型变量，形成了泛型编程的基础。

> 编程语言理论(PLT)中多态(Polymorphism)包含三个主要方面：特设多态(Ad-hoc)，参数多态(Parametric)和子类型(Subtyping)。

> Ad-hoc：也叫重载(Overloading)，允许具有相同名称的函数对不同类型执行不同的操作。例如，+运算符即可以将两个整数相加，也可以连接两个字符串。

> Subtyping：也叫包容性多态(Inclusion)，是指通过基类指针和引用使用派生类的能力。

子类型多态(Subtyping)是面向对象编程(OOP)中很重要的一个概念，它也称为运行时多态性，因为编译器在编译时不定位函数的地址，而是在运行时动态调用函数。这也称为动态派发(Dynamic Dispatch)。

派发目的是让程序运行时知道被执行的函数或方法所在的内存位置。派发分为：

静态派发(Static dispatch/early binding)：当程序在编译时可以找到执行的函数。C++默认使用的是直接派发，加上virtual修饰符可以改成虚函数表(Vtable)派发。直接派发是最快的，原因是调用指令少，还可通过编译器进行内联等方式的优化。这种派发缺点是不灵活，无法实现一些面向对象所需的技术如多态性。
动态派发(dynamic dispatch/run-time dispatch/virtual method call/late binding)：当程序在运行时可以找到执行的函数。Java默认使用的是虚函数表(Vtable)派发，通过final修饰符可改成直接派发。虚函数表派发是有动态性的，一个类里会用表来存储类成员函数的指针，子类重写(Override)父类的函数会替代父类的函数，子类添加的函数会被加到这个表里。当程序运行时派发时会从这个表中找到对应的函数，这样就可以实现动态派发。面向对象的编程语言正是靠此机制实现了多态性(Polymorphic)。
消息机制(message passing)：通过消息传递来调用被执行的函数。这种机制是在运行时可以改变函数的行为，甚至函数可以未实现，也不会引发运行时错误。比如Objective-C中就是通过消息传递来调用被执行的函数，甚至可以在程序运行过程中实现热更新代码。
以上三种派发方式都有其优劣：比如静态派发的速度是最快的，但并不灵活。而动态派发虽然比较慢，但却可以实现面向对象多态的功能。消息机制是最灵活的方式，但性能也最差。


## 类型擦除
## 虚函数表
## 字典
## 单态化
## 模版
## 蜡印
# 总结