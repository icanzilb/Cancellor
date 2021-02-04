# Cancellor

Bind multiple cancellables to the lifetime of another object like your view controller.

## Usage

Import **Cancellor** and subscribe your publishers inside an `ownedCancellables` block. When your view controller is dismissed any active subscriptions will get cancelled automatically. 

```swift
import Cancellor

class MyViewController: UIViewController {
  override func viewDidLoad() {
    ownedCancellables {
      myPublisher1.sink(...)
      myPublisher2.sink(...)
      myPublisher3.assign(to: ..., on: ...)
    }
  }
}
```

To tie a subscription to the lifetime of another object use:

```swift
class ViewModel: NSObject { ... }
let vm = ViewModel(...)

...

myPublisher
  .sink(...)
  .owned(by: vm)
```

## Import

Add the following dependency to your **Package.swift** file:

```swift
.package(url: "https://github.com/icanzilb/Cancellor, from: "0.1.0")
```

## License

Cancellor is available under the MIT license. See the LICENSE file for more info.

## Credits

Created by Marin Todorov. 

📚 You can support me by checking out our Combine book: [combinebook.com](http://combinebook.com).

Inspired by Ash Furrow's [NSObject-rx](https://github.com/RxSwiftCommunity/NSObject-Rx).

Name by https://github.com/manmal.
