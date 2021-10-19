# SQLiteValueExtension
SQLiteValueExtension for SQLite.swift
用于解决SQLite.swift没有办法直接存储数组和字典。传统的做法就是先把数组和字典转成字符串，再进行存储。查询的时候再把字符串转成数组或字典。


# 使用

对于元素类型符合条件（下面会讲具体条件）的数组、字典，可以直接进行SQLite数据库操作。
```Swift
//Expression定义
static let intArray = Expression<[Int]?>("int_array")
static let intStringDict = Expression<[Int:String]?>("int_string_dict")
//Insert
let insert = config.insert(normalInt <- basic.normalInt, intStringDict <- basic.intStringDict)
try connection.run(insert)
//Query
let rows = try connection.prepare(config)
var result = [BasicDataModel]()
for data in rows {
    let basic = BasicDataModel(JSON: [String : Any]())!
    basic.normalInt = data[normalInt]
    basic.intStringDict = data[intStringDict]
    result.append(basic)
}
```


## 原生类型
SQLite.swift原生支持`Int`、`Int64`、`Bool`、`Double`、`String`、`Blob`、`Data`、`Date`类型，内部对于这些类型添加了extension遵从`StringValueExpressible`协议。所以，如果Array.Element、Dictionary.Key和Vaule是以上这些类型，引入`SQLiteValueExtension`库之后，就可以直接存储。

## 自定义类型

### 遵从`Value`、`StringValueExpressible`协议
对于自定义类型想要存入数据库，需要遵从`Value`协议，具体参考`SQLite.swift`官方文档：[custom-types](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#custom-types)。

如果想要存入自定义类型数组、字典，还需要让自定义类型遵从`StringValueExpressible`协议。

示例代码：
```Swift
extension BasicInfoModel: Value, StringValueExpressible {
    public static var declaredDatatype: String { String.declaredDatatype }
    public static func fromDatatypeValue(_ datatypeValue: String) -> BasicInfoModel {
        return fromStringValue(datatypeValue)
    }
    public var datatypeValue: String {
        return stringValue
    }

    public static func fromStringValue(_ stringValue: String) -> BasicInfoModel {
        return BasicInfoModel(JSONString: stringValue) ?? BasicInfoModel(JSON: [String : Any]())!
    }
    public var stringValue: String {
        return toJSONString() ?? ""
    }
}
```

### 减少样板代码

从上面的代码可以看到遵从`Value`、`StringValueExpressible`协议之后，需要添加许多样板代码。所以，添加了`SQLiteValueStorable`协议，它的定义如下
```Swift
public protocol SQLiteValueStorable: Value, StringValueExpressible { }
```
然后再看一下优化之后的代码，如下：
```Swift
extension BasicInfoModel: SQLiteValueStorable {
    public static func fromStringValue(_ stringValue: String) -> BasicInfoModel {
        return BasicInfoModel(JSONString: stringValue) ?? BasicInfoModel(JSON: [String : Any]())!
    }
    public var stringValue: String {
        return toJSONString() ?? ""
    }
}
```

### 存储自定义类型数组、字典

```Swift
//Expression定义
static let modelArray = Expression<[BasicInfoModel]?>("model_array")
static let stringModelDict = Expression<[String:BasicInfoModel]?>("string_model_dict")
//Insert
let insert = config.insert(modelArray <- basic.modelArray, stringModelDict <- basic.stringModelDict)
try connection.run(insert)
//Query
let rows = try connection.prepare(config)
var result = [BasicDataModel]()
for data in rows {
    let basic = BasicDataModel(JSON: [String : Any]())!
    basic.modelArray = data[modelArray]
    basic.intStringDict = data[intStringDict]
    result.append(basic)
}
```

### Dictionary.Key和Value的类型约束

`Dictionary.Key`需要遵从`Hashable`和`StringValueExpressible`协议；
`Dictionary.Value`需要遵从`StringValueExpressible`协议；
符合以上条件即可直接存入数据库。

## 新增基础类型支持

比如想要存储`Float`类型的数组，添加以下代码即可：
```Swift
extension Float: Value, StringValueExpressible {
    public static var declaredDatatype: String { Double.declaredDatatype }
    public static func fromDatatypeValue(_ datatypeValue: Double) -> Float {
        return Float(datatypeValue)
    }
    public var datatypeValue: Double {
        return Double(self)
    }
    public static func fromStringValue(_ stringValue: String) -> Float {
        return Float(stringValue) ?? 0
    }
    public var stringValue: String {
        return String(self)
    }
}
```

其他想要新增的基础数据类型，参考这个来就可以支持。

# 总结

只要`Array.Element`、`Dictionary.Key、Value`遵从`Value`和`StringValueExpressible`协议，就可以直接存入数据库，不需要自己做转换。

# 安装

## Cocoapods

```
pod 'SQLiteValueExtension'
```

# 推荐

[ModelAdaptor](https://github.com/pujiaxin33/ModelAdaptor): 是一个可以简化`ObjectMapper`和`SQLite.swift`操作的库。




