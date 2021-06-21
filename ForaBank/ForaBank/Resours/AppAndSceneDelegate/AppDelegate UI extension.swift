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
        
        // Настройка клавиатуры
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Готово"
        IQKeyboardManager.shared.toolbarTintColor = .black
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        
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
