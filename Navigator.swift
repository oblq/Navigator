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

// Returns the AppDelegate
public let APP_DELEGATE = UIApplication.shared.delegate

public var APP_KEY_WINDOW: UIWindow? {
	get {
		return UIApplication.shared.keyWindow
	}
}

// Returns the root viewController also if it is not in the view hierarchy
public var APP_ROOT: UIViewController? {
	get {
		var root = APP_KEY_WINDOW?.rootViewController
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
public var APP_TOP_VC: UIViewController? {
	var topController = APP_ROOT_VH
	while topController?.presentedViewController != nil {
		topController = topController!.presentedViewController
	}
	return topController
}

public class Navigator {
	
	public static let debug = false

	struct StackObject {
		var parent: UIViewController?
		var vc: UIViewController?
		
		func select() {
			switch parent {
			case let parent? where parent is UITabBarController:
				guard let vc = vc else {
					return
				}
				(parent as! UITabBarController).selectedViewController = vc
				
			case let parent? where parent is UINavigationController:
				guard let vc = vc else {
					return
				}
				let parent = parent as! UINavigationController
				parent.popToRootViewController(animated: false)
				if parent.topViewController != vc {
					parent.show(vc, sender: nil)
				}
				
			default:
				return
			}
		}
	}
	
	@discardableResult public static func find<T>(_ viewControllerType: T.Type,
													 navigate: Bool = false,
													 asyncMain: ((_ parent: UIViewController?, _ vc: T?) -> ())? = nil) -> T? where T: UIViewController {
		
		
		func checkIn(_ viewController: UIViewController?, stack: [StackObject], indent: String = "") -> [StackObject] {
			
			var stack = stack
			
			switch viewController {
			case is T:
				logNavigation(msg: indent + "-> Found!")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				return stack
				
			case let tab as UITabBarController where tab.viewControllers != nil:
				logNavigation(msg: indent + "Tab found: \(tab)")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				for vc in tab.viewControllers! {
					logNavigation(msg: indent + "-> in tab: \(vc)")
					let subStack = checkIn(vc, stack: [StackObject(parent: tab, vc: nil)], indent: indent + "    ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
						return stack
					}
				}
				if let presented = tab.presentedViewController {
					logNavigation(msg: indent + "Has presentedViewController: \(presented)")
					if stack.last != nil {
						stack[stack.count - 1].vc = viewController
					}
					let subStack = checkIn(presented, stack: stack, indent: indent + " ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
						return stack
					}
				}
				return stack

			case let nav as UINavigationController:
				logNavigation(msg: indent + "Nav found: \(nav)")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				for vc in nav.viewControllers {
					logNavigation(msg: indent + "-> in nav: \(vc)")
					let subStack = checkIn(vc, stack: [StackObject(parent: nav, vc: nil)], indent: indent + "    ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
						return stack
					}
				}
				if let presented = nav.presentedViewController {
					logNavigation(msg: indent + "Has presentedViewController: \(presented)")
					if stack.last != nil {
						stack[stack.count - 1].vc = viewController
					}
					let subStack = checkIn(presented, stack: stack, indent: indent + " ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
						return stack
					}
				}
				return stack

			case let parent? where parent.childViewControllers.count > 0:
				logNavigation(msg: indent + "Has childs: \(parent)")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				for vc in parent.childViewControllers {
					logNavigation(msg: indent + "-> in childs: \(vc)")
					let subStack = checkIn(vc, stack: [StackObject(parent: parent, vc: nil)], indent: indent + "    ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
						return stack
					}
				}
				return stack

			case let parent? where parent.presentedViewController != nil:
				logNavigation(msg: indent + "Has presentedViewController: \(parent)")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				let subStack = checkIn(parent.presentedViewController, stack: stack, indent: indent + " ")
				if subStack.last?.vc is T {
					stack.append(contentsOf: subStack)
					return stack
				}
				return stack

			default:
				return stack
			}
		}
		
		logNavigation(msg: "") // empty line...
		let stack = checkIn(APP_ROOT, stack: [StackObject]())
		DispatchQueue.main.async(execute: { () -> Void in
			logNavigation(msg: "The navigation stack: \(stack as AnyObject)")
			logNavigation(msg: "") // empty line...
			if navigate {
				for obj in stack {
					obj.select()
				}
			}
			asyncMain?(stack.last?.parent, stack.last?.vc as? T)
		})

		return stack.last?.vc as? T
	}
	
	static func logNavigation(msg: String) {
		if debug {
			print(msg)
		}
	}
	
}
