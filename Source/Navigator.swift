//
//  Navigator.swift
//  BKit
//
//  Created by Marco Muratori on 05/09/2017.
//  Copyright © 2017 Marco Muratori. All rights reserved.
//

import UIKit

// Get AppDelegate
public let APP_DELEGATE = UIApplication.shared.delegate

public var APP_KEY_WINDOW: UIWindow? {
	get {
		return UIApplication.shared.keyWindow
	}
}

// returns the root viewController also if it is not in the view hierarchy
public var APP_ROOT_VC: UIViewController? {
	get {
		var root = APP_KEY_WINDOW?.rootViewController
		while root?.presentingViewController != nil {
			root = root?.presentingViewController
		}
		return root
	}
}

// returns the root viewController which is in the view hierarchy
public var APP_ROOT_VC_IN_VH: UIViewController? {
	get {
		func isInViewHierarchy(_ vc: UIViewController?) -> Bool {
			guard let vc = vc else { return false }
			return vc.isViewLoaded && vc.view.window != nil
		}
		
		var vc = APP_ROOT_VC
		while !isInViewHierarchy(vc) {
			if vc == nil { return nil }
			vc = vc?.presentedViewController
		}
		return vc
	}
}

// Get the top most viewController
public var APP_TOP_VC: UIViewController? {
	var topController = APP_ROOT_VC
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
				parent.popToRootViewController(animated: false) // could be animated but the next line could not be called
				if parent.topViewController != vc {
					parent.show(vc, sender: nil)
				}
				
			default:
				return
			}
		}
	}
	
	@discardableResult public static func find<T>(_ viewControllerType: T.Type,
													 navigateTo: Bool = false,
													 found: ((_ vc: T?) -> ())? = nil) -> T? where T: UIViewController {
		
		func checkIn(_ viewController: UIViewController?, stack: [StackObject], indent: String = "") -> (T?, [StackObject]) {
			
			var stack = stack
			
			switch viewController {
			case is T:
				logNavigation(msg: indent + "-> Found!")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				return (viewController as? T, stack)
				
			case let tab as UITabBarController where tab.viewControllers != nil:
				logNavigation(msg: indent + "Is tab \(tab)")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				for vc in tab.viewControllers! {
					logNavigation(msg: indent + "-> in tab: \(vc)")
					let (vcFound, subStack) = checkIn(vc, stack: [StackObject(parent: tab, vc: nil)], indent: indent + "    ")
					if vcFound != nil {
						stack.append(contentsOf: subStack)
						return (vcFound, stack)
					}
				}
				if let presented = tab.presentedViewController {
					logNavigation(msg: indent + "Has presentedViewController \(presented)")
					if stack.last != nil {
						stack[stack.count - 1].vc = viewController
					}
					let (vcFound, subStack) = checkIn(presented, stack: stack, indent: indent + " ")
					if vcFound != nil {
						stack.append(contentsOf: subStack)
						return (vcFound, stack)
					}
				}
				return (nil, stack)

			case let nav as UINavigationController:
				logNavigation(msg: indent + "Is nav \(nav)")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				for vc in nav.viewControllers {
					logNavigation(msg: indent + "-> in nav: \(vc)")
					let (vcFound, subStack) = checkIn(vc, stack: [StackObject(parent: nav, vc: nil)], indent: indent + "    ")
					if vcFound != nil {
						stack.append(contentsOf: subStack)
						return (vcFound, stack)
					}
				}
				if let presented = nav.presentedViewController {
					logNavigation(msg: indent + "Has presentedViewController \(presented)")
					if stack.last != nil {
						stack[stack.count - 1].vc = viewController
					}
					let (vcFound, subStack) = checkIn(presented, stack: stack, indent: indent + " ")
					if vcFound != nil {
						stack.append(contentsOf: subStack)
						return (vcFound, stack)
					}
				}
				return (nil, stack)

			case let parent? where parent.childViewControllers.count > 0:
				logNavigation(msg: indent + "Has childs \(parent)")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				for vc in parent.childViewControllers {
					logNavigation(msg: indent + "-> in childs: \(vc)")
					let (vcFound, subStack) = checkIn(vc, stack: [StackObject(parent: parent, vc: nil)], indent: indent + "    ")
					if vcFound != nil {
						stack.append(contentsOf: subStack)
						return (vcFound, stack)
					}
				}
				return (nil, stack)

			case let parent? where parent.presentedViewController != nil:
				logNavigation(msg: indent + "Has presentedViewController \(parent)")
				if stack.last != nil {
					stack[stack.count - 1].vc = viewController
				}
				let (vcFound, subStack) = checkIn(parent.presentedViewController, stack: stack, indent: indent + " ")
				if vcFound != nil {
					stack.append(contentsOf: subStack)
					return (vcFound, stack)
				}
				return (nil, stack)

			default:
				return (nil, stack)
			}
		}
		
		let (foundVC, stack) = checkIn(APP_ROOT_VC, stack: [StackObject]())
		DispatchQueue.main.async(execute: { () -> Void in
			logNavigation(msg: "The navigation stack: \(stack as AnyObject)")
			if navigateTo {
				for obj in stack {
					obj.select()
				}
			}
			found?(foundVC)
		})

		return foundVC
	}
	
	static func logNavigation(msg: Any) {
		if debug {
			print(msg)
		}
	}
	
}
