//
//  Navigator.swift
//
//  Copyright (c) 2017 Marco Muratori
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

// MARK: -
// MARK: UIViewController extension

public extension UIViewController {
	@discardableResult public static func find() -> Self? {
		return Navigator.find(self)
	}
	
	@discardableResult public static func navigate() -> Self? {
		return Navigator.navigate(to: self)
	}
}

// MARK: -
// MARK: Navigator class

public class Navigator {
	
	public static var debug = false {
		didSet {
			if debug {
				NLog("Disable debug var inside Navigator class to shut down those comments")
			}
		}
	}
	
	static var cache = [String: [ViewHierarchyObject]]()
	
	public static func purgeCache() {
		Navigator.cache.removeAll()
	}
	
	public static func purgeCacheFor(_ type: UIViewController.Type) {
		Navigator.cache.removeValue(forKey: String(describing: type))
	}
	
	public typealias asyncMainHandler<T: UIViewController> = ((_ container: UIViewController?, _ vc: T?) -> ())?
	
	@discardableResult public static func find<T: UIViewController>(_ type: T.Type, asyncMain: asyncMainHandler<T> = nil) -> T? {
		return lookFor(type, navigate: false, asyncMain: asyncMain)
	}
	@discardableResult public static func navigate<T: UIViewController>(to: T.Type, asyncMain: asyncMainHandler<T> = nil) -> T? {
		return lookFor(to, navigate: true, asyncMain: asyncMain)
	}
	
	@discardableResult private static func lookFor<T: UIViewController>(_ vcType: T.Type, navigate: Bool = false, asyncMain: asyncMainHandler<T>) -> T? {
		
		// recursive search
		func checkIn(_ viewController: UIViewController?, stack: [ViewHierarchyObject] = [ViewHierarchyObject](), indent: String = "") -> [ViewHierarchyObject] {
			
			var stack = stack
			
			func setLastVC() {
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
			}
			
			switch viewController {
			case is T:
				NLog(indent + "-> Found!")
				setLastVC()
				return stack

			case let container? where container.childViewControllers.count > 0:
				setLastVC()
				for vc in container.childViewControllers {
					NLog(indent + "-> in \(String(describing: type(of: vc))) childs:")
					let subStack = checkIn(vc, stack: [ViewHierarchyObject(container: container, vc: nil)], indent: indent + "    ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
						return stack
					} else {
					}
				}
				fallthrough // not found, check for presentedViewController in default case

			default:
				if let container = viewController,
					let pvc = container.presentedViewController {
					setLastVC()
					NLog(indent + "-> \(String(describing: type(of: pvc))).presentedViewController:")
					let subStack = checkIn(pvc, stack: stack, indent: indent + "    ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
					} else {
					}
				}
				return stack
			}
		}
		
		NLog("") // empty line...
		// get stack from cache or scan the view hierarchy
		var stack = Navigator.cache[String(describing: vcType)]
		if stack == nil {
			guard let root = APP_ROOT else {
				asyncMain?(nil, nil)
				return nil
			}
			NLog("From \(String(describing: type(of: root)))...") // empty line...
			stack = checkIn(root)
			Navigator.cache[String(describing: vcType)] = stack
		} else {
			NLog("\n'\(String(describing: vcType))' stack found on cache")
		}
		// NLog("\nNavigation stack: \(stack as AnyObject)\n")
		NLog("") // empty line...

		DispatchQueue.main.async(execute: { () -> Void in
			if navigate {
				for obj in stack! {
					obj.select()
				}
			}
			asyncMain?(stack!.last?.container, stack!.last?.vc as? T)
		})

		return stack!.last?.vc as? T
	}
	
	static func NLog(_ msg: String) {
		if debug {
			print(msg.count > 0 ? "[Navigator]: \(msg)" : msg)
		}
	}
}

struct ViewHierarchyObject {
	var container: UIViewController?
	var vc: UIViewController?
	
	func select() {
		guard let vc = vc else {
			return
		}
		
		switch container {
		case let container? where container is UITabBarController:
			(container as! UITabBarController).selectedViewController = vc
			
		case let container? where container is UISplitViewController:
			(container as! UISplitViewController).showDetailViewController(vc, sender: nil)
			
		case let container? where container is UINavigationController:
			let container = container as! UINavigationController
			container.popToRootViewController(animated: false)
			// avoid pushing the same vc twice:
			if container.topViewController != vc {
				container.show(vc, sender: nil)
			}
			
		default:
			return
		}
	}
}


// MARK: -
// MARK: Globals

// Returns the AppDelegate
public let APP_DELEGATE = UIApplication.shared.delegate

// Returns the App Window
public var APP_WINDOW: UIWindow? {
	get {
		return UIApplication.shared.keyWindow
	}
}

// Returns the root viewController also if it is not in the view hierarchy
public var APP_ROOT: UIViewController? {
	get {
		var root = APP_WINDOW?.rootViewController
		while root?.presentingViewController != nil {
			root = root?.presentingViewController
		}
		return root
	}
}

// Returns the root viewController which is in the view hierarchy
public var APP_ROOT_VH: UIViewController? {
	get {
		func isInViewHierarchy(_ vc: UIViewController?) -> Bool {
			guard let vc = vc else { return false }
			return vc.isViewLoaded && vc.view.window != nil
		}
		
		var vc = APP_ROOT
		while !isInViewHierarchy(vc) {
			if vc == nil { return nil }
			vc = vc?.presentedViewController
		}
		return vc
	}
}

// Returns the top most viewController
public var APP_TOP: UIViewController? {
	var topController = APP_ROOT_VH
	while topController?.presentedViewController != nil {
		topController = topController!.presentedViewController
	}
	return topController
}
