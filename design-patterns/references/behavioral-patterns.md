# Behavioral Patterns

Patterns quản lý communication và responsibilities giữa objects.

## Strategy Pattern

Define family of algorithms, interchangeable.

```kotlin
interface SortStrategy {
    fun <T : Comparable<T>> sort(list: List<T>): List<T>
}

class QuickSort : SortStrategy {
    override fun <T : Comparable<T>> sort(list: List<T>): List<T> {
        if (list.size <= 1) return list
        val pivot = list[list.size / 2]
        val equal = list.filter { it == pivot }
        val less = list.filter { it < pivot }
        val greater = list.filter { it > pivot }
        return sort(less) + equal + sort(greater)
    }
}

class MergeSort : SortStrategy {
    override fun <T : Comparable<T>> sort(list: List<T>): List<T> {
        if (list.size <= 1) return list
        val mid = list.size / 2
        val left = sort(list.subList(0, mid))
        val right = sort(list.subList(mid, list.size))
        return merge(left, right)
    }

    private fun <T : Comparable<T>> merge(left: List<T>, right: List<T>): List<T> {
        val result = mutableListOf<T>()
        var i = 0
        var j = 0
        while (i < left.size && j < right.size) {
            if (left[i] <= right[j]) {
                result.add(left[i++])
            } else {
                result.add(right[j++])
            }
        }
        result.addAll(left.subList(i, left.size))
        result.addAll(right.subList(j, right.size))
        return result
    }
}

class Sorter(private var strategy: SortStrategy) {
    fun <T : Comparable<T>> sort(list: List<T>): List<T> = strategy.sort(list)
    fun setStrategy(strategy: SortStrategy) {
        this.strategy = strategy
    }
}

// Usage
val sorter = Sorter(QuickSort())
val sorted = sorter.sort(listOf(3, 1, 4, 1, 5))
sorter.setStrategy(MergeSort())
```

## Observer Pattern

Reactive data flow, one-to-many dependency.

```kotlin
interface Observer<T> {
    fun onChanged(data: T)
}

interface Observable<T> {
    fun addObserver(observer: Observer<T>)
    fun removeObserver(observer: Observer<T>)
    fun notifyObservers(data: T)
}

class LiveData<T> : Observable<T> {
    private val observers = mutableListOf<Observer<T>>()
    private var data: T? = null

    override fun addObserver(observer: Observer<T>) {
        observers.add(observer)
    }

    override fun removeObserver(observer: Observer<T>) {
        observers.remove(observer)
    }

    override fun notifyObservers(data: T) {
        this.data = data
        observers.forEach { it.onChanged(data) }
    }

    fun setValue(value: T) {
        notifyObservers(value)
    }
}

// Usage
val liveData = LiveData<String>()
liveData.addObserver(object : Observer<String> {
    override fun onChanged(data: String) {
        println("Updated: $data")
    }
})
liveData.setValue("Hello") // All observers notified
```

## Command Pattern

Encapsulate requests as objects.

```kotlin
interface Command {
    fun execute()
    fun undo()
}

class AddTextCommand(
    private val document: Document,
    private val text: String
) : Command {
    override fun execute() {
        document.append(text)
    }

    override fun undo() {
        document.remove(text)
    }
}

class CommandManager {
    private val commands = mutableListOf<Command>()
    private var currentIndex = -1

    fun execute(command: Command) {
        command.execute()
        commands.add(++currentIndex, command)
    }

    fun undo() {
        if (currentIndex >= 0) {
            commands[currentIndex--].undo()
        }
    }

    fun redo() {
        if (currentIndex < commands.size - 1) {
            commands[++currentIndex].execute()
        }
    }
}

// Usage
val manager = CommandManager()
val document = Document()
manager.execute(AddTextCommand(document, "Hello"))
manager.execute(AddTextCommand(document, " World"))
manager.undo() // Removes " World"
manager.redo() // Adds " World" back
```

## Other Behavioral Patterns

### Template Method Pattern

```kotlin
abstract class DataParser {
    fun parse(file: File): List<Record> {
        val content = readFile(file)
        val lines = splitLines(content)
        return lines.map { parseLine(it) }
    }

    protected abstract fun readFile(file: File): String
    protected abstract fun splitLines(content: String): List<String>
    protected abstract fun parseLine(line: String): Record
}

class CsvParser : DataParser() {
    override fun readFile(file: File) = file.readText()
    override fun splitLines(content: String) = content.split("\n")
    override fun parseLine(line: String) = Record(line.split(","))
}

class JsonParser : DataParser() {
    override fun readFile(file: File) = file.readText()
    override fun splitLines(content: String) = parseJsonArray(content)
    override fun parseLine(line: String) = Record(parseJsonObject(line))
}
```

### State Pattern

```kotlin
interface State {
    fun handle(context: Context)
}

class DraftState : State {
    override fun handle(context: Context) {
        println("Draft: Can edit and save")
        context.state = ReviewState()
    }
}

class ReviewState : State {
    override fun handle(context: Context) {
        println("Review: Can approve or reject")
        context.state = PublishedState()
    }
}

class PublishedState : State {
    override fun handle(context: Context) {
        println("Published: View only")
    }
}

class Context {
    var state: State = DraftState()
    fun request() = state.handle(this)
}
```

## When to Use

| Pattern | Use When |
|---------|----------|
| Strategy | Interchangeable algorithms |
| Observer | Reactive updates, event handling |
| Command | Undo/redo, request queuing |
| Template Method | Common algorithm steps, vary specifics |
| State | Object behavior changes based on state |
