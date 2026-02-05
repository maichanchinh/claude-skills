# Compose Performance

Performance optimization patterns cho Jetpack Compose.

## Lazy Lists

### Keys

```kotlin
// Tốt - dùng items với key
LazyColumn {
    items(
        items = items,
        key = { it.id }
    ) { item ->
        ItemCard(item = item)
    }
}

// Tránh - không có key
LazyColumn {
    items(items) { item ->
        ItemCard(item = item)
    }
}
```

### Content Type

```kotlin
LazyColumn {
    items(
        items = mixedItems,
        key = { it.id },
        contentType = { it.type }
    ) { item ->
        when (item) {
            is HeaderItem -> Header(item)
            is ContentItem -> Content(item)
        }
    }
}
```

### LazyListState

```kotlin
val listState = rememberLazyListState()

LazyColumn(state = listState) {
    items(items) { item ->
        ItemCard(item = item)
    }
}

// Scroll to top
val scope = rememberCoroutineScope()
scope.launch {
    listState.scrollToItem(0)
}
```

## Derived State

### Expensive Calculations

```kotlin
// Tốt - dùng derivedStateOf
val sortedItems by remember(items) {
    derivedStateOf { items.sortedBy { it.priority } }
}

// Tránh - calculation mỗi recomposition
val sortedItems = items.sortedBy { it.priority }
```

### Visibility Threshold

```kotlin
val isVisible by remember {
    derivedStateOf { listState.firstVisibleItemIndex > 0 }
}

AnimatedVisibility(visible = isVisible) {
    ScrollToTopButton()
}
```

## Side Effects

### LaunchedEffect

```kotlin
// Chạy coroutine khi key change
LaunchedEffect(userId) {
    viewModel.loadUser(userId)
}

// Chỉ chạy một lần
LaunchedEffect(Unit) {
    analytics.trackScreenView(screenName)
}
```

### DisposableEffect

```kotlin
// Cleanup khi key change
DisposableEffect(lifecycleOwner) {
    val observer = LifecycleEventObserver { _, event ->
        // Handle event
    }
    lifecycleOwner.lifecycle.addObserver(observer)
    
    onDispose {
        lifecycleOwner.lifecycle.removeObserver(observer)
    }
}
```

### SideEffect

```kotlin
// Gọi code với mỗi recomposition
SideEffect {
    analytics.trackScreenView(screenName)
}
```

### SnapshotFlow

```kotlin
// Convert Compose state thành Flow
val scrollOffsetFlow = snapshotFlow { listState.firstVisibleItemScrollOffset }

LaunchedEffect(Unit) {
    scrollOffsetFlow
        .map { offset -> offset > 100 }
        .distinctUntilChanged()
        .collect { showShadow = it }
}
```

## Remember Patterns

### remember vs rememberSaveable

```kotlinn// Không cần survive config change
var isVisible by remember { mutableStateOf(false) }

// Cần survive config change  
var text by rememberSaveable { mutableStateOf("") }

// Với custom saver
var customState by rememberSaveable(
    stateSaver = CustomStateSaver
) { mutableStateOf(CustomState()) }
```

### rememberUpdatedState

```kotlinn// Khi cần reference đến latest value trong side effect
val currentOnTimeout by rememberUpdatedState(onTimeout)

LaunchedEffect(Unit) {
    delay(timeoutMillis)
    currentOnTimeout() // Luôn gọi latest value
}
```

## Stability

### Immutable Data Classes

```kotlinn// Tốt - stable
@Immutable
data class User(val id: String, val name: String)

// Không tốt - unstable
class User(val id: String, val name: String) // Mutable
```

### Stable Markers

```kotlinn@Stable
interface UiState {
    val isLoading: Boolean
    val data: List<Item>
}

@Immutable
data class FeatureUiState(
    override val isLoading: Boolean = false,
    override val data: List<Item> = emptyList()
) : UiState
```

## Best Practices

### DO
- ✅ Use `key` in lazy lists
- ✅ Hoist state properly
- ✅ Use `derivedStateOf` cho expensive calculations
- ✅ Avoid creating objects trong composition
- ✅ Use `@Immutable` cho data classes

### DON'T
- ❌ Pass unstable types to composables
- ❌ Create lambdas mà không nhớ chúng
- ❌ Do heavy work trong composition
- ❌ Use `rememberSaveable` cho large objects

### Lambda Memoization

```kotlin
// Tốt - nhớ lambda
elevatedButton(
    onClick = remember { { viewModel.submit() } }
)

// Tránh - tạo mới mỗi lần
elevatedButton(
    onClick = { viewModel.submit() }
)
```
