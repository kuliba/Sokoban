//
//  AppDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import Firebase
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //FIXME: remove singletone after refactoring
    let model = Model.shared
    
    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// FirebaseApp configure
        if let googleServiceInfoFilePath = Bundle.main.path(forResource: googleServiceInfoFileName, ofType: "plist"),
           let firebaseOptions = FirebaseOptions.init(contentsOfFile: googleServiceInfoFilePath) {
            
            FirebaseApp.configure(options: firebaseOptions)
        }

        // remote notifications
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        // send user interaction events to session agent
        if let foraApplication = application as? ForaApplication {
            
            foraApplication.didTouchEvent = {
                
                self.model.sessionAgent.action.send(SessionAgentAction.Event.UserInteraction())
            }
        }
        
        model.action.send(ModelAction.App.Launched())
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    private var googleServiceInfoFileName: String {
        
        #if DEBUG
        "GoogleService-Info-test"
        #else
        "GoogleService-Info"
        #endif
    }
}

//MARK: - Push Notifications

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken

        // request authorization for push notifications
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        if (userInfo["aps"]) != nil  || (userInfo["otp"] as? String) != nil {

            NotificationCenter.default.post(name: Notification.Name("otpCode"), object: nil, userInfo: userInfo)
        }

        if let eventId = userInfo["event_id"] as? String, let cloudId = userInfo["cloud_id"] as? String {

            model.action.send(ModelAction.Notification.ChangeNotificationStatus.Request(eventId: eventId,
                                                                                          cloudId: cloudId,
                                                                                          status: .delivered))
        }
        
        if let otpCode = otpCode(with: userInfo) {
            
            Model.shared.action.send(ModelAction.Auth.VerificationCode.PushRecieved(code: otpCode))
        }
        
        func otpCode(with info: [AnyHashable : Any]) -> String? {
            
            if let code = info["otp"] as? String  {
                
                return code.filter { "0"..."9" ~= $0 }
                
            } else if let code = info["aps.alert.body"] as? String {
                
                return code.filter { "0"..."9" ~= $0 }
                
            } else {
                
                return nil
            }
        }

        completionHandler([[.alert, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        model.action.send(ModelAction.Notification.Transition.Set(transition: .init(userInfo: userInfo)))

        completionHandler()
    }
}


