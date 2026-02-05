# Compose Previews

Detailed patterns for writing effective Compose previews.

## Screen Previews

### Multiple Themes

```kotlin
@Preview(
    name = "Light Mode",
    showBackground = true
)
@Preview(
    name = "Dark Mode",
    showBackground = true,
    uiMode = Configuration.UI_MODE_NIGHT_YES
)
@Composable
fun FeatureScreenPreview() {
    AppTheme {
        FeatureScreen(
            uiState = FeatureUiState(
                items = listOf(
                    Item(id = "1", name = "Item 1"),
                    Item(id = "2", name = "Item 2")
                )
            ),
            onAction = {}
        )
    }
}
```

### Different Sizes

```kotlin
@Preview(
    name = "Phone",
    device = "id:pixel_5",
    showSystemUi = true
)
@Preview(
    name = "Tablet",
    device = "id:pixel_c",
    showSystemUi = true
)
@Composable
fun ResponsiveScreenPreview() {
    AppTheme {
        FeatureScreen(uiState = FeatureUiState(), onAction = {})
    }
}
```

## State-Based Previews

### Loading State

```kotlin
@Preview(name = "Loading", showBackground = true)
@Composable
fun FeatureScreenLoadingPreview() {
    AppTheme {
        FeatureScreen(
            uiState = FeatureUiState(isLoading = true),
            onAction = {}
        )
    }
}
```

### Error State

```kotlin
@Preview(name = "Error", showBackground = true)
@Composable
fun FeatureScreenErrorPreview() {
    AppTheme {
        FeatureScreen(
            uiState = FeatureUiState(errorMessage = "Failed to load"),
            onAction = {}
        )
    }
}
```

### Empty State

```kotlin
@Preview(name = "Empty", showBackground = true)
@Composable
fun FeatureScreenEmptyPreview() {
    AppTheme {
        FeatureScreen(
            uiState = FeatureUiState(data = emptyList()),
            onAction = {}
        )
    }
}
```

## Component Previews

### Interactive Components

```kotlin
@Preview(name = "Selected", showBackground = true)
@Composable
fun SelectableCardSelectedPreview() {
    AppTheme {
        SelectableCard(
            title = "Selected Card",
            isSelected = true,
            onClick = {}
        )
    }
}

@Preview(name = "Unselected", showBackground = true)
@Composable
fun SelectableCardUnselectedPreview() {
    AppTheme {
        SelectableCard(
            title = "Unselected Card",
            isSelected = false,
            onClick = {}
        )
    }
}

@Preview(name = "Disabled", showBackground = true)
@Composable
fun SelectableCardDisabledPreview() {
    AppTheme {
        SelectableCard(
            title = "Disabled Card",
            isSelected = false,
            onClick = {},
            enabled = false
        )
    }
}
```

### List Components

```kotlin
@Preview(name = "Item List", showBackground = true)
@Composable
fun ItemListPreview() {
    AppTheme {
        LazyColumn {
            items(5) { index ->
                ItemCard(
                    item = Item("$index", "Item $index"),
                    onClick = {}
                )
            }
        }
    }
}
```

## Preview Parameters

### Using PreviewParameterProvider

```kotlin
class UserPreviewParameterProvider : PreviewParameterProvider<User> {
    override val values = sequenceOf(
        User("1", "John Doe", "john@example.com"),
        User("2", "Jane Smith", "jane@example.com"),
        User("3", "", "") // Edge case
    )
}

@Preview(showBackground = true)
@Composable
fun UserCardPreview(
    @PreviewParameter(UserPreviewParameterProvider::class) user: User
) {
    AppTheme {
        UserCard(user = user, onClick = {})
    }
}
```

### Locale Previews

```kotlin
@Preview(name = "English", locale = "en")
@Preview(name = "Vietnamese", locale = "vi")
@Preview(name = "Japanese", locale = "ja")
@Composable
fun LocalizedScreenPreview() {
    AppTheme {
        FeatureScreen(uiState = FeatureUiState(), onAction = {})
    }
}
```

## Best Practices

### DO
- ✅ Preview all states (loading, error, empty, content)
- ✅ Use multiple themes (light/dark)
- ✅ Preview different screen sizes
- ✅ Provide sample data
- ✅ Group related previews

### DON'T
- ❌ Forget background color (showBackground = true)
- ❌ Use real data in previews
- ❌ Preview with ViewModel dependencies
- ❌ Ignore edge cases

### Font Scale Previews

```kotlin
@Preview(name = "Default Font", fontScale = 1f)
@Preview(name = "Large Font", fontScale = 1.5f)
@Preview(name = "Extra Large Font", fontScale = 2f)
@Composable
fun AccessibilityPreview() {
    AppTheme {
        FeatureScreen(uiState = FeatureUiState(), onAction = {})
    }
}
```
