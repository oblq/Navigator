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

public protocol Navigable {}
extension UIViewController: Navigable {} // implement the protocol by default in all UIViewControllers
public extension Navigable where Self: UIViewController {
    @discardableResult static func find(asyncMain: Navigator.asyncMainHandler<Self>? = nil) -> Self? {
        return Navigator.find(self, asyncMain: asyncMain)
    }
    
    @discardableResult static func select(asyncMain: Navigator.asyncMainHandler<Self>? = nil) -> Self? {
        return Navigator.select(self, asyncMain: asyncMain)
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

    /// This block is always called in the main thread.
    public typealias asyncMainHandler<T: UIViewController> = ((_ container: UIViewController?, _ vc: T?) -> ())
	
	@discardableResult public static func find<T: UIViewController>(_ type: T.Type, asyncMain: asyncMainHandler<T>? = nil) -> T? {
		return lookFor(type, select: false, asyncMain: asyncMain)
	}

	@discardableResult public static func select<T: UIViewController>(_ type: T.Type, asyncMain: asyncMainHandler<T>? = nil) -> T? {
		return lookFor(type, select: true, asyncMain: asyncMain)
	}
	
	@discardableResult private static func lookFor<T: UIViewController>(_ vcType: T.Type, select: Bool, asyncMain: asyncMainHandler<T>?) -> T? {
		// recursive search
		func checkIn(_ viewController: UIViewController?, stack: [StackObject] = [StackObject](), indent: String = "") -> [StackObject] {
			
			var stack = stack
			
			switch viewController {
			case is T:
				NLog(indent + "-> Found!")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				return stack

            case let parent? where parent.children.count > 0:
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
                for vc in parent.children {
					NLog(indent + "-> \(String(describing: type(of: vc))):")
					let subStack = checkIn(vc, stack: [StackObject(parent: parent, vc: nil)], indent: indent + "    ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
						return stack
					}
				}
				fallthrough // not found, check for presentedViewController in default case

			default:
				// The presentedViewController is != nil also when it has bee presented
				// by an ancestor of the examined container.
				// So we also need to check 'pvc.parent == container'.
				if let parent = viewController,
					let pvc = parent.presentedViewController,
					pvc.parent == parent {
					if stack.last != nil {
						stack[stack.count - 1].vc = viewController
					}
					NLog(indent + "-> \(String(describing: type(of: pvc))).presentedViewController:")
					let subStack = checkIn(pvc, stack: stack, indent: indent + "    ")
					if subStack.last?.vc is T {
						stack.append(contentsOf: subStack)
					}
				}
				return stack
			}
		}

		guard let root = APP_ROOT else {
			asyncMain?(nil, nil)
			return nil
		}
		NLog("From \(String(describing: type(of: root)))...")
		let stack = checkIn(root)

		DispatchQueue.main.async(execute: { () -> Void in
			if select {
				for obj in stack {
					if !obj.select() {
						NLog("unable to select one of the elements in the stack:\n\(stack as AnyObject)")
						break
					}
				}
			}

			asyncMain?(stack.last?.parent, stack.last?.vc as? T)
		})

		return stack.last?.vc as? T
	}
	
	static func NLog(_ msg: String) {
		if debug {
			print(msg.count > 0 ? "[Navigator]: \(msg)" : msg)
		}
	}
}

struct StackObject {
	var parent: UIViewController?
	var vc: UIViewController?
	
	func select() -> Bool {
		guard let vc = vc else {
			return false
		}
		
		switch parent {
		case let parent? where parent is UITabBarController:
			(parent as! UITabBarController).selectedViewController = vc
			return true

		case let parent? where parent is UISplitViewController:
			(parent as! UISplitViewController).showDetailViewController(vc, sender: nil)
			return true

		case let parent? where parent is UINavigationController:
			let parent = parent as! UINavigationController
			parent.popToRootViewController(animated: false)
			// avoid pushing the same vc twice:
			if parent.topViewController != vc {
				parent.show(vc, sender: nil)
			}
			return true

		default:
			return false
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
