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
// MARK: Navigator class

public class Navigator {
	
	public static let debug = true
	
	public typealias asyncMainHandler<T> = ((_ container: UIViewController?, _ vc: T?) -> ())?
	
	@discardableResult public static func find<T>(_ type: T.Type, asyncMain: asyncMainHandler<T> = nil) -> T? where T: UIViewController {
		return lookFor(type, navigate: false, asyncMain: asyncMain)
	}
	@discardableResult public static func navigate<T>(to: T.Type, asyncMain: asyncMainHandler<T> = nil) -> T? where T: UIViewController {
		return lookFor(to, navigate: true, asyncMain: asyncMain)
	}
	
	@discardableResult static func lookFor<T>(_ type: T.Type,
												  navigate: Bool = false,
												  asyncMain: asyncMainHandler<T> = nil) -> T? where T: UIViewController {
		
		// recursive search
		func checkIn(_ viewController: UIViewController?, stack: [StackObject] = [StackObject](), indent: String = "") -> [StackObject] {
			
			var stack = stack
			
			switch viewController {
			case is T:
				nLog(msg: indent + "-> Found!")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				return stack

			case let container? where container.childViewControllers.count > 0:
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				for vc in container.childViewControllers {
					nLog(msg: indent + "-> in childs: \(vc)")
					let subStack = checkIn(vc, stack: [StackObject(container: container, vc: nil)], indent: indent + "    ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
						return stack
					}
				}
				fallthrough

			default:
				if let container = viewController,
					let pvc = container.presentedViewController {
					nLog(msg: indent + "-> presentedViewController: \(pvc)")
					if stack.last != nil {
						stack[stack.count - 1].vc = viewController
					}
					let subStack = checkIn(pvc, stack: stack, indent: indent + "    ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
						return stack
					}
					return stack
				}
				return stack
			}
		}
		
		nLog(msg: "") // empty line...
		nLog(msg: "[INFO]: Disable debug var inside Navigator class to shut down those comments")

		let stack = checkIn(APP_ROOT)
		DispatchQueue.main.async(execute: { () -> Void in
			nLog(msg: "The navigation stack: \(stack as AnyObject)")
			nLog(msg: "") // empty line...
			if navigate {
				for obj in stack {
					obj.select()
				}
			}
			asyncMain?(stack.last?.container, stack.last?.vc as? T)
		})

		return stack.last?.vc as? T
	}
	
	static func nLog(msg: String) {
		if debug {
			print(msg)
		}
	}
	
}

struct StackObject {
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