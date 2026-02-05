---
name: kotlin-delegation
description: Kotlin delegation patterns including property delegation, interface delegation, lazy initialization, and observable patterns. Use when implementing property delegates, creating reusable delegation logic, or applying lazy/observable patterns in Android/Kotlin code.
---

# Kotlin Delegation Patterns

Delegation patterns trong Kotlin để code ngắn gọn, reusable và maintainable.

## Property Delegation

### lazy

```kotlin
// Thread-safe lazy initialization
val database: AppDatabase by lazy {
    Room.databaseBuilder(
        context,
        AppDatabase::class.java,
        "app.db"
    ).build()
}

// Lazy với custom mode
val heavyObject: HeavyClass by lazy(LazyThreadSafetyMode.NONE) {
    HeavyClass() // Không thread-safe, dùng khi chỉ có 1 thread
}

// Lazy trong ViewModel
class FeatureViewModel : ViewModel() {
    private val useCase: FeatureUseCase by lazy {
        FeatureUseCase(repository)
    }
}
```

### observable

```kotlinn// Observer pattern cho properties
var name: String by Delegates.observable("<no name>") { 
    property, oldValue, newValue ->
    println("${property.name} changed from $oldValue to $newValue")
}

// Trong ViewModel
var searchQuery: String by Delegates.observable("") { _, _, newValue ->
    viewModelScope.launch {
        search(newValue)
    }
}
```

### vetoable

```kotlinn// Validate trước khi set value
var age: Int by Delegates.vetoable(0) { _, oldValue, newValue ->
    newValue >= 0 // Chỉ nhận giá trị >= 0
}

// UI State validation
var selectedIndex: Int by Delegates.vetoable(0) { _, _, newValue ->
    newValue in 0 until itemCount
}
```

## Map Delegation

### JSON-like Objects

```kotlinn// Map delegation cho dynamic properties
class User(val map: MutableMap<String, Any?>) {
    var name: String by map
    var age: Int by map
    var email: String by map
}

// Usage
val user = User(mutableMapOf())
user.name = "John"
user.age = 30
println(user.map) // {name=John, age=30}

// Read-only
class Config(map: Map<String, Any>) {
    val apiUrl: String by map
    val timeout: Int by map
}
```

## Interface Delegation

### by Keyword

```kotlinn// Delegate to another object
interface Repository<T> {
    fun get(id: String): T
    fun save(item: T)
    fun delete(id: String)
}

// Base implementation
class BaseRepository<T> : Repository<T> {
    override fun get(id: String): T = TODO()
    override fun save(item: T) = TODO()
    override fun delete(id: String) = TODO()
}

// Delegate và override chỉ methods cần thiết
class CachedRepository<T>(
    private val cache: Cache<T>
) : Repository<T> by BaseRepository() {
    
    override fun get(id: String): T {
        return cache.get(id) ?: super.get(id).also {
            cache.put(id, it)
        }
    }
}
```

### Composition over Inheritance

```kotlinn// Multiple delegation
interface Logger {
    fun log(message: String)
}

interface Analytics {
    fun track(event: String)
}

class FileLogger : Logger {
    override fun log(message: String) {
        // Write to file
    }
}

class FirebaseAnalytics : Analytics {
    override fun track(event: String) {
        // Track to Firebase
    }
}

// Feature class delegates to both
class FeatureTracker(
    logger: Logger,
    analytics: Analytics
) : Logger by logger, Analytics by analytics {
    fun doSomething() {
        log("Doing something")
        track("something_done")
    }
}
```

## Custom Delegates

### Custom Property Delegate

```kotlinnimport kotlin.reflect.KProperty

// Singleton delegate
class SingletonDelegate<T>(private val creator: () -> T) {
    private var instance: T? = null
    
    operator fun getValue(thisRef: Any?, property: KProperty<*>): T {
        return instance ?: creator().also { instance = it }
    }
}

// Usage
val apiService: ApiService by SingletonDelegate {
    Retrofit.Builder()
        .baseUrl(BASE_URL)
        .build()
        .create(ApiService::class.java)
}
```

### Preference Delegate

```kotlinn// SharedPreferences delegate
class PreferenceDelegate<T>(
    private val prefs: SharedPreferences,
    private val key: String,
    private val defaultValue: T
) {
    @Suppress("UNCHECKED_CAST")
    operator fun getValue(thisRef: Any?, property: KProperty<*>): T {
        return when (defaultValue) {
            is String -> prefs.getString(key, defaultValue) as T
            is Int -> prefs.getInt(key, defaultValue) as T
            is Boolean -> prefs.getBoolean(key, defaultValue) as T
            is Long -> prefs.getLong(key, defaultValue) as T
            is Float -> prefs.getFloat(key, defaultValue) as T
            else -> throw IllegalArgumentException("Unsupported type")
        }
    }

    operator fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        with(prefs.edit()) {
            when (value) {
                is String -> putString(key, value)
                is Int -> putInt(key, value)
                is Boolean -> putBoolean(key, value)
                is Long -> putLong(key, value)
                is Float -> putFloat(key, value)
                else -> throw IllegalArgumentException("Unsupported type")
            }
            apply()
        }
    }
}

// Usage trong Activity
class SettingsActivity : AppCompatActivity() {
    private var darkMode: Boolean by PreferenceDelegate(
        prefs = getSharedPreferences("settings", Context.MODE_PRIVATE),
        key = "dark_mode",
        defaultValue = false
    )
}
```

### StateFlow Delegate

```kotlinn// Delegate MutableStateFlow như regular property
class StateFlowDelegate<T>(initialValue: T) {
    private val _state = MutableStateFlow(initialValue)
    val stateFlow: StateFlow<T> = _state.asStateFlow()
    
    operator fun getValue(thisRef: Any?, property: KProperty<*>): T {
        return _state.value
    }
    
    operator fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        _state.value = value
    }
}

// Usage trong ViewModel
class FeatureViewModel : ViewModel() {
    private var isLoading by StateFlowDelegate(false)
    val isLoadingFlow: StateFlow<Boolean> = isLoading.stateFlow
}
```

## Common Delegates

### NotNull

```kotlinn// Late initialization với safety
var name: String by Delegates.notNull()

fun init() {
    name = "John" // Phải set trước khi get
}
```

### ProvidingDelegate

```kotlinn// Factory cho delegates phức tạp
class ResourceDelegate<T>(
    private val loader: () -> T,
    private val disposer: (T) -> Unit
) {
    private var value: T? = null
    
    operator fun provideDelegate(
        thisRef: Any?, 
        property: KProperty<*>
    ): ReadOnlyProperty<Any?, T> {
        println("Creating delegate for ${property.name}")
        value = loader()
        return object : ReadOnlyProperty<Any?, T> {
            override fun getValue(thisRef: Any?, property: KProperty<*>): T {
                return value ?: throw IllegalStateException("Not loaded")
            }
        }
    }
}

// Usage
val resource: Resource by ResourceDelegate(
    loader = { loadResource() },
    disposer = { it.dispose() }
)
```

## Best Practices

### Khi nào dùng Delegation

| Pattern | Use Case |
|---------|----------|
| `by lazy` | Expensive initialization |
| `by observable` | React to property changes |
| `by vetoable` | Validate property values |
| `by map` | Dynamic objects, JSON-like |
| Interface `by` | Composition, code reuse |
| Custom delegates | Cross-cutting concerns |

### Performance Considerations

```kotlinn// Tốt - lazy cho expensive objects
val parser: JsonParser by lazy { JsonParser() }

// Tốt - reuse delegate instances
class ViewModel {
    private val prefsDelegate = PreferenceDelegate(
        getSharedPreferences("app", Context.MODE_PRIVATE)
    )
    
    var setting1: String by prefsDelegate.withKey("key1", "")
    var setting2: Int by prefsDelegate.withKey("key2", 0)
}

// Tránh - tạo delegate mỗi lần access
val bad: String by PreferenceDelegate(prefs, "key", "") // Tạo mỗi lần
```

## Android-Specific Patterns

### View Binding Delegate

```kotlinn// Auto-clear view binding
class ViewBindingDelegate<T : ViewBinding>(
    private val fragment: Fragment,
    private val viewBindingFactory: (View) -> T
) : ReadOnlyProperty<Fragment, T> {
    private var binding: T? = null

    init {
        fragment.lifecycle.addObserver(object : DefaultLifecycleObserver {
            override fun onDestroy(owner: LifecycleOwner) {
                binding = null
            }
        })
    }

    override fun getValue(thisRef: Fragment, property: KProperty<*>): T {
        return binding ?: viewBindingFactory(thisRef.requireView()).also {
            binding = it
        }
    }
}

// Usage
class MyFragment : Fragment(R.layout.fragment_my) {
    private val binding by ViewBindingDelegate(this) { 
        FragmentMyBinding.bind(it) 
    }
}
```

## References

- [references/custom-delegates.md](references/custom-delegates.md) - More custom delegate examples
- [references/android-delegates.md](references/android-delegates.md) - Android-specific delegates
