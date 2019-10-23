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

func appReducer(action: Action, state: State?) -> State {
    return State(passcodeSignUpState: passcodeSignUpReducer(state: state?.passcodeSignUpState, action: action), authenticationState: authenticationReducer(state: state?.authenticationState, action: action), passcodeSignInState: passcodeSignInReducer(state: state?.passcodeSignInState, action: action), verificationCodeState: verificationCodeReducer(state: state?.verificationCodeState, action: action), productsState: productReducer(state: state?.productsState, action: action), registrationState: registrationReducer(state: state?.registrationState, action: action))
}
let thunkMiddleware: Middleware<State> = createThunkMiddleware()
var store = Store<State>(reducer: appReducer, state: nil, middleware: [thunkMiddleware])

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
   
           setNavigationBarAppearance()
                setTextFieldAppearance()
                IQKeyboardManager.shared.enable = true
        //        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
                store.dispatch(checkAuthCredentials)
    FirebaseApp.configure()
    application.registerForRemoteNotifications()
    requestNotificationAuthorization(application: application)
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] {
      NSLog("[RemoteNotification] applicationState: \(applicationStateString) didFinishLaunchingWithOptions for iOS9: \(userInfo)")
      //TODO: Handle background notification
    }
    return true
  }
  
  var applicationStateString: String {
    if UIApplication.shared.applicationState == .active {
      return "active"
    } else if UIApplication.shared.applicationState == .background {
      return "background"
    }else {
      return "inactive"
    }
  }
  
  func requestNotificationAuthorization(application: UIApplication) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
    } else {
      let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
  }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
  // iOS10+, called when presenting notification in foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    NSLog("[UserNotificationCenter] applicationState: \(applicationStateString) willPresentNotification: \(userInfo)")
    //TODO: Handle foreground notification
    completionHandler([.alert])
  }
  
  // iOS10+, called when received response (default open, dismiss or custom action) for a notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    NSLog("[UserNotificationCenter] applicationState: \(applicationStateString) didReceiveResponse: \(userInfo)")
    //TODO: Handle background notification
    completionHandler()
  }
}

extension AppDelegate : MessagingDelegate {
  func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
    NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken)")
  }
  
  // iOS9, called when presenting notification in foreground
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    NSLog("[RemoteNotification] applicationState: \(applicationStateString) didReceiveRemoteNotification for iOS9: \(userInfo)")
    if UIApplication.shared.applicationState == .active {
      //TODO: Handle foreground notification
    } else {
      //TODO: Handle background notification
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
