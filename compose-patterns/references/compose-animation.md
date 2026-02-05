# Compose Animation

Animation patterns cho Jetpack Compose.

## Visibility Animations

### AnimatedVisibility

```kotlin
var isVisible by remember { mutableStateOf(false) }

AnimatedVisibility(
    visible = isVisible,
    enter = fadeIn() + slideInVertically(),
    exit = fadeOut() + slideOutVertically()
) {
    Text("Now you see me")
}
```

### Expand/Collapse

```kotlin
AnimatedVisibility(
    visible = isExpanded,
    enter = expandVertically(),
    exit = shrinkVertically()
) {
    Column {
        Text("Content 1")
        Text("Content 2")
    }
}
```

## Content Animations

### AnimatedContent

```kotlin
AnimatedContent(
    targetState = selectedTab,
    transitionSpec = {
        fadeIn() + slideInHorizontally { it } togetherWith
        fadeOut() + slideOutHorizontally { -it }
    }
) { tab ->
    when (tab) {
        Tab.HOME -> HomeScreen()
        Tab.PROFILE -> ProfileScreen()
    }
}
```

### Crossfade

```kotlin
Crossfade(
    targetState = selectedTab,
    animationSpec = tween(300)
) { tab ->
    when (tab) {
        Tab.HOME -> HomeScreen()
        Tab.PROFILE -> ProfileScreen()
    }
}
```

## State-based Animations

### animate*AsState

```kotlin
val alpha by animateFloatAsState(
    targetValue = if (isVisible) 1f else 0f,
    animationSpec = tween(300)
)

val size by animateDpAsState(
    targetValue = if (isExpanded) 200.dp else 100.dp,
    animationSpec = spring(
        dampingRatio = Spring.DampingRatioMediumBouncy,
        stiffness = Spring.StiffnessLow
    )
)

val color by animateColorAsState(
    targetValue = if (isSelected) Color.Blue else Color.Gray
)
```

### updateTransition

```kotlin
val transition = updateTransition(isExpanded, label = "expand")

val size by transition.animateDp(label = "size") { state ->
    if (state) 200.dp else 100.dp
}

val color by transition.animateColor(label = "color") { state ->
    if (state) Color.Blue else Color.Gray
}

val alpha by transition.animateFloat(label = "alpha") { state ->
    if (state) 1f else 0.5f
}
```

## Gesture Animations

### animateScrollBy

```kotlin
val scope = rememberCoroutineScope()
val listState = rememberLazyListState()

Button(onClick = {
    scope.launch {
        listState.animateScrollBy(100f)
    }
}) {
    Text("Scroll")
}
```

### animateTo

```kotlin
val draggableState = rememberDraggableState { delta ->
    offset += delta
}

scope.launch {
    draggableState.animateTo(0f, SpringSpec())
}
```

## Custom Animations

### AnimationSpec

```kotlin
// Tween - time-based
val alpha = animateFloatAsState(
    targetValue = 1f,
    animationSpec = tween(
        durationMillis = 300,
        easing = FastOutSlowInEasing
    )
)

// Spring - physics-based
val size = animateDpAsState(
    targetValue = 100.dp,
    animationSpec = spring(
        dampingRatio = Spring.DampingRatioMediumBouncy,
        stiffness = Spring.StiffnessLow
    )
)

// Keyframes
val value = animateFloatAsState(
    targetValue = 1f,
    animationSpec = keyframes {
        durationMillis = 300
        0.0f at 0
        0.5f at 100
        1.0f at 300
    }
)
```

### Infinite Animation

```kotlinnval infiniteTransition = rememberInfiniteTransition(label = "infinite")

val scale by infiniteTransition.animateFloat(
    initialValue = 1f,
    targetValue = 1.2f,
    animationSpec = infiniteRepeatable(
        animation = tween(1000),
        repeatMode = RepeatMode.Reverse
    ),
    label = "scale"
)

val rotation by infiniteTransition.animateFloat(
    initialValue = 0f,
    targetValue = 360f,
    animationSpec = infiniteRepeatable(
        animation = tween(2000, easing = LinearEasing),
        repeatMode = RepeatMode.Restart
    ),
    label = "rotation"
)
```

## Best Practices

### DO
- ✅ Use `togetherWith` cho enter/exit pairs
- ✅ Set `label` cho transitions (debugging)
- ✅ Use `spring` cho natural motion
- ✅ Prefer `animate*AsState` cho simple animations

### DON'T
- ❌ Animate nhiều properties independently nếu liên quan
- ❌ Use long durations (>500ms)
- ❌ Forget content keys trong AnimatedContent

### Performance

```kotlin
// Tốt - use graphicsLayer cho frequent updates
Box(
    modifier = Modifier.graphicsLayer {
        alpha = animatedAlpha
        scaleX = animatedScale
        scaleY = animatedScale
    }
)

// Tránh - recomposition mỗi frame
Box(
    modifier = Modifier
        .alpha(animatedAlpha)
        .scale(animatedScale)
)
```
