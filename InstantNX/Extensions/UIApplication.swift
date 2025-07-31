//
//  UIApplication.swift
//  InstantNX
//
//  Created by devonly on 2024/10/13.
//  Copyright © 2024 Magi, Corporation. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

public extension UIApplication {
    /// UIWindow
    var window: UIWindow? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first
    }

    /// UIWindow
    var firstWindow: UIWindow? {
        UIApplication.shared.foregroundScene?.windows.first
    }

    /// UIWindow
    var lastWindow: UIWindow? {
        UIApplication.shared.foregroundScene?.windows.last
    }

    /// UIWindowScene
    var foregroundScene: UIWindowScene? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first(where: { $0.activationState == .foregroundActive })
    }

    var rootViewController: UIViewController? {
        firstWindow?.rootViewController
    }

    var presentedViewController: UIViewController? {
        guard let window: UIWindow = firstWindow
        else {
            return nil
        }
        window.makeKeyAndVisible()

        guard let rootViewController = window.rootViewController
        else {
            return nil
        }

        var topViewController: UIViewController? = rootViewController
        while let newTopViewController: UIViewController = topViewController?.presentedViewController {
            topViewController = newTopViewController
        }
        return topViewController
    }

    func popToRootView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController,
           let navigationController = findNavigationController(rootViewController) {
            navigationController.popToRootViewController(animated: true)
        }
    }

    private func findNavigationController(_ viewController: UIViewController?) -> UINavigationController? {
        guard let viewController else {
            return nil
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        for childViewController in viewController.children {
            return findNavigationController(childViewController)
        }

        return nil
    }
}

// public extension UIViewController {
//    func popover(_ viewControllerToPresent: UIActivityViewController, animated: Bool, completion: (() -> Void)? = nil) {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            if let popover = viewControllerToPresent.popoverPresentationController {
//                popover.sourceView = viewControllerToPresent.view
//                popover.barButtonItem = .none
//                popover.sourceRect = viewControllerToPresent.accessibilityFrame
//            }
//        }
//        present(viewControllerToPresent, animated: animated, completion: completion)
//    }
// }
