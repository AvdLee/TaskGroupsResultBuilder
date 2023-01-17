# TaskGroupsResultBuilder
This project demonstrates how you can use a [@resultBuilder](https://www.avanderlee.com/swift/result-builders/) in combination with TaskGroup.

### Example
```swift
let photoURLs = try await listPhotoURLs(inGallery: "Amsterdam Holiday")
let images = try await withThrowingTaskGroup {
    for photoURL in photoURLs {
        Task { try await downloadPhoto(url: photoURL) }
    }
}
```

Or:

```swift
func taskGroupExampleThree() async {
    let names = await withTaskGroup {
        Task {
            await asyncOperation(name: "Antoine")
        }
        Task {
            await asyncOperation(name: "Maaike")
        }
        Task {
            await asyncOperation(name: "Sep")
        }
    }
    print("Received: \(names)") // Received: ["Antoine", "Maaike", "Sep"]
}
```
