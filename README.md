# 🚣 Navigator

[![Swift4 compatible][Swift4Badge]][Swift4Link]

**Navigator.swift** allow decoupled navigation in iOS apps,
useful to handle external requests such as deep linking, push notifications or shortcuts 
(open a given viewController from AppDelegate) and/or to simply call funcs on VCs not directly accessible. 

Navigator recursively scan all instantiated view controllers in your view hierarchy looking for the class.Type you're searching for in childs and/or presentedViewController.

It can then navigate to it using all native container view controllers methods (UITabBarController, UISplitViewController and UINavigationController). 

NOTE:
If you use custom containers then you can navigate to them and complete navigation steps in closure, same for not loaded UIViewControllers.

## Usage

Use the UIViewController extension on your view controller itself.
It returns the vc instance (auto-inferred type) synchronously while navigation always happen async on the main thread:
```swift
// return the running instance and call one of its funcs in one line:
HelloVC.find()?.sayHelloInConsole()

// go to it
HelloVC.select()

// execute something in the main thread asynchronously:
HelloVC.find { (helloVCParent, helloVC) in
    helloVC?.sayHelloWithAlertFromRootViewController()
    print("HelloVC found: ", helloVC?.title as? String)
}

let hVC = HelloVC.select { (helloVCParent, helloVC) in
    helloVC?.sayHelloWithAlert()
    print("HelloVC found, printing on main thread async: ", helloVC?.title as? String)
}
hVC.doSomething() // sync
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
