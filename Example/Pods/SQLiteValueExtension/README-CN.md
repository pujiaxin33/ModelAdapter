# SQLiteValueExtension
基于SQLite.swift库，更方便的存储数组、字典或自定义数据类型。

核心思路是：先把数组、字典或自定义类型转成字符串类型，再进行存储。查询的时候再把字符串转成数组、字典或自定义数据类型。

# 使用

只要是遵从`SQLiteValueStringExpressible`协议的数据类型，就可以通过`SQLite.swift`存储到数据库。

## 原生基础类型
以下基础类型都已经遵从`SQLiteValueStringExpressible`协议。
- `Int`、
- `Int64`
- `Bool`
- `Double`
- `Float`
- `String`
- `Blob`
- `Data`
- `Date`

## 数组、字典

`Array.Element`、`Dictionary.Key`和`Dictionary.Value`类型遵从`SQLiteValueStringExpressible`协议，就可以通过`SQLite.swift`存储到数据库。

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

## 自定义类型

遵从`SQLiteValueStorable`协议并实现相关方法。

`SQLiteValueStorable`继承`SQLiteValueStringExpressible`协议，在extensioin中指定了`datatypeValue`为`String`，简化了使用流程。

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

### 存储自定义类型的数组或字典使用示例

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

## 新增基础类型支持

比如`Float`数据类型：
```Swift
extension Float: SQLiteValueStringExpressible {
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

如果需要支持其他基础数据类型，欢迎提交Issue或Pull Request。

# 安装

## Cocoapods

```
pod 'SQLiteValueExtension'
```

## SPM

从0.0.6版本开始支持。

Xcode11的安装教程，可以参考文章：[在 Xcode 中使用 Swift Package](https://xiaozhuanlan.com/topic/9635421780)

# 推荐

- [ModelAdaptor](https://github.com/pujiaxin33/ModelAdaptor): 基于`SQLite.swift`的轻量级ORM库。
- [SQLite.swift custom-types](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#custom-types)



