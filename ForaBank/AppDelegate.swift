/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import IQKeyboardManagerSwift
import RMMapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    var window: UIWindow?
    
    // MARK: - Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
 
        
        setNavigationBarAppearance()
        setTextFieldAppearance()
        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        
       
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
   
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if  UserDefaults.standard.value(forKey: "pincode") != nil{
            
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: - Private methods
private extension AppDelegate {
    
    func setNavigationBarAppearance() {
        setNavigationBarTransparent()
        setNavigationBarFont()
    }
    
    func setNavigationBarTransparent() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    func setNavigationBarFont() {
        let font = UIFont(name: "Roboto-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        UINavigationBar.appearance().titleTextAttributes = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
    }
    
    func setTextFieldAppearance() {
        UITextField.appearance().tintColor = .black
        UITextField.appearance().backgroundColor = UIColor(red: 0.889415, green: 0.889436, blue: 0.889424, alpha: 0.25 )//UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)//
    }
}
