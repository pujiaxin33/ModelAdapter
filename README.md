# ModelAdapter

A SQLite ORM for Swift 5.1+ powered by [SQLite.swift](https://github.com/stephencelis/SQLite.swift).

基于SQLite.swift封装的SQLite ORM库，需要Swift 5.1+。消灭SQLite.swift库需要的数据库定义、增删改查等样板代码，只需要简单的配置就能完成数据对象对应数据库的搭建。

# 使用示例

下面是一个简单使用示例，看看`ModelAdapter`如何简化代码！

## Column定义

- 1、数据类型遵从`ModelAdapterModel`协议
- 2、非可选值属性使用`@Field`进行注解
- 3、可选值属性使用`@FieldOptional`进行注解
- 4、在`Field`或`FieldOptional`初始化器填写column相关信息

```Swift
struct CustomModel: ModelAdapterModel {
    @Field(key: "user_id", primaryKey: true)
    var userID: Int = 0
    @FieldOptional
    var nickName: String?
    @FieldOptional(unique: true)
    var phone: Int?
    @Field
    var age: Int = 0

    init() {
        initFieldExpressions()
    }
}
```

## `ModelAdapterModel`其他配置

- 实现`ModelAdapterModel`协议的指定初始化器，并且在`init`方法调用`initFieldExpressions`方法。
```Swift
struct CustomModel: ModelAdapterModel {
    init() {
        initFieldExpressions()
    }
}
```

## 数据库DAO定义

- 自定义`CustomDAO`类，遵从`ModelAdapterDAO`协议
- 设置关联类型`Entity`为`CustomModel`
- 实现`ModelAdapterDAO`协议要求的`connection`和`table`属性
- 整个数据库层的定义就完成了，不需要自己写增删改查的样板代码了。

```Swift
class CustomDAO: ModelAdapterDAO {
    typealias Entity = CustomModel
    var connection: Connection = try! Connection("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/db.sqlite3")
    var table: Table = Table("user")

    required init() {
    }
}
```

## 开始使用

### 通过JSON字典数据创建model。
引入了[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)库完成JSON To Model。
```Swift
let jsonDict = ["user_id" : 123, "nickName" : "暴走的鑫鑫", "phone": 123456, "age": 33]
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
try? dao.delete(model.$userID.expression == 123)
```

### 更新数据
```Swift
model.phone = 654321
try? dao.update(entity: model, model.$userID.expression == 123)
```

### 查询数据
```Swift
//查询全部
let queryAll = try? dao.queryAll() 
//条件查询
let queryOne = try? dao.query(model.$userID.expression == 123)
```

# 详细说明

## 自定义column key

- 默认是属性名称，比如age属性在数据库的column值就是age
- 通过Field的key进行自定义，比如nickName属性在数据库的column值就是nick_name

```Swift
@Field(key: "nick_name"))
var nickName: String = "名字"
@Field
var age: Int = 0
```

## 自动创建数据库column

当首次建表之后，后续添加的属性，会自动创建数据库column。比如现在新增了height属性，只需要正常配置即可。
```Swift
@Field
var height: Double = 188
```

## 存储自定义类型

属性的类型是自定义类型时，需要让自定义类型遵从`SQLiteValueStringExpressible`协议并实现相关方法，就能够存储进数据库。为了方便使用，使用`SQLiteValueStorable`协议，它遵从于`SQLiteValueStringExpressible`协议。

`SQLiteValueStorable`协议就是让自定义类型能够和String互相转换，从而能够存储进数据库。更多详细信息，点击[SQLiteValueExtension](https://github.com/pujiaxin33/SQLiteValueExtension)进行了解。

使用`SQLiteValueStorable`协议时需要导入`import SQLiteValueExtension`。

```Swift
struct NestModel: SQLiteValueStorable {
    var nestName: String?
    var nestAge: Int = 0

    static func fromStringValue(_ stringValue: String) -> NestModel {
        return NestModel(JSONString: stringValue) ?? NestModel(JSON: [String : Any]())!
    }
    var stringValue: String {
        return toJSONString() ?? ""
    }
}

class CustomModel: ModelAdapterModel {
    @FieldOptional
    var nest: NestModel?
}
```

## 存储数组、字典

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

### 存储数组

只需要`Array.Element`遵从于`SQLiteValueStringExpressible`即可。比如`[NestModel]`、`[Int]`、`[Date]`。

### 存储字典

只需要`Dictionay.key`和`Value`遵从于`SQLiteValueStringExpressible`即可。
比如`[String: NestModel]`、`[Int : NestModel]`、`[String: [NestModel]]`。

## 自定义存储

如果值类型没有遵从`SQLiteValueStringExpressible`，就不能使用@Field。需要遵从`ModelAdapterModelCustomStorage`协议，然后自己处理数据的存储流程。存储数据类型`Set<String>`示例如下：
```Swift
class CustomModel: ModelAdapterModel {
    var customSet: Set<String>? = nil
}
    
extension CustomModel: ModelAdapterCustomStorage {
    static let customSetExpression = Expression<String?>("custom_set")

    func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(CustomModel.customSetExpression)
    }
    func setters() -> [Setter] {
        guard let set = customSet else {
            return []
        }
        guard let data = try? JSONSerialization.data(withJSONObject: Array(set), options: []) else {
            return []
        }
        return [CustomModel.customSetExpression <- String(data: data, encoding: .utf8)]
    }
    mutating func update(with row: Row) {
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

`ModelAdapterDAO`协议默认实现了常用的增删改查方法：
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

### 自定义数据库参考

```Swift
class CustomDAO: ModelAdapterDAO {
    func customUpdate(entity: Entity) throws {
        let statement = table.update(entity.$nickName.expression <- "自定义更新")
        try connection.run(statement)
    }
}
```

# 安装

## Cocoapods

```
pod 'ModelAdapter'
```

# 要求

- iOS 9+
- Swift 5.1+
- Xcode 12+

# 依赖

- `SQLite.swift`
- `SQLiteValueExtension`


