# ModelAdaptor

模型适配器：Define once, Use anywhere!
终极目标是只需要定义一次数据模型，就可以在数据解析、数据库存储等地方解析并使用。
目前仅支持[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)数据解析、[SQLite.swift](https://github.com/stephencelis/SQLite.swift)数据存储。

这个库的灵感来源于`Java`语言的注解特性，感兴趣的可以点击了解[Android Jetpack的Room库的简单使用](https://juejin.im/post/5d4c0088f265da03925a3265)，了解如何使用注解来简化数据库存储。

然后依赖于Swift 5.1提供的`Proptery wrapper`特性，感兴趣的可以看一下这篇文章：[Property wrappers in Swift](https://www.swiftbysundell.com/articles/property-wrappers-in-swift/)

我们一起看一个简单使用示例，看看`ModelAdaptor`如何简化我们的代码！

# 使用示例

## 定义Model

遵从`ModelAdaptorModel`协议，非可选值普通类型使用`@Field`进行注解，可选值类型使用`@FieldOptional`进行注解。
```Swift
class CustomModel: ModelAdaptorModel {
    @Field(key: "level")
    var vipLevel: Int = 1
    @FieldOptional
    var accountID: Int?

    required init() {
        initExpressions()
    }
    required init?(map: Map) {
        initExpressions()
    }
}
```

经过这一步`ObjectMapper`层的数据解析已经完成，无需自己实现`func mapping(map: Map) `方法和添加类似`self.vipLevel <- map["level"]`的代码。

## 数据库DAO定义

创建`CustomDAO`类，遵从`ModelAdaptorDAO`协议，设置关联类型`Entity`为`CustomModel`。然后实现协议要求提供的`connection`和`table`属性。整个数据库层的定义就完成了。不需要自己写增删改查的样板代码了。
```Swift
class CustomDAO: ModelAdaptorDAO {
    typealias Entity = CustomModel
    var connection: Connection = try! Connection("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/db.sqlite3")
    var table: Table = Table("user")

    required init() {
    }
}
```

## 开始使用

### 通过JSON字典数据创建model。
```Swift
let jsonDict = ["accountID" : 123, "level" : 10]
let model = CustomModel(JSON: jsonDict)!
```

### 创建dao实例并创建数据库表单
```Swift
let dao = CustomDAO()
dao.createTable()
```

### 插入数据
```Swift
try? dao.insert(entity: model)
```

### 删除数据
```Swift
try? dao.delete(model.$accountID.expression == 123)
```

### 更新数据
```Swift
model.vipLevel = 100
try? dao.update(entity: model, model.$accountID.expression == 123)
```

### 查询数据
```Swift
//查询全部
let queryAll = try? dao.queryAll() 
//条件查询
let queryOne = try? dao.query(model.$accountID.expression == 123)
```

## 使用总结

以上就是一个简单的使用场景，需要通过`@Field`、`@FieldOptional`注解，在`ObjectMapper`和`SQLite.swift`两端就可以无缝使用了。尤其是数据库操作，无需写N多的样板代码。

# 详细说明

对于普通的情况使用起来非常顺手，对于一些特殊的数据类型，就要做一些兼容处理了。下面分别通过`ObjectMapper`和`SQLite.swift`两侧来进行说明。

## `ObjectMapper`特殊处理

### 自定义codingKey

数据解析时定义的key，确定优先级从高到低：key>codingParams.key>propertyName

- 使用key
```Swift
@FieldOptional(key: "nick_name")
var nickName: String?
```
这里的codingKey就是`nick_name`。

- 使用`codingParams.key`
```Swift
@FieldOptional(codingParams: .init(key: "nick_name_custom", convertor: NilTransform<String>()))
var nickName: String?
```
这里的codingKey就是`nick_name_custom`。
因为`CodingParams`是一个泛型类型，所以即使不需要自定义convertor，也需要传递一个NilTransform类型实例，防止编译器报错。

- 使用属性名
```Swift
@FieldOptional
var nickName: String?
```
这里的codingKey就是`nickName`。

### 自定义convertor

```Swift
@Field(codingParams: .init(convertor: DateTransform()))
var registerDate: Date = Date()
```

### nested、delimiter、ignoreNil自定义

```Swift
@Field(codingParams: .init(key: nil, convertor: NilTransform<String>(), nested: nil, delimiter:  ".", ignoreNil:  false))
var userName: String = "名字"
```

### 复杂类型自定义map过程

对于数据类型是数组、字典、Set等数据类型，就需要使用@FieldCustom进行注解。
然后实现`func customMap(map: Map) `方法进行自己转换，如下所示：
```Swift
@FieldCustom
var customDict: [String: NestModel]?
@FieldCustom
var customDictInt: [Int : NestModel]?
@FieldCustom
var customDictAarray: [String: [NestModel]]?
var customSet: Set<String>?

func customMap(map: Map) {
    self.nests <- map["nests"]
    self.customDict <- map["custom_dict"]
    self.customDictAarray <- map["custom_dict_array"]
    self.customDictInt <- (map["custom_dict_int"], IntDictTransform())
    self.customSet <- (map["custom_set"], ArraySetTransform())
}
```

## `SQLite.swift`特殊处理

### 自定义storageParams.key

同codingKey一样，可以通过默认属性名、默认自定义key、storageParams.key完成

```Swift
@Field(storageParams: .init(key: "user_name"))
var userName: String = "名字"
```

### 自定义storageParams.version和defaultValue

当version大于1时，dao调用`createTable`方法时，对于该属性会调用`addColumn`方法。version默认为1，会调用`createColumn`方法。defaultValue就是调用`addColumn`方法时，当参数不是可选值使用的。
```Swift
@Field(key: "amount", storageParams: .init(version: 2, defaultValue: 100))
var amount: Double = 6
```

### 存储自定义类型

遵从`SQLiteValueProvider`协议并实现相关方法
```Swift
//定义NestModel
struct NestModel: ModelAdaptorModel, SQLiteValueProvider {
    @FieldOptional(key: "nest_name")
    var nestName: String?
    @Field(key: "age")
    var nestAge: Int = 0

    init?(map: Map) {
        initExpressions()
    }
    init() {
        initExpressions()
    }

    init?(value: String) {
        self.init(JSONString: value)
    }
    func value() -> String? {
        return self.toJSONString()
    }
    init?(stringValue: String) {
        self.init(JSONString: stringValue)
    }
    func stringValue() -> String? {
        return value()
    }
}
//在CustomModel中使用
@FieldOptional
var nest: NestModel?
```

### 存储数组、字典、Set等数据类型

#### 存储数组

只需要Array.Element遵从于`SQLiteValueProvider`即可。比如`[NestModel]`、`[Int]`。
对于`String`、`Int`、`Double`、`Date`、`Data`等基础类型，已经默认遵从了`SQLiteValueProvider`协议。自定义的类型需要自己实现。

#### 存储字典

只需要`Dictionay.key`和`Value`遵从于`SQLiteValueProvider`即可。
比如`[String: NestModel]`、`[Int : NestModel]`、`[String: [NestModel]]`。

#### 存储Set

需要自己完成处理存储过程，示例如下：
```Swift
extension CustomModel {
    static let customSetExpression = Expression<String?>("custom_set")

    func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(CustomModel.customSetExpression)
    }
    func addColumn(table: Table) { }
    func setters() -> [Setter] {
        guard let set = customSet else {
            return []
        }
        guard let data = try? JSONSerialization.data(withJSONObject: Array(set), options: []) else {
            return []
        }
        return [CustomModel.customSetExpression <- String(data: data, encoding: .utf8)]
    }
    func update(with row: Row) {
        guard let string = row[CustomModel.customSetExpression] else {
            return
        }
        let data = Data(string.utf8)
        guard let stringArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [String] else {
            return
        }
        self.customSet = Set(stringArray)
    }
}
```

## DAO层使用

`ModelAdaptorDAO`协议默认实现了常用的增删改查方法：
```Swift
func createTable(ifNotExists: Bool)
func insert(entity: Entity) throws
func insert(entities: [Entity]) throws
func deleteAll() throws
func delete(_ predicate: SQLite.Expression<Bool>) throws
func delete(_ predicate: SQLite.Expression<Bool?>) throws
func update(entity: Entity, _ predicate: SQLite.Expression<Bool>) throws
func update(entity: Entity, _ predicate: SQLite.Expression<Bool?>) throws
func query(_ predicate: SQLite.Expression<Bool>) throws -> Entity?
func query(_ predicate: SQLite.Expression<Bool?>) throws -> Entity?
func queryAll() throws -> [Entity]?
```

如果需要实现其他数据库操作，可以参考示例代码：
```Swift
//CustomDAO添加的自定义方法
func customUpdate(entity: Entity) throws {
    let statement = table.update(entity.$vipLevel.expression <- entity.vipLevel)
    try connection.run(statement)
}
```

## 不需要`SQLite.swift`，只处理`ObjectMapper`

遵从`ModelAdaptorMappable`协议即可。
```Swift
struct OnlyMap: ModelAdaptorMappable {
    @FieldOptional(key: "nick_name")
    var nickName: String?
    @Field
    var age: Int = 6

    init?(map: Map) {
    }
}
```

# 总结

对于新的特性总会感觉莫名兴奋，如果能利用他们提高工作效率就更完美了。最开始了解过`Java`的注解特性，就觉得十分强大。恰好swift 5.1带来了`Property Wrapper`特性，抱着试一试的态度，做出了`ModelAdaptoer`库。

目前`ModelAdaptoer`处于实验性阶段，在小项目上进行了实践。感兴趣的朋友，可以一起优化壮大它。虽然目前有一些限制，但是带来的便利也是非常巨大的。期待你的加入，让`ModelAdaptoer`变得更加强大。

# 安装

## Cocoapods

```
pod 'ModelAdaptor'
```





