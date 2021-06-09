//
//  AppDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        getCSRF()
        
        customizeNavBar()
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

    var applicationStateString: String {
        if UIApplication.shared.applicationState == .active {
            return "active"
        } else if UIApplication.shared.applicationState == .background {
            return "background"
        } else {
            return "inactive"
        }
    }

}

extension AppDelegate {
    func getCSRF() {
        let parameters = [
            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
            "pushFCMtoken": Messaging.messaging().fcmToken! as String,
            "model": UIDevice().model,
            "operationSystem": "IOS"
        ]
//        print("DEBUG: Parameters = ", parameters)
        
        NetworkManager<CSRFDecodableModel>.addRequest(.csrf, [:], parameters) { request, error in
            guard let token = request?.data?.token else { return }
            print("DEBUG: Token = ", token)
            
            // TODO: пределать на сингл тон
            UserDefaults.standard.set(token, forKey: "sessionToken")
        }
    }
}


extension AppDelegate: MessagingDelegate {
 
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken ?? "nil")")
    }

    // iOS9, called when presenting notification in foreground
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NSLog("[RemoteNotification] applicationState: \(applicationStateString) didReceiveRemoteNotification for iOS9: \(userInfo)")
        if UIApplication.shared.applicationState == .active {
            //TODO: Handle foreground notification
        } else {
            //TODO: Handle background notification
        }
    }
}

struct FCMToken {
    static var fcmToken: String?
}
