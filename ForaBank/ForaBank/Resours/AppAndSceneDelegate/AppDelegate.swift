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
    
    var delegate: Encription?


    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        application.openSessions
        application.backgroundRefreshStatus
        application.beginBackgroundTask {
            print("background")
        }
        requestNotificationAuthorization(application: application)
      
        customizeUiInApp()

        return true
    }

    func beginBackgroundTask(){
        AppLocker.present(with: .validate)
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
        
//        AppLocker.present(with: ALMode.validate)
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
                AppLocker.present(with: ALMode.validate)

    }
    func applicationDidEnterBackground(_ application: UIApplication) {

    }
    func applicationWillResignActive(_ application: UIApplication) {
        AppLocker.present(with: ALMode.validate)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DispatchQueue.background(delay: 3.0, completion:{
            AppLocker.present(with: .validate)
        })
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

    
    func requestNotificationAuthorization(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        NetworkManager<LogoutDecodableModel>.addRequest(.logout, [:], [:]) { _,_  in
            print("Logout :", "Вышли из приложения")
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // ...
        
        // Print full message.
            print(userInfo)
        let otpCode = userInfo["body"] as! String
        print(otpCode.components(separatedBy:  otpCode))
        let newstring = otpCode.filter { "0"..."9" ~= $0 }
        print(newstring)
        
        NotificationCenter.default.post(name: Notification.Name("otpCode"), object: nil, userInfo: userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()

        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        let tokenString = NSMutableString()
        
        for i in 0 ..< deviceToken.count {
            tokenString.appendFormat("%02.2hhx", tokenChars[i])
        }
        
    }
    
    
}

extension AppDelegate: MessagingDelegate {
 
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    // iOS9, called when presenting notification in foreground
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        //        NSLog("[RemoteNotification] applicationState: \(applicationStateString) didReceiveRemoteNotification for iOS9: \(userInfo)")
        if UIApplication.shared.applicationState == .active {
            //TODO: Handle foreground notification
        } else {
            //TODO: Handle background notification
        }
    }
}
extension AppDelegate {
    
    func getCSRF(completion: @escaping (_ error: String?) ->()) {
        
        let parameters = [
//            "cryptoVersion": "1.0",
            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
            "pushFcmToken": Messaging.messaging().fcmToken ?? "" as String,
            "model": UIDevice().model,
            "operationSystem": "IOS"
        ] as [String : AnyObject]
//        print("DEBUG: Parameters = ", parameters)
      
        
        
        NetworkManager<CSRFDecodableModel>.addRequest(.csrf, [:], parameters) { request, error in
            if error != nil {
                completion(error)
            }
            guard let token = request?.data?.token else {
                completion("error")
                return
                
            }
            
            let certSeparator = request?.data?.cert?.replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "").components(separatedBy: "-----END CERTIFICATE----------BEGIN CERTIFICATE-----")
            KeyFromServer.publicKeyCert = certSeparator?[0].replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            KeyFromServer.privateKeyCert = certSeparator?[1].replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            KeyFromServer.publicKey = request?.data?.pk
              
//            let ourKeys = delegate?.createOwnKey()
            
            let pubkeyFromCert = Encription().encryptedPublicKey()
                                   
            let shared = Encription().computeSharedSecret(ownPrivateKey: KeyPair.privateKey!, otherPublicKey: KeyFromServer.pubFromServ!)
                                   
                               
            let ectoRsa = SecKeyCreateEncryptedData(KeyPair.publicKey!, .rsaEncryptionRaw, Data(base64Encoded: KeyFromServer.publicKey!)! as CFData, nil)

            let newData = Encription().encryptWithRSAKey(Data(base64Encoded: KeyFromServer.publicKey!)!, rsaKeyRef: KeyPair.privateKey!, padding: .PKCS1)
            
//                                   keyExchange()
  
            
            // TODO: пределать на сингл тон
            UserDefaults.standard.set(token, forKey: "sessionToken")
            
//            let tok = UserDefaults.standard.object(forKey: "sessionToken")
//            print("DEBUG: Token = ", tok)
            CSRFToken.token = token
            completion(nil)
            
                   NetworkManager<InstallPushDeviceDecodebleModel>.addRequest(.installPushDevice, [:], parameters) { model, error in
                       if error != nil {
                           print("DEBUG: installPushDevice error", error ?? "nil")
                           completion(error)
                       }
                        
                    keyExchange()
                    
                    print("DEBUG: CSRF DONE!")
       //                print("DEBUG: installPushDevice model", model ?? "nil")
                       completion(nil)
                   }

            
        }
        
            func keyExchange(){
                var tempParameters = [String: String]()
                tempParameters = ["X-XSRF-TOKEN":"\(UserDefaults.standard.object(forKey: "sessionToken") ?? "")"]
                let parametersKey = [
                "data": KeyFromServer.sendBase64ToServ ?? "",
                "token": CSRFToken.token ?? "",
                "type": "",
            ] as [String : AnyObject]
            
                NetworkManager<KeyExchangeDecodebleModel>.addRequest(.keyExchange, [:], parametersKey) { model, error in
                if error != nil {
                    print("DEBUG: KeyExchange error", error ?? "nil")
                    completion(error)
                }
             
                print("DEBUG: KeyExchange DONE!")
//                print("DEBUG: installPushDevice model", model ?? "nil")
                completion("Ok")
            }
        }
        
    }
}

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}
