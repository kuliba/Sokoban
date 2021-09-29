//
//  AppDelegate UI extension.swift
//  ForaBank
//
//  Created by Mikhail on 01.06.2021.
//

import UIKit
import IQKeyboardManagerSwift

extension AppDelegate {
    func customizeUiInApp() {
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Настройка клавиатуры
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Готово"
        IQKeyboardManager.shared.toolbarTintColor = .black
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldPlayInputClicks = true
        IQKeyboardManager.shared.toolbarPreviousBarButtonItemImage = UIImage()
        IQKeyboardManager.shared.toolbarNextBarButtonItemImage = UIImage()
//        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40
        
        // Настройка NavigationBar
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().titleTextAttributes =
            [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().isTranslucent = false
        
        // Убираем надписи у кнопок NavigationBar
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.clear], for: .highlighted)
        
        // Настройка TabBar
        UITabBarItem.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.black ], for: .selected)
    }
}
