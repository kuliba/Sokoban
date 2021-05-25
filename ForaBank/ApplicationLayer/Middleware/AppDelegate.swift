/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import IQKeyboardManagerSwift
import ReSwift
import ReSwiftThunk
import CryptoSwift
import UserNotifications
import Firebase
import FirebaseMessaging
//import FirebaseInstanceID

//import Network
struct FCMToken {
    static var fcmToken: String?
}
struct KeyPair {
    static var publicKey: SecKey?
    static var privateKey: SecKey?
}
struct KeyFromServer {
    static var publicKey: String?
    static var publicKeyCert: String?
    static var privateKeyCert: String?
}
func appReducer(action: Action, state: State?) -> State {
    return State(authenticationState: authenticationReducer(state: state?.authenticationState, action: action),
                 userState: userReducer(state: state?.userState, action: action),
                 productsState: productReducer(state: state?.productsState, action: action),
                 registrationState: registrationReducer(state: state?.registrationState, action: action),
                 passcodeSignUpState: passcodeSignUpReducer(state: state?.passcodeSignUpState, action: action),
                 passcodeSignInState: passcodeSignInReducer(state: state?.passcodeSignInState, action: action),
                 verificationCodeState: verificationCodeReducer(state: state?.verificationCodeState, action: action))
}
let thunkMiddleware: Middleware<State> = createThunkMiddleware()
var store = Store<State>(reducer: appReducer, state: nil, middleware: [thunkMiddleware])
var csrf: Bool?
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        let delegate = KeyPairGeneration()
        let keyPair = delegate.createOwnKey()
        print(keyPair)

        Messaging.messaging().delegate = self
        setNavigationBarAppearance()
        setTextFieldAppearance()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        
        cleanKeychainIfNeeded()
//        store.dispatch(checkAuthCredentials)
        AuthenticationService.shared.startSecurityCheckIfNeeded()

        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        requestNotificationAuthorization(application: application)
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] {
            NSLog("[RemoteNotification] applicationState: \(applicationStateString) didFinishLaunchingWithOptions for iOS9: \(userInfo)")
            //TODO: Handle background notification
        }
        let parameters = [
        "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
        "pushFCMtoken": Messaging.messaging().fcmToken as Any,
        "model": UIDevice().model,
         "operationSystem": "IOS"
        ] as [String : Any]
        
        func sendRequestToServer(actionCSRF: Bool){
            NetworkManager.shared().isSignedIn { (isSignIn) in
                    NetworkManager.shared().installPushDevice(parameters: parameters, auth: isSignIn) { (success, errorMessage) in
                        if success{
                            print("Это пуши \(success)")
                        } else {
                            print(errorMessage)
                        }
                }

                }
            }
        sendRequestToServer(actionCSRF: false)
        checkInternetConnection()
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      
        
        
        print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict:[String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
         if !application.isRegisteredForRemoteNotifications {
             NotificationCenter.default.post(name: Notification.Name(rawValue: kApplicationDidRegisterWithDeviceToken), object: nil)
         }
     }
    

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        store.dispatch(checkAuthCredentials)
        
//        AuthenticationService.shared.startSecurityCheckIfNeeded()
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
    

    // MARK: - MessagingDelegate

    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
      
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
//        print(application.isRegisteredForRemoteNotifications)
        
        let token = Messaging.messaging().fcmToken
//         print("FCM token: \(token ?? "")")
        FCMToken.fcmToken = Messaging.messaging().fcmToken as String?

//        sendRequestToServer(actionCSRF: false)
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        let tokenString = NSMutableString()
        
        for i in 0 ..< deviceToken.count {
            tokenString.appendFormat("%02.2hhx", tokenChars[i])
        }
        
        LivetexCoreManager.defaultManager.apnToken = tokenString as String
        NotificationCenter.default.post(name: Notification.Name(rawValue: kApplicationDidRegisterWithDeviceToken), object: nil)
//        print("tokenString: \(tokenString)")
    }

    func requestNotificationAuthorization(application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }

    func cleanKeychainIfNeeded() {
        let settingsStorage = SettingsStorage.shared

        if settingsStorage.isFirstLaunch() {
            settingsStorage.setFirstLaunch()
            settingsStorage.invalidateUserSettings()
            removeAllKeychainItems()
        }
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
        UITextField.appearance().backgroundColor = UIColor(red: 0.889415, green: 0.889436, blue: 0.889424, alpha: 0.25)//UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)//
    }
}

@available(iOS 10, *)
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
//    print(userInfo)

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
}

extension AppDelegate: MessagingDelegate {
 
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken)")
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


extension AppDelegate{
    
    //запускаем постоянную проверку сети
    func checkInternetConnection(){
        DispatchQueue.global(qos: .background).async {
            var firstStatus = Reach().connectionStatus() // последний статус сети
            while 1==1{
                let status = Reach().connectionStatus() // текущий статус сети
                if firstStatus.description != status.description{
                    self.changeInternetStatus(status)
                    firstStatus = status
                }
                
            }
        }
    }
    
    // определяет действие при изменении сети
    func changeInternetStatus(_ status: ReachabilityStatus){
        switch status {
        case .offline, .unknown:
            addViewToRoot()
        case .online(.wiFi), .online(.wwan):
            removeViewToRoot()
        }
    }
    
    // добавляет оповещение view в rootVC
    func addViewToRoot(){
        DispatchQueue.main.async {
            guard let rootVC = getRootVC() else {return}
            let viewStatus = self.getViewChangeInternetStatus()
            rootVC.view.addSubview(viewStatus)
        }
    }
    
    // удаляем оповещение view в rootVC
    func removeViewToRoot(){
        DispatchQueue.main.async {
            guard let rootVC = getRootVC() else {return}
            guard let removeView = rootVC.view.viewWithTag(999) else{return}
            removeView.removeFromSuperview()
        }
    }
    
    //создаем  view c оповещением
    func getViewChangeInternetStatus()->UIView{
        let viewStatus = UIView(frame: CGRect(x: 0, y: 34, width: UIScreen.main.bounds.size.width, height: 10))
        viewStatus.tag = 999 // нужен для поределения этого view
        viewStatus.isHidden = false
        viewStatus.backgroundColor = .lightGray
        
        let label = UILabel()
        label.text = "нет соединения"
        label.textColor = .red
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 8)
        
        viewStatus.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = label.centerXAnchor.constraint(equalTo: viewStatus.centerXAnchor)
        let verticalConstraint = label.centerYAnchor.constraint(equalTo: viewStatus.centerYAnchor)
        let widthConstraint = label.widthAnchor.constraint(equalToConstant: viewStatus.frame.size.width)
        let heightConstraint = label.heightAnchor.constraint(equalToConstant: viewStatus.frame.size.height)
        viewStatus.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        horizontalConstraint.isActive = true
        verticalConstraint.isActive = true
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        return viewStatus
    }

}
