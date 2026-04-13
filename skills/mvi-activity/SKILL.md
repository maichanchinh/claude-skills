---
name: mvi-activity
description: Lean MVI pattern for Android Activities with Jetpack Compose. Use when creating Compose-first Activity screens with UiState, Action, Event, StateFlow, SharedFlow, and a small ViewModel boundary.
---

# MVI Activity

Pattern tối giản cho Android Activity dùng Compose:
- `Activity` dựng UI và xử lý `Event`
- `Screen` chỉ nhận `UiState` + `onAction`
- `ViewModel` giữ `StateFlow` + `SharedFlow`
- `Repository` hoặc `UseCase` nằm sau `ViewModel`

## Minimal Structure

```text
feature/
├── FeatureActivity.kt
├── FeatureScreen.kt
├── FeatureViewModel.kt
├── FeatureUiState.kt
├── FeatureAction.kt
└── FeatureEvent.kt
```

## Rules

- `Screen` không nhận `ViewModel`
- Mọi input từ UI đi qua `FeatureAction`
- UI state là immutable `data class`
- One-off side effects đi qua `FeatureEvent`
- `Activity` xử lý navigation, `Toast`, launcher result
- Ưu tiên `by viewModels()` và `by lazy` nếu thật sự giúp giảm boilerplate

## Activity

```kotlin
@AndroidEntryPoint
class FeatureActivity : ComponentActivity() {
    private val viewModel: FeatureViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            AppTheme {
                val uiState by viewModel.uiState.collectAsState()
                FeatureScreen(
                    uiState = uiState,
                    onAction = viewModel::handleAction
                )
            }
        }

        lifecycleScope.launch {
            viewModel.events.collect { event ->
                handleEvent(event)
            }
        }
    }

    private fun handleEvent(event: FeatureEvent) {
        when (event) {
            FeatureEvent.NavigateBack -> finish()
            is FeatureEvent.ShowMessage -> Toast.makeText(this, event.message, Toast.LENGTH_SHORT).show()
        }
    }
}
```

## Screen

```kotlin
@Composable
fun FeatureScreen(
    uiState: FeatureUiState,
    onAction: (FeatureAction) -> Unit
) {
    Scaffold(
        topBar = {
            FeatureTopBar(onBackClick = { onAction(FeatureAction.BackClicked) })
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when {
                uiState.isLoading -> CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                uiState.errorMessage != null -> ErrorMessage(uiState.errorMessage)
                else -> {
                    FeatureContent(
                        data = uiState.data,
                        onItemClick = { id -> onAction(FeatureAction.ItemClicked(id)) }
                    )
                }
            }
        }
    }
}
```

## ViewModel

```kotlin
@HiltViewModel
class FeatureViewModel @Inject constructor(
    private val repository: FeatureRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(FeatureUiState())
    val uiState: StateFlow<FeatureUiState> = _uiState.asStateFlow()

    private val _events = MutableSharedFlow<FeatureEvent>()
    val events = _events.asSharedFlow()

    init {
        loadData()
    }

    fun handleAction(action: FeatureAction) {
        when (action) {
            FeatureAction.BackClicked -> emitBack()
            is FeatureAction.ItemClicked -> selectItem(action.id)
            FeatureAction.RetryClicked -> loadData()
        }
    }

    private fun loadData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            runCatching { repository.getItems() }
                .onSuccess { items ->
                    _uiState.update { it.copy(data = items, isLoading = false) }
                }
                .onFailure { error ->
                    _uiState.update { it.copy(errorMessage = error.message, isLoading = false) }
                }
        }
    }

    private fun selectItem(id: String) {
        viewModelScope.launch {
            _events.emit(FeatureEvent.OpenDetail(id))
        }
    }

    private fun emitBack() {
        viewModelScope.launch {
            _events.emit(FeatureEvent.NavigateBack)
        }
    }
}
```

## State / Action / Event

```kotlin
data class FeatureUiState(
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val data: List<Item> = emptyList()
)

sealed interface FeatureAction {
    data object BackClicked : FeatureAction
    data object RetryClicked : FeatureAction
    data class ItemClicked(val id: String) : FeatureAction
}

sealed interface FeatureEvent {
    data object NavigateBack : FeatureEvent
    data class OpenDetail(val id: String) : FeatureEvent
    data class ShowMessage(val message: String) : FeatureEvent
}
```

## Compose + Coroutine Notes

- Dùng `collectAsState()` cho render state
- Dùng `MutableStateFlow` + `update { copy(...) }` cho atomic update
- Dùng `MutableSharedFlow` cho navigation, snackbar, toast
- Nếu cần init object nặng trong `Activity` hoặc `ViewModel`, dùng `by lazy` thay vì custom delegation

## Boundary

```kotlin
interface FeatureRepository {
    suspend fun getItems(): List<Item>
}
```

- `ViewModel` gọi `Repository` hoặc một `UseCase` mỏng
- Không nhét navigation, Android framework API, hoặc Compose state cục bộ vào repository

## Avoid

- `Screen` tự gọi repository hoặc giữ business logic
- Nhiều `LiveData`/state rời rạc cho cùng một screen
- Dùng `StateFlow` cho one-time event
- Đưa catalog design patterns tổng quát vào skill này
