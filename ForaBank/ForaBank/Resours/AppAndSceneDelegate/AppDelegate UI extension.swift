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
//        if #available(iOS 15, *) {
//            let appearance = UINavigationBarAppearance()
//            let navigationBar = UINavigationBar()
//            appearance.configureWithOpaqueBackground()
//            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//            appearance.backgroundColor = .clear
//            navigationBar.standardAppearance = appearance
//            UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        }
        
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
        IQKeyboardManager.shared.disabledToolbarClasses.append(CodeVerificationViewController.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CodeVerificationViewController.self)
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(CodeVerificationViewController.self)

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


class PaddingLabel: UILabel {
    
    var topInset: CGFloat
    var bottomInset: CGFloat
    var leftInset: CGFloat
    var rightInset: CGFloat
    
    required init(withInsets top: CGFloat, _ bottom: CGFloat, _ left: CGFloat, _ right: CGFloat) {
        self.topInset = top
        self.bottomInset = bottom
        self.leftInset = left
        self.rightInset = right
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
    
}
