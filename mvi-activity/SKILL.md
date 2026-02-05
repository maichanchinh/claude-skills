---
name: mvi-activity
description: MVI (Model-View-Intent) pattern implementation for Android Activities with Jetpack Compose. Use when creating new Activity screens with MVI architecture, implementing screen state management with sealed classes, handling user actions/events, or structuring Compose-based Activities with ViewModel separation.
---

# MVI Activity Pattern

MVI pattern implementation cho Android Activities sử dụng Jetpack Compose với separation of concerns rõ ràng giữa Activity, Screen, ViewModel và State.

## Core Architecture

### File Structure

```
feature/
├── FeatureActivity.kt      # Entry point, event handling
├── FeatureScreen.kt        # UI (100% Compose)
├── FeatureViewModel.kt     # Business logic, state management
├── FeatureUiState.kt       # Immutable state model
├── FeatureAction.kt        # User actions (sealed class)
└── FeatureEvent.kt         # ViewModel -> Activity events
```

### Key Principles

1. **Screen không nhận ViewModel** - Screen chỉ nhận `UiState` và `onAction` callback
2. **Single entry point** - Mọi user action đi qua sealed class Action
3. **StateFlow cho UI** - `_uiState: MutableStateFlow<UiState>` với `asStateFlow()`
4. **SharedFlow cho Events** - `_events: MutableSharedFlow<Event>` cho navigation/messages
5. **Activity xử lý Events** - Navigation, Toast, Activity Result từ Events

## Activity Template

```kotlin
@AndroidEntryPoint
class FeatureActivity : ComponentActivity() {

    companion object {
        fun newInstance(context: Context) = Intent(context, FeatureActivity::class.java)
    }

    private val viewModel: FeatureViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            AppTheme {
                val uiState by viewModel.uiState.collectAsState()
                
                FeatureScreen(
                    uiState = uiState,
                    onAction = { action -> viewModel.handleAction(action) }
                )
            }
        }

        // Collect events cho navigation và side effects
        lifecycleScope.launch {
            viewModel.events.collect { event ->
                handleEvent(event)
            }
        }
    }

    private fun handleEvent(event: FeatureEvent) {
        when (event) {
            is FeatureEvent.Navigation.NavigateBack -> finish()
            is FeatureEvent.Message -> {
                Toast.makeText(this, event.message, Toast.LENGTH_SHORT).show()
            }
        }
    }
}
```

## Screen Template

```kotlin
@Composable
fun FeatureScreen(
    uiState: FeatureUiState,
    onAction: (FeatureAction) -> Unit
) {
    Scaffold(
        topBar = {
            FeatureTopBar(
                onBackClick = { onAction(FeatureAction.NavigateBack) }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Content dựa trên state
            when {
                uiState.isLoading -> {
                    CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                }
                uiState.errorMessage != null -> {
                    ErrorMessage(message = uiState.errorMessage)
                }
                else -> {
                    FeatureContent(
                        data = uiState.data,
                        onItemClick = { id -> 
                            onAction(FeatureAction.SelectItem(id)) 
                        }
                    )
                }
            }
        }
    }
}
```

## ViewModel Template

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
            is FeatureAction.NavigateBack -> navigateBack()
            is FeatureAction.SelectItem -> selectItem(action.id)
        }
    }

    private fun navigateBack() {
        viewModelScope.launch {
            _events.emit(FeatureEvent.Navigation.NavigateBack)
        }
    }

    private fun selectItem(id: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                val result = repository.getItem(id)
                _uiState.update { 
                    it.copy(data = result, isLoading = false) 
                }
            } catch (e: Exception) {
                _uiState.update { 
                    it.copy(errorMessage = e.message, isLoading = false) 
                }
            }
        }
    }
}
```

## State Definition

```kotlin
data class FeatureUiState(
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val data: List<Item> = emptyList(),
    val selectedId: String = "",
    // Boolean flags cho conditional UI
    val showDialog: Boolean = false
)
```

## Action Sealed Class

```kotlin
sealed class FeatureAction {
    data object NavigateBack : FeatureAction()
    data class SelectItem(val id: String) : FeatureAction()
    data class UpdateText(val text: String) : FeatureAction()
}
```

## Event Sealed Class

```kotlin
sealed class FeatureEvent {
    sealed class Navigation : FeatureEvent() {
        data object NavigateBack : Navigation()
        data class NavigateToDetail(val id: String) : Navigation()
    }
    data class Message(val message: String) : FeatureEvent()
}
```

## Best Practices

### State Updates

- Luôn dùng `StateFlow.update { it.copy(...) }` cho atomic updates
- Tránh tạo nhiều state variables riêng lẻ
- Sử dụng data class để group related state

### Action Handling

- Mỗi action nên có 1 mục đích rõ ràng
- Không xử lý business logic trong Screen
- Chuyển đổi action phức tạp trong Activity trước khi gọi ViewModel

### Event vs State

| Event | State |
|-------|-------|
| Navigation | Loading indicators |
| Toast/Snackbar | Data display |
| Activity Result | Selected items |
| One-time actions | Toggle states |

### Component Reusability

- Components không nhận ViewModel, chỉ nhận lambda callbacks
- Tách components thành các file riêng trong package `components/`
- Luôn viết Preview cho components

## Examples

Xem [references/mvi-examples.md](references/mvi-examples.md) cho các ví dụ thực tế:
- Activity với ActivityResultLauncher
- Multiple screens trong 1 Activity
- Dialog và BottomSheet handling
- Error handling patterns
