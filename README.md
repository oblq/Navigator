# 🚣 Navigator

[![Swift4 compatible][Swift4Badge]][Swift4Link]

Easily find and navigate to any ViewController inside your app by passing just 
the class Type and get the instance synchronously or asynchronously (on the main thread).
Navigator is a central navigation system for your application.
This way the code becomes declarative and decoupled, so that **Navigator.swift** 
does not need to know what is presenting.
It also makes simple to handle external requests such as deep linking.  


## Usage

Getting your UIViewController instance synchronously:
```swift
let MyViewControllerInstance = Navigator.find(MyViewController.self)
MyViewControllerInstance?.doSomethingSync()
```
or...
```swift
Navigator.find(MyViewController.self)?.doSomethingSync()
```


Getting your UIViewController instance asynchronously, on the main thread:
```swift
Navigator.find(MyViewController.self) { (MyViewControllerContainer, MyViewControllerInstance) in
    MyViewControllerInstance?.doSomethingAsync()
}
```

...and automatically navigate to it:
```swift
Navigator.navigate(to: MyViewController.self)?.doSomethingSync()

Navigator.navigate(to: MyViewController.self) { (MyViewControllerContainer, MyViewControllerInstance) in
    MyViewControllerInstance?.doSomethingAsync()
}
```

## Globals
```swift
APP_DELEGATE // Returns the AppDelegate
APP_WINDOW // Returns the App Window
APP_ROOT // Returns the root viewController also if it is not in the view hierarchy
APP_ROOT_VH // Returns the root viewController which is in the view hierarchy
APP_TOP // Returns the top most viewController
```

## Installation

Simply drag **Navigator.swift** inside your project and start using it.

## Communication

- Found a **bug** or have a **feature request**? [Open an issue][].
- Want to **contribute**? [Submit a pull request][].

[Read the contributing guidelines]: ./CONTRIBUTING.md#contributing
[Ask on Stack Overflow]: http://stackoverflow.com/questions/tagged/Navigator
[Open an issue]: https://github.com/oblq/Navigator/issues/new
[Submit a pull request]: https://github.com/oblq/Navigator/fork


## Author

- [Marco Muratori](mailto:marcomrtr@gmail.com) 

## License

Navigator.swift is available under the MIT license. See [the LICENSE
file](./LICENSE.txt) for more information.


[Swift]: https://swift.org/

[Swift4Badge]: https://img.shields.io/badge/swift-4-orange.svg?style=flat
[Swift4Link]: https://developer.apple.com/swift/
