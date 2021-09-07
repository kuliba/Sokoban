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
        
        /// FirebaseApp configure
        var filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        #if DEBUG
        filePath = Bundle.main.path(forResource: "GoogleService-Info-test", ofType: "plist")!
        #endif
        let fileopts = FirebaseOptions.init(contentsOfFile: filePath)
        FirebaseApp.configure(options: fileopts!)
        
        /// FirebaseApp Messaging configure
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
        requestNotificationAuthorization(application: application)
        customizeUiInApp()
        
        // Net Detect
        NetStatus.shared.startMonitoring()

        return true
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
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
        
        if let type = userInfo["type"] as? String {
            if type == "сonsentMe2MePull" {
                print("ОТКРЫВАЕМ ЭКРАН", userInfo)
                let amount = userInfo["amount"] as? String ?? ""
                let fee = userInfo["fee"] as? String ?? ""
                let cardId = userInfo["cardId"] as? String ?? ""
                let accountId = userInfo["accountId"] as? String ?? ""
                let bank = userInfo["BankRecipientID"] as? String ?? ""
                var meToMeReq = RequestMeToMeModel(
                    amount: Double(amount) ?? 0, bankId: bank,
                    fee: Double(fee) ?? 0, cardId: Int(cardId), accountId: Int(accountId))
                meToMeReq.RefTrnId = userInfo["RefTrnId"] as? String ?? ""
                meToMeReq.RcvrMsgId = userInfo["RcvrMsgId"] as? String ?? ""
                meToMeReq.RecipientID = userInfo["RecipientID"] as? String ?? ""
                
                
                
                let topvc = UIApplication.topViewController()
                
                let vc = MeToMeRequestController()
                vc.viewModel = meToMeReq
                vc.modalPresentationStyle = .fullScreen
                topvc?.present(vc, animated: true, completion: nil)
                
            }
        }
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
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
        
        NetworkManager<CSRFDecodableModel>.addRequest(.csrf, [:], [:]) { request, error in
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
              
            let pubkeyFromCert = Encription().encryptedPublicKey()
                                   
            let shared = Encription().computeSharedSecret(ownPrivateKey: KeyPair.privateKey!, otherPublicKey: KeyFromServer.pubFromServ!)
                                   
                               
            let ectoRsa = SecKeyCreateEncryptedData(KeyPair.publicKey!, .rsaEncryptionRaw, Data(base64Encoded: KeyFromServer.publicKey!)! as CFData, nil)

            let newData = Encription().encryptWithRSAKey(Data(base64Encoded: KeyFromServer.publicKey!)!, rsaKeyRef: KeyPair.privateKey!, padding: .PKCS1)
            
            
            CSRFToken.token = token
            
            let parameters = [
    //            "cryptoVersion": "1.0",
                "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                "pushFcmToken": "\(Messaging.messaging().fcmToken ?? "")",
                "model": UIDevice().model,
                "operationSystem": "IOS"
            ] as [String : AnyObject]
            print("DEBUG: Parameters = ", parameters)
            
            NetworkManager<InstallPushDeviceDecodebleModel>.addRequest(.installPushDevice, [:], parameters) { model, error in
                if error != nil {
                    print("DEBUG: installPushDevice error", error ?? "nil")
                    completion(error)
                } else {
                    
                    let parametersKey = [
                        "data": "\(KeyFromServer.sendBase64ToServ ?? "")",
                        "token": "\(CSRFToken.token ?? "")",
                        "type": "",
                    ] as [String : AnyObject]
                    
                    NetworkManager<KeyExchangeDecodebleModel>.addRequest(.keyExchange, [:], parametersKey) { model, error in
                        if error != nil {
                            print("DEBUG: KeyExchange error", error ?? "nil")
                            completion(error)
                        } else {
                            print("DEBUG: KeyExchange DONE!")
                            print("DEBUG: CSRF DONE!")
                            completion(nil)
                        }
                    }
                }
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
