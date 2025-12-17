---
sidebar_position: 1
---

# Params

> 注意：Params 模块已被弃用，改为每个模块管理自己的参数。

## 摘要

params 包提供了一个全局可用的参数存储。

主要有两种类型：Keeper 和 Subspace。Subspace 是参数存储的隔离命名空间，其中键由预配置的空间名称作为前缀。Keeper 有权访问所有现有空间。

Subspace 可以被需要私有参数存储的各个 keeper 使用，其他 keeper 无法修改该存储。params Keeper 可用于向 `x/gov` 路由器添加路由，以便在提案通过时修改任何参数。

以下内容解释了如何为主模块和用户模块使用 params 模块。

## Contents

* [Keeper](params.md#keeper)
* [Subspace](params.md#subspace)
  * [Key](params.md#key)
  * [KeyTable](params.md#keytable)
  * [ParamSet](params.md#paramset)

## Keeper

在应用初始化阶段，可以使用 `Keeper.Subspace` 为其他模块的 keeper 分配[子空间](params.md#subspace)，并存储在 `Keeper.spaces` 中。然后，这些模块可以通过 `Keeper.GetSubspace` 获得对其特定参数存储的引用。

示例：

```go
type ExampleKeeper struct {
	paramSpace paramtypes.Subspace
}

func (k ExampleKeeper) SetParams(ctx sdk.Context, params types.Params) {
	k.paramSpace.SetParamSet(ctx, &params)
}
```

## Subspace

`Subspace` 是参数存储的带前缀子空间。使用参数存储的每个模块都会采用一个 `Subspace` 来隔离访问权限。

### Key

参数键是人类可读的字母数字字符串。键 `"ExampleParameter"` 的参数存储在 `[]byte("SubspaceName" + "/" + "ExampleParameter")` 下，\
其中 `"SubspaceName"` 是子空间的名称。

子键是与主参数键一起使用的辅助参数键。\
子键可用于分组或在运行时动态生成参数键。

### KeyTable

所有将使用的参数键都应在编译时注册。`KeyTable` 本质上是一个 `map[string]attribute`，其中 `string` 是参数键。

目前，`attribute` 由 `reflect.Type` 组成，它指示参数类型以检查提供的键和值是否兼容并已注册，以及一个函数 `ValueValidatorFn` 来验证值。

只有主键必须在 `KeyTable` 上注册。子键继承主键的属性。

### ParamSet

模块通常将参数定义为 proto 消息。生成的结构体可以实现 `ParamSet` 接口，以与以下方法一起使用：

* `KeyTable.RegisterParamSet()`: 注册结构体中的所有参数
* `Subspace.{Get, Set}ParamSet()`: 从结构体获取和设置

实现者应该是指针才能使用 `GetParamSet()`。
