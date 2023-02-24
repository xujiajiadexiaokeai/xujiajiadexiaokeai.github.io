---
title: "Design Patterns Notes"
date: 2022-01-15T03:06:30+08:00
layout: post
description: "设计模式笔记"
author: "Wenhao Jiang"
draft: false
showFullContent: false
tags:
    - design-pattern
URL: "/2022-01-15/design-patterns"
---
# 创建型模式(Creational Pattern)

### 单例模式(Singleton Pattern)

主要用于保证一个类仅有一个实例,并提供一个访问它的全局访问点

(1) 限制调用者直接实例化该对象

(2) 为该对象的单例提供一个全局唯一的访问方法

```go
package msgpool
...
// 消息池
type messagePool struct {
	pool *sync.Pool
}
// 消息池单例
var msgPool = &messagePool {
	// 如果消息池里没有消息,则新建一个Count值为0的Message实例
	pool: &sync.Pool{New: func() interface{} { return &Message{Count: 0}},
}
// 访问消息池单例的唯一方法
func Instence() *messagePool {
	return msgPool
}
// 向消息池里添加消息
func (m *messagePool) AddMsg(msg *Message) {
	m.pool.Put(msg)
}
// 从消息池里获取消息
func (m *messagePool) GetMsg() *Message {
	return m.pool.Get().(*Message)
}
...
```

```go
package test
...
func TestMessagePool(t *testing.T) {
	msg0 := msgpool.Instance().GetMsg()
	if msg0.Count != 0 {
		t.Errorf("expect msg count %d, but actual %d.", 0, msg0.Count)
	}
	msg0.Count = 1
	msgpool.Instance().AddMsg(msg0)
	msg1 := msgpool.Instance().GetMsg()
	if msg1.Count != 1 {
		t.Errorf("expect msg count %d, but actual %d.", 1, msg1.Count)
	}
}
```

饿汉模式与懒汉模式

懒汉模式会带来线程安全问题,可以通过普通加锁,或者双重检验锁来优化

```go
// 单例模式的“懒汉模式”实现
package msgpool
...
var once = &sync.Once{}
var msgPool *messagePool
func Instance() *messagePool {
	// 在匿名函数中实现初始化逻辑,Go语言保证只会调用一次
	once.Do(func() {
		msgPool = &messagePool{
			// 如果消息池里没有消息, 则新建一个Count值为0的Message实例
			pool:&sync.Poll{New: func() interface{} {return &Message{Count:0} }},
		}
	})
	return msgPool
}
...
```

### 建造者模式(Builder Pattern)

(1) 封装复杂对象的创建过程,使对象使用者不感知复杂的创建逻辑

(2) 可以一步步按照顺序对成员进行赋值,或者创建嵌套对象,并最终完成目标对象的创建

(3) 对多个对象复用同样的对象创建逻辑

```go
package msg
...
type Message struct {
	Header *Header
	Body *Body
}

type Header struct {
	SrcAddr string
	SrcPort uint64
	DestAddr string
	DestPort uint64
	Items map[string] string
}
type Body struct {
	Item []string
}
...
```



```go
package msg
...
// Message对象的Builder对象
type builder struct {
	once *sync.Once
	msg *Message
}
// 返回Builder对象
func Builder() *builder {
	return &builder{
		once: &sync.Once{},
		msg: &Message{Header: &Header{}, Body: &Body{}},
	}
}

// 以下是对Message成员的构建方法
func (b *builder) WithSrcAddr(srcAddr string) *builder {
	b.msg.Header.SrcAddr = srcAddr
	return b
}
func (b *builder) WithSrcPort(srcPort uint64) *builder {
	b.msg.Header.SrcPort = srcPort
	return b
}
func (b *builder) WithDestAddr(destAddr string) *builder {
	b.msg.Header.DestAddr = destAddr
	return b
}
func (b *builder) WithHeaderItem(key, value, string) *builder {
	// 保证map只初始化一次
	b.once.Do(func() {
		b.msg.Header.Items = make(map[string]string)
	})
	b.msg.Header.Items[key] = value
	return b
}
func (b *builder) WithBodyItem(record string) *builder {
	b.msg.Body.Items = append(b.msg.Body.Items, record)
	return b
}
func (b *builder) Build() *Message {
	return b.msg
}
```

```go
package test
...
func TestMessageBuilder(t *testing.T) {
	// 使用消息建造者进行对象创建
	message := msg.Builder().
		WithSrcAddr("192.168.0.1").
		WithSrcPost(1234).
		...
		Build()
	if message.Header.SrcAddr != "192.168.0.1" {
		t.Errorf("expect src address 192.168.0.1, but actual %d.", message.Header.SrcAddr)
	if message.Body.Items[0] != "record1" {
		t.Errorf("expect body item0 record1, but actual %s.",message.Body.Items[0])
	}
}
```

### 工厂方法模式(Factory Method Pattern)

```go
package event
...
type Type uint8
// 事件类型定义
const (
	Start Type = iota
	End
)
// 事件抽象接口
type Event interface {
	EventType() Type
	Content() string
}
// 开始事件,实现了Event接口
type StartEvent struct{
	content string
}
...
// 结束事件,实现了Event接口
type EndEvent struct{
	content string
}
...
```

```go
package event
...
// 事件工厂对象
type Factory struct{}
// 根据事件类型创建具体事件
func (e *Factory) Create(etype Type) Event {
	switch etype {
	case Start:
		return &StartEvent{
			content: "this is start event",
		}
	case End:
		return &EndEvent{
			content: "this is end event",
		}
	default:
		return nil
	}
}
```



```go
package event 
...
func TestEvent(t *testing.T) {
	e := event.OfStart()
	if e.EventType() != event.Start {
		t.Errorf("expect event.Start, but actual %v.", e.EventType())
	}
	e = factory.Create(event.End)
	if e.EventType() != event.End {
		t.Errorf("expect event.End, but actual %v.", e.EventType())
	}
}
```

### 抽象工厂模式(Abstract Factory Pattern)

![](https://tcs.teambition.net/storage/312dac721ae2e5db5dfd73d0091ddfb92a9e?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY3NzgyNTE0NCwiaWF0IjoxNjc3MjIwMzQ0LCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmRhYzcyMWFlMmU1ZGI1ZGZkNzNkMDA5MWRkZmI5MmE5ZSJ9.hS5QO-KPxmoLc1gElEZACQdg8Z29DkGOyKs6l7Cnk0U&download=image.png "")

![](https://tcs.teambition.net/storage/312d15f97489776c7f78378dcfecc2069f7e?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY3NzgyNTE0NCwiaWF0IjoxNjc3MjIwMzQ0LCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmQxNWY5NzQ4OTc3NmM3Zjc4Mzc4ZGNmZWNjMjA2OWY3ZSJ9.kv-n_k3L1VhlA53YDLWF9IscPVfEJTmkmoU15NILWe0&download=image.png "")

```go
package plugin
...
// 插件抽象接口定义
type Plugin interface{}
// 输入插件,用于接收消息
type Input interface {
	Plugin
	Receive() string
}
// 过滤插件,用于处理消息
type Fliter interface {
	Plugin
	Process(msg string) string
}
// 输出插件,用于发送消息
type Output interface {
	Plugin
	Send(msg string)
}

package pipeline
...
// 消息管道的定义
type Pipeline struct {
	input plugin.Input
	filter plugin.Filter
	output plugin.Output
}
// 一个消息的处理流程为 input -> filter -> output
func (p *Pipeline) Exec() {
	msg := p.intput.Receive()
	msg = p.filter.Process(msg)
	p.output.Send(msg)
}
```

```go
package plugin
...
// input插件名称与类型的映射关系,主要用于通过反射创建input对象
var inputNames = make(map[string]reflect.Type)
// Hello input插件,接收”Hello World“消息
type HelloInput struct {}

 func (h *HelloInput) Receive() string {
	return "Hello World"
}
// 初始化input插件映射关系表
func init() {
	inputNames["hello"] = reflect.TypeOf(HelloInput{})
}

package plugin
...
// filter插件名称与类型的映射关系.主要用于通过反射创建filter对象
var filterNames = make(map[string]reflect.Type)
// Upper filter插件,将消息全部字母转成大写
type UpperFilter struct {}

func (u *UpperFilter) Process(msg string) string {
	return strings.ToUpper(msg)
}
// 初始化filter插件映射关系表
func init() {
	filterNames["upper"] = reflect.TypeOf(UpperFilter{})
}

package plugin
...
// output插件名称与类型的映射关系,主要用于通过反射创建output对象
var outputNames = make(map[string]reflect.Type)
// Console output插件,将消息输出到控制台上
type ConsoleOutput struct {}

func (c *ConsoleOutput) Send(msg string) {
	fmt.Println(msg)
}
// 初始化output插件映射关系表
func init() {
	outputNames["console"] = reflect.TypeOf(ConsoleOutput{})
}

```

```go
package plugin
...
// 插件工厂接口
type Factory interface {
	Create(conf Config) Plugin
}
// input插件工厂对象,实现Factory接口
type InputFactory struct{}
// 读取配置,通过反射机制进行对象实例化
func (i *InputFactory) Create(conf Config) Plugin {
	t, _ := inputNames[conf.Name]
	return reflect.New(t).Interface().(Plugin)
}
// filter和output插件工厂实现类似
type FilterFactory struct{}
func (f *FilterFactory) Create(conf Config) Plugin {
	t, _ := filterNames[conf.Name]
	return reflect.New(t).Interface().(Plugin)
}
type OutputFactory struct{}
func (o *OutputFactory) Create(conf Config) Plugin {
	r, _ := outputNames[conf.Name]
	return reflect.New(t).Interface().(Plugin)
}

```

```go
package pipeline
...
// 保存用于创建Plugin的工厂实例,其中map的key为插件类型,value为抽象工厂接口
var pluginFactories = make(map[plugin.Type]plugin.Factory)
// 根据plugin.Type返回对应Plugin类型的工厂实例
func factoryOf(t plugin.Type) plugin.Factory {
	factory, _ := pluginFactories[t]
	return factory
}
// pipeline工厂方法,根据配置创建一个Pipeline实例
func Of(conf Config) *Pipeline {
	p := &Pipeline{}
	p.intput = factoryOf(plugin.InputType).Create(conf.Input).(plugin.Input)
	p.filter = factoryOf(plugin.FilterType).Create(conf.Filter).(pulgin.Filter)
	p.output = factoryOf(plugin.OutputType).Create(conf.Output).(plugin.Output)
	return p	
)
// 初始化插件工厂对象
func init() {
	pluginFactories[plugin.InputType] = &plugin.InputFactory{}
	pluginFactories[plugin.FilterType] = &plugin.FilterFactory{}
	pluginFactories[plugin.OutputType] = &plugin.OutputFactory{}
}

```

```go
package test
...
func TestPipeline(t *testing.T) {
	// 其中pipeline.DefaultConfig()的配置内容见[抽象工厂模式示例图]
	// 消息处理流程为 HelloInput -> UpperFilter -> ConsoleOutput
	p := pipeline.Of(pipeline.Deafult.Config())
	p.Exec()
}
```

### 原型模式(Prototype Pattern)

```go
package prototype
...
// 原型复制抽象接口
type Prototype interface {
 clone() Prototype
}

type Message struct {
	Header *Header
	Body *Body
}

func (m *Message) clone() Prototype {
	msg := *m
	return &msg
}
```

```go
package test
...
func TestPrototype(t *testing.T) {
	message := msg.Builder().
		WithSrcAddr("192.168.0.1").
		WithSrcPort(1234).
		WithDestAddr("192.168.0.2").
		WithDestPort(8080).
		WithHeaderItem("contents","application/json").
		WithBodyItem("record1").
		WithBodyItem("record2").
		Build()
	// 复制一份消息
	newMessage := message.Clone().(*msg.Message)
	if newMessage.Header.SrcAddr != message.Header.SrcAddr {
		t.Errorf("Clone Message failed.")
	}
	if newMessage.Body.Items[0] != message.Body.Items[0] {
		t.Errorf("Clone Message failed.")
	}
```

# 结构型模式(Structural Pattern)

### 组合模式(Composite Pattern)

Go实现组合模式的方式有两种

直接组合(Direct Composition)

嵌入组合(Embedding Composition)

```go
type Message struct {
	Header *Header
	Body *Body
}
```

```go
package plugin
...
// 插件运行状态
type Status uint8

const (
	Stopped Status = iota
	Started
)

type Plugin interface {
	// 启动插件
	Start()
	// 停止插件
	Stop()
	// 返回插件当前的运行状态
	Status() Status
}
// 这里使用Message结构体替代了原来的string,使语义更清晰
type Input interface {
	Plugin
	Receive() *msg.Message
}

type Filter interface {
	Plugin
	Process(msg *msg.Message) *msg.Message
}

type Output interface {
	Plugin
	Send(msg *msg.Message)
}
```

```go
package pipeline
...
// 一个Pipeline由input filter output三个Plugin组成
type Pipeline struct {
	status plugin.Status
	input plugin.Input
	filter plugin.Filter
	output plugin.Output
}

func (p *Pipeline) Exec() {
	msg := p.input.Receive()
	msg = p.filter.Process(msg)
	p.output.Send(msg)
}
// 启动的顺序 output -> filter -> input
func (p *Pipeline) Start() {
	p.output.Start()
	p.filter.Start()
	p.input.Start()
	p.status = plugin.Started
	fmt.Println("Hello input plugin started.")
}
// 停止的顺序 input -> filter -> output
func (p *Pipeline) Stop() {
	p.input.Stop()
	p.filter.Stop()
	p.output.Stop()
	p.status = plugin.Stopped
	fmt.Println("Hello input plugin stopped.")
}

func (p *Pipeline) Status() plugin.Status {
	return p.status
}
```

一个`Pipeline`由`Input`、`Filter`、`Output`三类插件组成，形成了“部分-整体”的关系，而且它们都实现了`Plugin`接口，这就是一个典型的组合模式的实现。Client无需显式地启动和停止`Input`、`Filter`和`Output`插件，在调用`Pipeline`对象的`Start`和`Stop`方法时，`Pipeline`就已经帮你按顺序完成对应插件的启动和停止。



```go
package plugin
...
type HelloInput struct {
	status Status
}

func (h *HelloInput) Receive() *msg.Message {
	// 如果插件未启动,则返回nil
	if h.status != Started {
		fmt.Println("Hello input plugin is not running, input nothing.")
		return nil
	}
	return msg.Builder().
		WithHeaderItem("content", "text").
		WithBodyItem("Hello World").
		Build()
}

func (h *HelloInput) start()  {
	h.status = Started
	fmt.Println("Hello input plugin started.")
}

func (h *HelloInput) Stop() {
	h.status = Stopped
	fmt.Println("Hello input plugin stopped.")
}

func (h *HelloInput) Status {
	return h.status
}

func (u *UpperFilter) Process(msg *msg.Message) *msg.Message {
	if u.status != Started {
	fmt.Println("Upper filter plugin is not running, filter nothing.")
	return msg
	}
	for i, val := range msg.Body.Items {
		msg.Body.Items[i] = strings.ToUpper(val)
	}
	return msg
}

func (u *UpperFilter) Start() {
	u.status = Started
	fmt.Println("Upper filter plugin started.")
}

func (u *UpperFilter) Stop() {
	u.status = Stopped
	fmt.Println("Upper filter plugin stopped.")
}

func (u *UpperFilter) Status() Status {
	return u.status
}

package plugin
...
type ConsoleOutput struct {
	status Status
}

func (c *ConsoleOutput) Send(msg *msg.Message) {
	if c.status != Started {
		fmt.Println("Console output is not running, output nothing.")
		return
	}
	fmt.Printf("Output:\n\tHeader:%+v, Body:%+v\n", msg.Header.Items, msg.Body.Items)
}

func (c *ConsoleOutput) Start() {
	c.status = Started
	fmt.Println("Console output plugin started.")
}

func (c *ConsoleOutput) Stop() {
	c.status = Stopped
	fmt.Println("Console output plugin stopped.")
}

func (c *ConsoleOutput) Status() Status {
	return c.status
}

```

```go
package test
...
func TestPipeline(t *testing.T) {
	p := pipeline.Of(pipeline.DefaultConfig())
	p.Start()
	p.Exec()
	p.Stop()
}

```

组合模式的另一种实现,嵌入组合(Embedding Composition),是利用了Go的匿名成员特性,本质上跟直接组合是一致的

```go
type Message struct {
	Header
	Body
}
// 使用时,Message可以引用Header和Body的成员属性
msg := &Message{}
msg.SrcAddr = "192.168.0.1"
```

### 适配器模式(Adapter Pattern)

适配器模式是最常用的结构型模式之一,它让原本因为接口不匹配而无法一起工作的两个对象能够一起工作.适配器模式所做的就是将一个接口Adaptee,通过适配器Adapter转换成Client所期望的另一个接口Target来使用,实现原理也很简单,就是Adapter通过实现Target接口,并在对应的方法中调用Adaptee的接口实现

一个典型的应用场景是,系统中一个老的接口已经过时即将废弃,但因为历史包袱没法立即将老接口全部替换为新接口.可以新增一个适配器,将老的接口适配成新的接口来使用.适配器模式很好的践行了面向对象设计里的开闭原则(open/closed principle),新增一个接口时也无需修改老接口,只需多加一个适配器即可.



假设需要给系统新增从kafka 消息队列中接收数据的功能,其中Kafka消费者的接口如下

```go
package kafka
...
type Records struct {
	Items []string
}

type Consumer interface {
	Poll() Records
}
```

由于当前Pipeline设计时通过plugin.Input接口来进行数据接收,因此kafka.Consumer并不能直接集成到系统中.

所以需要使用适配器模式

为了能让Pipeline能够使用kafka.Consumer接口,我们需要定义一个适配器:

```go
package plugin
...
type KafkaInput struct {
	status Status
	consumer kafka.Consumer
}

func (k *KafkaInput) Receive() *msg.Message {
	records := k.consumer.Poll()
	if k.status != Started {
		fmt.Println("Kafka input plugin is not running, input nothing.")
		return nil
	}
	return msg.Builder().
		WithHeaderItem("content", "kafka").
		WithBodyItem(records.Item).
		Build()
}

// 在输入插件映射关系中加入kafka,用于通过反射创建input对象
func init() {
	inputNames["hello"] = reflect.TypeOf(HelloInput{})
	inputNames["kafka"] = reflect.TypeOf(KafkaInput{})
}
```

因为Go语言没有构造函数,如果按照抽象工厂模式来创建KafkaInput,那么得到的实例中的consumer成员因为没有被初始化而会是nil.因此,需要给Plugin接口新增一个Init方法,用户定义插件的一些初始化操作,并在工厂返回实例前调用.

```go
package plugin
...
type Plugin interface {
	Start()
	Stop()
	Status() Status
	// 新增初始化方法,在插件Init函数,完成相关初始化方法
	Init()
}

// 修改后的插件工厂实现如下
func (i *InputFactory) Create(conf Config) Plugin {
	t, _ := inputNames[conf.Name]
	p := reflect.New(t).Interface().(Plugin)
	p.Init()
	return p
}

// KafkaInput的Init函数实现
func (k *KafkaInput) Init() {
	k.consumer = &kafka.MockConsumer{}
}

```

上述代码中的kafka.MockConsumer为我们模拟Kafka消费者的一个实现,

```go
package kafka
...
type MockConsumer struct {}

func (m *MockConsumer) Poll() *Records {
	records := &Records{}
	records.Items = append(records.Items, "i am mock consumer.")
	return records
}

```

```go
package test
...
func TestKafkaInputPipeline(t *testing.T) {
	config := pipeline.Config{
		Name: "pipeline2",
		Input: plugin.Config{
			PluginType: plugin.InputType,
			Name: "kafka",
		},
		Filter: plugin.Config{
			PluginType: plugiin.FilterType,
			Name: "upper",
		},
		Output: plugin.Config{
			PluginType: plugin.OutputType,
			Name: "console",
		},
	}
	p := pipeline.Of(config)
	p.Start()
	p.Exec()
	p.Stop()
}
```

### 桥接模式(Bridge Pattern)

![](https://tcs.teambition.net/storage/312e6caaa50934bbfe2d273c2a6bc5be4942?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY3NzgyNTE0NCwiaWF0IjoxNjc3MjIwMzQ0LCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmU2Y2FhYTUwOTM0YmJmZTJkMjczYzJhNmJjNWJlNDk0MiJ9.smGJmZZGv_HRw2QeywW6rpZCvL5nszKjkFvhjHM-M80&download=image.png "")

桥接模式主要用于将抽象部分和实现部分进行解耦,使得它们能够各自往独立的方向变化.

![](https://tcs.teambition.net/storage/312e7779775d739bfcb2507aff8539a09920?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY3NzgyNTE0NCwiaWF0IjoxNjc3MjIwMzQ0LCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmU3Nzc5Nzc1ZDczOWJmY2IyNTA3YWZmODUzOWEwOTkyMCJ9.JYF6QyIagvBAxw4E3Y1apqCeglSjUK85gmycYHO1aXE&download=image.png "")

这个例子中,我们通过将形状和颜色抽象为一个接口,使产品不再依赖于具体的形状和颜色细节,从而达到了解耦的目的.桥接模式本质上就是面向接口编程,可以给系统带来很好的灵活性和可扩展性.如果一个对象存在多个变化的方向,而且每个变化方向都需要扩展,那么使用桥街模式进行设计比较合适.



回到消息处理系统的例子,一个Pipeline对象主要由Input、Filter、Output三类插件组成(3个特征),因为是插件化的系统,不可避免的就要求支持多种Input、Filter、Output的实现,并能够灵活组合(有多个变化的方向).显然,Pipeline就非常适合使用桥街模式进行设计,实际上我们也这么做了.我们将Input、Filter、Output分别设计成一个抽象的接口,它们按照各自的方向去扩展.Pipeline只依赖的这3个抽象接口,并不感知具体实现的细节.

![](https://tcs.teambition.net/storage/312e5f292fba5d2a22c27489b1801ce8cd44?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY3NzgyNTE0NCwiaWF0IjoxNjc3MjIwMzQ0LCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmU1ZjI5MmZiYTVkMmEyMmMyNzQ4OWIxODAxY2U4Y2Q0NCJ9.cQmR2A369OpQkwOoL_6-LQpwmaCHE9nJTiAmzu6AO8Q&download=image.png "")

```go
package plugin
...
type Input interface {
	Plugin
	Receive() *msg.Message
}
type Filter interface {
	Plugin
	Process(msg *msg.Message) *msg.Message
}

type Output interface {
	Plugin
	Send(msg *msg.Message)
}

package pipeline
...
// 一个Pipeline由input、filter、output三个Plugin组成
type Pipeline struct {
	status plugin.Status
	input plugin.Input
	filter plugin.Filter
	output plugin.Output
}
// 通过抽象接口来使用,看不到底层的实现细节
func (p *Pipeline) Exec() {
	msg := p.input.Receive()
	msg = p.filter.Process(msg)
	p.output.Send(msg)
}
```

```go
package test
...
func TestPipeline(t *testing.T) {
	p := pipeline.Of(pipeline.DefaultConfig())
	p.Start()
	p.Exec()
	p.Stop()
}

```

本文主要介绍了结构型模式中的组合模式、适配器模式和桥接模式。**组合模式**主要解决代码复用的问题，相比于继承关系，组合模式可以避免继承层次过深导致的代码复杂问题，因此面向对象设计领域流传着**组合优于继承**的原则，而Go语言的设计也很好实践了该原则；**适配器模式**可以看作是两个不兼容接口之间的桥梁，可以将一个接口转换成client所希望的另外一个接口，解决了模块之间因为接口不兼容而无法一起工作的问题；**桥接模式**将模块的抽象部分和实现部分进行分离，让它们能够往各自的方向扩展，从而达到解耦的目的。



### 代理模式(Proxy Pattern)

![](https://tcs.teambition.net/storage/312e70565f8b57a77be711d582d86bc7de93?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY3NzgyNTE0NCwiaWF0IjoxNjc3MjIwMzQ0LCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmU3MDU2NWY4YjU3YTc3YmU3MTFkNTgyZDg2YmM3ZGU5MyJ9.eFrV730KZWTn3ck9inoCnSlvJeJ5miaE1yezLMXyiWI&download=image.png "")

代理模式为一个对象提供一种代理以控制对该对象的访问

// 当Client不方便直接访问一个对象时,提供一个代理对象控制该对象的访问

代理模式分以下几种:

**远程代理(remote proxy)**: 远程代理适用于提供服务的对象处在远程的机器上,通过普通的函数调用无法使用服务,需要经过远程代理来完成.因此并不能直接访问本体对象,所有远程代理对象通常不会直接持有本体对象的引用,而是持有远端机器的地址,通过网络协议去访问本体对象

**虚拟代理(virtual proxy)**:对一些重量级的服务对象,如果一直持有该对象实例回非常消耗系统资源,这时可以通过虚拟代理来对该对象进行延迟初始化.

**保护代理(protection proxy)**:保护代理用于控制对本体对象的访问,常用于需要给Client的访问加上权限验证的场景.

**缓存代理(cache proxy)**:缓存代理主要在Client与本体对象之间加上一层缓存,用于加速本体对象的访问,常见于连接数据库的场景.

**智能引用(smart reference)**:智能引用为本体对象的访问提供了额外的动作,常见的实现为C++中智能指针,为对象的访问提供了计数功能,当访问对象的计数为0时销毁该对象.



```go
package db
...
// Key-Value数据库接口
type KvDb interface {
	// 存储数据
	// 其中reply为操作结果,存储成功为true, 否则为false
	// 当连接数据库失败时返回error,成功则返回nil
	Save(record Record, reply *bool) error
	// 根据key获取value,其中value通过函数参数中指针类型返回
	// 当连接数据库失败时返回error,成功则返回nil
	Get(key string, value *string) error
}

type Record struct {
	Key string
	Value string
}
```

数据库是一个Key-Value数据库,使用map存储数据,下面为数据库的服务端实现,`db.Server`实现了db.KvDb接口:

```go
package db
...
// 数据库服务端实现
type Server struct {
	// 采用map存储key-value数据
	data map[string]string
}

func (s *Server) Save(record Record, reply *bool) error {
	if s.data == nil {
		s.data = make(map[string]string)
	}
	s.data[record.Key] = record.Value
	*reply = true
	return nil
}

func (s *Server) Get(key string, reply *string) error {
	val, ok := s.data[key]
	if !ok {
		*reply = ""
		return errors.New("Db has no key " + key)
	}
	*reply = val
	return nil
}
```

消息处理系统和数据库并不在同一台机器上,因此消息处理系统不能直接调用`db.Server`的方法进行数据存储,需要使用远程代理的方式

在远程代理中,最常见的一种实现是远程过程调用(Remote Procedure Call)

```go
package db
...
// 启动数据库,对外提供RPC接口进行数据库的访问
func Start() {
	rpcServer := rpc.NewServer()
	server := &Server{data: make[string]string}
	// 将数据库接口注册到RPC服务器上
	if err := rpc.Server.Register(server); err != nil {
		fmt.Printf("Register Server to rpc failed, error: %v", err)
		return
	}
	l, err := net.Listen("tcp", "127.0.0.1:1234")
	if err != nil {
		fmt.Printf("Listen tcp failed, error: %v", err)
		return	
	}
	go rpcServer.Accept(l)
	time.Sleep(1 * time.Second)
	fmt.Println("RPC server start success.")
}
```

上面已经为数据库提供了对外访问的方式.现在,需要一个远程代理来连接数据库服务端,并进行相关的数据库的操作.对消息处理系统而言,它不需要,也不应该知道远程代理与数据库服务端交互的底层细节,这样可以减轻系统之间的耦合.因此,远程代理需要实现`db.KvDb`

```go
package db
...
// 数据库服务端远程代理,实现db.KvDb接口
type Client struct {
	// RPC客户端
	cli *rpc.Client
}

func (c *Client) Save(record Record, Reply *bool) error {
	var ret bool
	// 通过RPC调用服务端的接口
	err := c.cli.Call("Server.Save", record, &ret)
	if err != nil {
		fmt.Printf("Call db Server.Save rpc failed, error: %v", err)
		*reply = false
		return err
	}
	*reply = ret
	return nil
}

func (c *Client) Get(key string, reply *string) error {
	var ret string
	// 通过RPC调用服务端的接口
	err := c.cli.Call("Server.Get", record, &ret)
	if err != nil {
		fmt.Printf("Call db Server.Get rpc failed, error: %v", err)
		*reply = false
		return err
	}
	*reply = ret
	return nil
}

// 工厂方法,返回远程代理实例
func CreateClient() *Client {
	rpcCli, err := rpc.Dial("tcp", "127.0.0.1:1234")
	if err != nil {
		fmt.Printf("Create rpc client failed, error: %v.",err)
		return nil
	}
	return &Client{cli: rpcCli}
}

```

作为远程代理的db.Client并没有直接持有db.Server的引用,而是持有了它的`ip:port`

通过RPC客户端调用了它的方法



### 装饰模式(Decorator Pattern)

![](https://tcs.teambition.net/storage/312e9309f45180e9077336f18b2fe3f4bb44?Signature=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBcHBJRCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9hcHBJZCI6IjU5Mzc3MGZmODM5NjMyMDAyZTAzNThmMSIsIl9vcmdhbml6YXRpb25JZCI6IiIsImV4cCI6MTY3NzgyNTE0NCwiaWF0IjoxNjc3MjIwMzQ0LCJyZXNvdXJjZSI6Ii9zdG9yYWdlLzMxMmU5MzA5ZjQ1MTgwZTkwNzczMzZmMThiMmZlM2Y0YmI0NCJ9.Qv59p6umMZ66pWRG87aeRFDyybLoIrJHGLEpQS7ASIs&download=image.png "")

装饰模式使用组合而非继承的方式,能够动态的为本体对象叠加新的行为

装饰模式最经典的应用当属Java的I/O流体系,通过装饰模式,使用者可以动态地为原始的输入输出流添加功能,比如按照字符串输入输出,添加缓存等

从结构上看,装饰模式和代理模式具有很高的相似性,但是两种所强调的点不一样.装饰模式强调的是为本体对象添加新的功能,代理模式强调的是对本体对象的访问控制

行为型模式(Behavioral Pattern)

