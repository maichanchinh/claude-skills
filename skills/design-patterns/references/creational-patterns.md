# Creational Patterns

Patterns tạo objects linh hoạt và maintainable.

## Factory Pattern

### Simple Factory

```kotlin
sealed class Notification {
    abstract fun send()
}

class EmailNotification : Notification() {
    override fun send() { /* ... */ }
}

class PushNotification : Notification() {
    override fun send() { /* ... */ }
}

object NotificationFactory {
    fun create(type: NotificationType): Notification = when (type) {
        NotificationType.EMAIL -> EmailNotification()
        NotificationType.PUSH -> PushNotification()
    }
}
```

### Abstract Factory

```kotlin
interface UIFactory {
    fun createButton(): Button
    fun createTextField(): TextField
}

class MaterialUIFactory : UIFactory {
    override fun createButton() = MaterialButton()
    override fun createTextField() = MaterialTextField()
}

class CupertinoUIFactory : UIFactory {
    override fun createButton() = CupertinoButton()
    override fun createTextField() = CupertinoTextField()
}
```

## Builder Pattern

### Kotlin-style Builder

```kotlin
class Request private constructor(
    val url: String,
    val method: String,
    val headers: Map<String, String>,
    val body: String?
) {
    class Builder(private val url: String) {
        private var method: String = "GET"
        private var headers = mutableMapOf<String, String>()
        private var body: String? = null

        fun method(method: String) = apply { this.method = method }
        fun header(key: String, value: String) = apply { 
            this.headers[key] = value 
        }
        fun body(body: String) = apply { this.body = body }
        fun build() = Request(url, method, headers, body)
    }
}

// Usage
val request = Request.Builder("https://api.example.com")
    .method("POST")
    .header("Authorization", "Bearer token")
    .body("{ \"key\": \"value\" }")
    .build()
```

### Type-safe DSL Builder

```kotlin
@DslMarker
annotation class UserDsl

@UserDsl
class UserBuilder {
    var name: String = ""
    var email: String = ""
    var age: Int = 0

    fun build() = User(name, email, age)
}

fun user(block: UserBuilder.() -> Unit): User {
    return UserBuilder().apply(block).build()
}

// Usage
val user = user {
    name = "John"
    email = "john@example.com"
    age = 30
}
```

## Singleton Pattern

### Object Declaration

```kotlin
object DatabaseManager {
    private var database: Database? = null

    fun getDatabase(context: Context): Database {
        return database ?: synchronized(this) {
            database ?: buildDatabase(context).also { database = it }
        }
    }

    private fun buildDatabase(context: Context): Database {
        return Room.databaseBuilder(
            context,
            Database::class.java,
            "app.db"
        ).build()
    }
}
```

### Lazy Singleton

```kotlin
interface ApiService

class ApiServiceImpl : ApiService

object ServiceLocator {
    val apiService: ApiService by lazy { ApiServiceImpl() }
}
```

## When to Use

| Pattern | Use When |
|---------|----------|
| Factory | Tạo objects khác nhau dựa trên input |
| Builder | Objects phức tạp với nhiều optional params |
| Singleton | Một instance duy nhất toàn app |
