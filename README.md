# 🚣 Navigator

[![Swift4 compatible][Swift4Badge]][Swift4Link]

**Navigator.swift** allow decoupled navigation in iOS apps by just passing the viewController class type, 
useful to handle external requests such as deep linking, push notifications or shortcuts 
(open specific VC from AppDelegate) for instance and/or to simply call functions on VCs not directly accessible. 
It also use cache for performance, you don’t need to worry about navigation logic after storyboard updates. 

## Usage

Getting your UIViewController instance synchronously:
```swift
Navigator.find(HelloVC.self)?.sayHello()
```

Getting your UIViewController instance asynchronously, on the main thread:
```swift
Navigator.find(HelloVC.self) { (HelloVCContainer, HelloVCInstance) in
    HelloVCInstance?.sayHello()
}
```

...or automatically navigate to it:
```swift
// simply navigate to the HelloVC instance
Navigator.navigate(to: HelloVC.self)

// execute sayHello() synchronously
Navigator.navigate(to: HelloVC.self)?.sayHello()

// execute sayHello() asynchronously on the main thread
Navigator.navigate(to: HelloVC.self) { (HelloVCContainer, HelloVCInstance) in
    HelloVCInstance?.sayHello()
}
```

Empty the view hierarchy cache:
```swift
Navigator.purgeCache()
```

Activate debug mode and whatch the view hierarchy printed on console:
```swift
Navigator.debug = true
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
