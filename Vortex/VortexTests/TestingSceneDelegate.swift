//
//  TestingSceneDelegate.swift
//  ForaBankTests
//
//  Created by Max Gribov on 04.02.2022.
//

import UIKit

class TestingSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TestingRootViewController()
        window?.makeKeyAndVisible()
    }
}

extension TestingSceneDelegate {
    
    class TestingRootViewController: UIViewController {

        override func loadView() {
            let label = UILabel()
            label.text = "Running Unit Tests..."
            label.textAlignment = .center
            label.textColor = .white

            view = label
        }
    }
}
