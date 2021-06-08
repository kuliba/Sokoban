//
//  AppDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        customizeNavBar()
        
        let parameters = [
        "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
        "pushFCMtoken": "",
        "model": UIDevice().model,
         "operationSystem": "IOS"
        ]
        
        NetworkManager<CSRFDecodableModel>.addRequest(.csrf, [:], parameters) { request, error in
            
            print(request?.data?.token as Any)
            
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

