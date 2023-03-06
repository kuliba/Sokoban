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

        Messaging.messaging().delegate = self
        
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
        
        if let launchOptions = launchOptions {
            
            model.action.send(ModelAction.Notification.Transition.Set(transition: .init(userInfo: launchOptions)))
        }
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    private var googleServiceInfoFileName: String = Config.googleServiceInfoFileName
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
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        do {
            
            let push = try Push(decoding: userInfo)
            
            if let code = push.code, let _ = push.aps {
                
                model.action.send(ModelAction.Auth.VerificationCode.PushRecieved(code: code))
                NotificationCenter.default.post(name: Notification.Name("otpCode"), object: nil, userInfo: userInfo)
            }
            
            model.action.send(ModelAction.Notification.ChangeNotificationStatus.Request(statusData: .init(push: push)))
            
        } catch {
            
            LoggerAgent.shared.log(level: .error, category: .model, message: "Unable decode push data with error: \(error)")
        }
        
        completionHandler([[.list, .banner, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        model.action.send(ModelAction.Notification.Transition.Set(transition: .init(userInfo: userInfo)))

        completionHandler()
    }
}

//MARK: - Firebase Cloud Messaging

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        model.fcmToken.send(fcmToken)
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}
