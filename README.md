# 🚣 Navigator

Easily find and navigate to any ViewController inside your app, from anywhere.

[![Build Status][TravisBadge]][TravisLink] [![Swift4 compatible][Swift4Badge]][Swift4Link] [![Platform][PlatformBadge]][PlatformLink]

A simple way to find and navigate to any ViewController in your app, from anywhere.

Find any UIViewController in the view hierarchy by passing just the class Type and automatically navigate to it.

**Navigator.swift** will look for it recursively inside UITabBarController, UINavigationController, UIViewController.childViewControllers, UIViewController.presentedViewController. 

Get the instance synchronously or asynchronously, on the main thread.


## Usage

Getting your UIViewController instance synchronously:
```swift
let MyViewControllerInstance = Navigator.find(MyViewController.self)
MyViewControllerInstance?.doSomething()
```
or...
```swift
Navigator.find(MyViewController.self)?.doSomething()
```


Getting your UIViewController instance asynchronously, on the main thread:
```swift
Navigator.find(MyViewController.self) { (MyViewControllerInstance) in
    MyViewControllerInstance.doSomething()
}
```

...and automatically navigate to it:
```swift
Navigator.find(MyViewController.self, navigate: true)?.doSomething()

Navigator.find(MyViewController.self, navigate: true) { (MyViewControllerInstance) in
    MyViewControllerInstance.doSomething()
}
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

[TravisBadge]: https://img.shields.io/travis/stephencelis/SQLite.swift/master.svg?style=flat
[TravisLink]: https://travis-ci.org/stephencelis/SQLite.swift

[PlatformBadge]: https://cocoapod-badges.herokuapp.com/p/SQLite.swift/badge.png
[PlatformLink]: http://cocoadocs.org/docsets/SQLite.swift

[Swift4Badge]: https://img.shields.io/badge/swift-4-orange.svg?style=flat
[Swift4Link]: https://developer.apple.com/swift/
