# Structural Patterns

Patterns tổ chức code structure cho flexibility và reuse.

## Adapter Pattern

Convert interface thành interface khác để tương thích.

```kotlin
interface MediaPlayer {
    fun play(filename: String)
}

// Legacy interface
interface AdvancedMediaPlayer {
    fun playVlc(filename: String)
    fun playMp4(filename: String)
}

class VlcPlayer : AdvancedMediaPlayer {
    override fun playVlc(filename: String) { /* ... */ }
    override fun playMp4(filename: String) { /* nothing */ }
}

// Adapter
class MediaAdapter(private val advancedPlayer: AdvancedMediaPlayer) : MediaPlayer {
    override fun play(filename: String) {
        when {
            filename.endsWith(".vlc") -> advancedPlayer.playVlc(filename)
            filename.endsWith(".mp4") -> advancedPlayer.playMp4(filename)
        }
    }
}
```

## Facade Pattern

Simplify complex subsystem bằng unified interface.

```kotlin
class DatabaseFacade(
    private val userDao: UserDao,
    private val orderDao: OrderDao,
    private val productDao: ProductDao
) {
    suspend fun getUserWithOrders(userId: String): UserWithOrders {
        val user = userDao.getUser(userId)
        val orders = orderDao.getOrdersForUser(userId)
        val products = orders.flatMap { order ->
            order.productIds.map { productDao.getProduct(it) }
        }
        return UserWithOrders(user, orders, products)
    }
}
```

## Other Structural Patterns

### Decorator Pattern

```kotlin
interface Coffee {
    fun cost(): Double
    fun description(): String
}

class SimpleCoffee : Coffee {
    override fun cost() = 1.0
    override fun description() = "Simple coffee"
}

abstract class CoffeeDecorator(protected val coffee: Coffee) : Coffee {
    override fun cost() = coffee.cost()
    override fun description() = coffee.description()
}

class Milk(coffee: Coffee) : CoffeeDecorator(coffee) {
    override fun cost() = coffee.cost() + 0.5
    override fun description() = coffee.description() + ", milk"
}

class Sugar(coffee: Coffee) : CoffeeDecorator(coffee) {
    override fun cost() = coffee.cost() + 0.2
    override fun description() = coffee.description() + ", sugar"
}

// Usage
val coffee: Coffee = Sugar(Milk(SimpleCoffee()))
// "Simple coffee, milk, sugar" - cost: 1.7
```

### Composite Pattern

```kotlinninterface FileSystemComponent {
    fun size(): Long
    fun display(): String
}

class File(private val name: String, private val fileSize: Long) : FileSystemComponent {
    override fun size() = fileSize
    override fun display() = name
}

class Directory(private val name: String) : FileSystemComponent {
    private val children = mutableListOf<FileSystemComponent>()

    fun add(component: FileSystemComponent) {
        children.add(component)
    }

    override fun size() = children.sumOf { it.size() }
    override fun display() = "$name/\n${children.joinToString("\n") { "  ${it.display()}" }}"
}

// Usage
val root = Directory("root")
val docs = Directory("documents")
docs.add(File("doc1.txt", 100))
docs.add(File("doc2.txt", 200))
root.add(docs)
root.add(File("readme.txt", 50))
```

## When to Use

| Pattern | Use When |
|---------|----------|
| Adapter | Tích hợp legacy code hoặc incompatible interfaces |
| Facade | Đơn giản hóa complex subsystem |
| Decorator | Thêm behavior dynamically mà không subclass |
| Composite | Tree structures, part-whole hierarchies |
