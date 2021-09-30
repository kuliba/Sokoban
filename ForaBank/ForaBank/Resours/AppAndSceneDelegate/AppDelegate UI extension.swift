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
        
        //Fix Nav Bar tint issue in iOS 15.0 or later - is transparent w/o code below
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            let navigationBar = UINavigationBar()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.backgroundColor = .clear
            navigationBar.standardAppearance = appearance
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
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
        
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
