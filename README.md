# 🚣 Navigator

[![Swift4 compatible][Swift4Badge]][Swift4Link]

**Navigator.swift** allow decoupled navigation in iOS apps by just passing the viewController class type, 
useful to handle external requests such as deep linking, push notifications or shortcuts 
(open specific VC from AppDelegate) and/or to simply call functions on VCs not directly accessible. 

Navigator is decoupled from the navigation logic in your storyboard, it recursively scan all instantiated view controllers in your view hierarchy looking for the class.Type you're searching for in childs and/or presentedViewController and save the route in cache for next calls.

It can then navigate to it using all native container view controllers fnctions (UITabBarController, UISplitViewController and UINavigationController). 

NOTE:
If you use custom containers then you can navigate to them and complete navigation steps in closure, same for not loaded UIViewControllers.

## Usage

Getting your UIViewController instance (and its container), the return type is automatically inferred:
```swift
// synchronously
Navigator.find(HelloVC.self)?.sayHello()

// asynchronously, on the main thread:
Navigator.find(HelloVC.self) { (HelloVCContainer, HelloVCInstance) in
    HelloVCInstance?.sayHello()
}
```

...or automatically navigate to it:
```swift
// navigate to the HelloVC instance and execute sayHello() synchronously
Navigator.navigate(to: HelloVC.self)?.sayHello()

// execute sayHello() asynchronously on the main thread
Navigator.navigate(to: HelloVC.self) { (HelloVCContainer, HelloVCInstance) in
    print(HelloVCContainer.childViewControllers as AnyObject)
    HelloVCInstance?.sayHello()
}
```

You can also use the UIViewController extension on you view controller itself, it returns the vc instance synchronously:
```swift
HelloVC.find()?.sayHello()
HelloVC.navigate()
HelloVC.navigate()?.sayHello()
```

Navigator cache the view hierarchy to be faster, you can empty it if needed:
```swift
Navigator.purgeCache()
```

Activate debug and whatch the view hierarchy printed on console:
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
