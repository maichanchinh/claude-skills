---
name: design-patterns
description: SOLID principles and essential design patterns for Kotlin Android development. Use when designing class hierarchies, implementing dependency injection, structuring repositories, applying MVVM architecture, or understanding SOLID principles.
---

# Design Patterns

SOLID principles và core design patterns cho clean Kotlin Android code.

## SOLID Principles

### Single Responsibility Principle (SRP)

```kotlin
// Không tốt - nhiều trách nhiệm
class UserManager {
    fun createUser(name: String) { /* ... */ }
    fun saveToDatabase(user: User) { /* ... */ }
    fun sendEmail(user: User) { /* ... */ }
    fun generateReport(user: User) { /* ... */ }
}

// Tốt - mỗi class một trách nhiệm
class UserCreator(private val validator: UserValidator) {
    fun create(name: String): User {
        validator.validate(name)
        return User(name)
    }
}

class UserRepository(private val database: Database) {
    fun save(user: User) { /* ... */ }
}

class EmailService {
    fun sendWelcomeEmail(user: User) { /* ... */ }
}
```

### Open/Closed Principle (OCP)

```kotlin
// Tốt - mở rộng bằng cách thêm class mới
interface Shape {
    fun area(): Double
}

class Rectangle(val width: Double, val height: Double) : Shape {
    override fun area() = width * height
}

class Circle(val radius: Double) : Shape {
    override fun area() = Math.PI * radius * radius
}

// Triangle thêm mà không sửa code cũ
class Triangle(val base: Double, val height: Double) : Shape {
    override fun area() = 0.5 * base * height
}
```

### Liskov Substitution Principle (LSP)

```kotlin
// Tốt - dùng interface chung
interface Shape {
    fun area(): Int
}

class Rectangle(val width: Int, val height: Int) : Shape {
    override fun area() = width * height
}

class Square(val side: Int) : Shape {
    override fun area() = side * side
}
```

### Interface Segregation Principle (ISP)

```kotlin
// Tốt - tách thành interfaces nhỏ
interface Workable {
    fun work()
}

interface Feedable {
    fun eat()
}

// Robot chỉ cần implement Workable
class Robot : Workable {
    override fun work() { /* ... */ }
}

// Human implement tất cả
class Human : Workable, Feedable {
    override fun work() { /* ... */ }
    override fun eat() { /* ... */ }
}
```

### Dependency Inversion Principle (DIP)

```kotlin
// Tốt - phụ thuộc abstraction
interface UserRepository {
    fun getUser(id: String): User
}

class UserRepositoryImpl : UserRepository {
    override fun getUser(id: String): User { /* ... */ }
}

class UserService(private val repository: UserRepository) {
    fun getUser(id: String) = repository.getUser(id)
}

// Hilt/Dagger
@HiltViewModel
class UserViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel()
```

## Core Patterns

### Repository Pattern

```kotlin
interface UserRepository {
    suspend fun getUser(id: String): User
    suspend fun saveUser(user: User)
    fun getUsersStream(): Flow<List<User>>
}

class UserRepositoryImpl @Inject constructor(
    private val api: UserApi,
    private val dao: UserDao,
    @IoDispatcher private val dispatcher: CoroutineDispatcher
) : UserRepository {

    override suspend fun getUser(id: String): User = withContext(dispatcher) {
        dao.getUser(id)?.toDomain() ?: api.getUser(id).toDomain()
    }

    override suspend fun saveUser(user: User) = withContext(dispatcher) {
        dao.insert(user.toEntity())
    }

    override fun getUsersStream(): Flow<List<User>> {
        return dao.getAll()
            .map { entities -> entities.map { it.toDomain() } }
            .flowOn(dispatcher)
    }
}
```

### MVVM Pattern

```kotlin
@HiltViewModel
class FeatureViewModel @Inject constructor(
    private val repository: FeatureRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(FeatureUiState())
    val uiState: StateFlow<FeatureUiState> = _uiState.asStateFlow()

    fun loadData() {
        viewModelScope.launch {
            repository.getData()
                .onStart { _uiState.update { it.copy(isLoading = true) } }
                .catch { e -> _uiState.update { it.copy(error = e.message) } }
                .collect { data -> 
                    _uiState.update { it.copy(data = data, isLoading = false) } 
                }
        }
    }
}

@Composable
fun FeatureScreen(viewModel: FeatureViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsState()
    // UI implementation
}
```

### Clean Architecture

```kotlin
// Domain layer
interface GetUserUseCase {
    suspend operator fun invoke(id: String): User
}

// Data layer
class GetUserUseCaseImpl @Inject constructor(
    private val repository: UserRepository
) : GetUserUseCase {
    override suspend fun invoke(id: String): User {
        return repository.getUser(id)
    }
}

// Presentation layer
@HiltViewModel
class UserViewModel @Inject constructor(
    private val getUser: GetUserUseCase
) : ViewModel()
```

## Quick Reference

### Creational Patterns
- **Factory**: Tạo objects mà không expose logic
- **Builder**: Xây dựng objects phức tạp step-by-step  
- **Singleton**: Một instance duy nhất

Xem chi tiết: [references/creational-patterns.md](references/creational-patterns.md)

### Structural Patterns
- **Adapter**: Convert interface sang interface khác
- **Facade**: Đơn giản hóa complex subsystem

Xem chi tiết: [references/structural-patterns.md](references/structural-patterns.md)

### Behavioral Patterns
- **Strategy**: Define family of algorithms
- **Observer**: Reactive data flow
- **Command**: Encapsulate requests

Xem chi tiết: [references/behavioral-patterns.md](references/behavioral-patterns.md)
