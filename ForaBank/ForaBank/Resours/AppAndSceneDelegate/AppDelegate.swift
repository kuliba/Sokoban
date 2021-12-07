//
//  AppDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import Firebase
import FirebaseMessaging
import RealmSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var delegate: Encription?
    let timer = BackgroundTimer()
    
    var isAuth: Bool? {
        didSet {
            guard isAuth != nil else { return }
            // Запуск таймера
           timer.repeatTimer()
        }
    }

    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
        RealmConfiguration()

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
        
        self.initRealmTimerParameters()
        // Net Detect
        NetStatus.shared.startMonitoring()
        return true
    }
    
    func initRealmTimerParameters() {
        let realm = try? Realm()
        // Сохраняем текущее время
        let updatingTimeObject = GetSessionTimeout()
        updatingTimeObject.maxTimeOut = StaticDefaultTimeOut.staticDefaultTimeOut
        updatingTimeObject.mustCheckTimeOut = true
        print("Debugging AppDelegate", updatingTimeObject.mustCheckTimeOut)
        do {
            let model = realm?.objects(GetSessionTimeout.self)
            realm?.beginWrite()
            realm?.delete(model!)
            realm?.add(updatingTimeObject)
            try realm?.commitWrite()
       
        } catch {
            print(error.localizedDescription)
        }

    }

    
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {

        // Determine who sent the URL.
        let sendingAppID = options[.sourceApplication]
        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let albumPath = components.path,
            let params = components.queryItems else {
                return false
        }
        if let photoIndex = params.first(where: { $0.name == "id" })?.value {
            return true
        } else {
            return false
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    fileprivate func RealmConfiguration() {
        // Версия БД (изменить на большую если меняем БД)
        let schemaVersion: UInt64 = 5

        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: schemaVersion,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < schemaVersion) {
                    if oldSchemaVersion < 3 {
                        migration.deleteData(forType: "GKHOperatorsModel")
                    }
                    if oldSchemaVersion < 4 {
                        migration.deleteData(forType: "Parameters")
                    }
                    if oldSchemaVersion < 5 {
                        migration.deleteData(forType: "LogotypeData")
                         migration.deleteData(forType: "UserAllCardsModel")
                    }

                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            })
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
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
            self.isAuth = false
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if (userInfo["otp"] as? String) != nil {
            NotificationCenter.default.post(name: Notification.Name("otpCode"), object: nil, userInfo: userInfo)
        }
        completionHandler([[.alert, .sound]])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let type = userInfo["type"] as? String {
            if type == "сonsentMe2MePull" {
                let meToMeReq = RequestMeToMeModel(userInfo: userInfo)
                
                if isAuth == true {
                    let topvc = UIApplication.topViewController()
                    
                    let vc = MeToMeRequestController()
                    vc.viewModel = meToMeReq
                    vc.modalPresentationStyle = .fullScreen
                    topvc?.present(vc, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.set(userInfo, forKey: "ConsentMe2MePull")
                }
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
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
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
              
            _ = Encription().encryptedPublicKey()
                                   
            _ = Encription().computeSharedSecret(ownPrivateKey: KeyPair.privateKey!, otherPublicKey: KeyFromServer.pubFromServ!)
                                   
                               
            _ = SecKeyCreateEncryptedData(KeyPair.publicKey!, .rsaEncryptionRaw, Data(base64Encoded: KeyFromServer.publicKey!)! as CFData, nil)

            _ = Encription().encryptWithRSAKey(Data(base64Encoded: KeyFromServer.publicKey!)!, rsaKeyRef: KeyPair.privateKey!, padding: .PKCS1)
        
            CSRFToken.token = token
            
            let parameters = [
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


enum VersionError: Error {
    case invalidBundleInfo, invalidResponse
}

class LookupResult: Decodable {
    var results: [AppInfo]
}

class AppInfo: Decodable {
    var version: String
    var trackViewUrl: String
}

class AppUpdater: NSObject {

    private override init() {}
    static let shared = AppUpdater()

    func showUpdate(withConfirmation: Bool) {
        DispatchQueue.global().async {
            self.checkVersion(force : !withConfirmation)
        }
    }

    private  func checkVersion(force: Bool) {
        let info = Bundle.main.infoDictionary
        if let currentVersion = info?["CFBundleShortVersionString"] as? String {
            _ = getAppInfo { (info, error) in
                if let appStoreAppVersion = info?.version{
                    if let error = error {
                        print("error getting app store version: ", error)
                    } else if appStoreAppVersion <= currentVersion{
                        print("Already on the last app version: ",currentVersion)
                    } else {
                        print("Needs update: AppStore Version: \(appStoreAppVersion) > Current version: ",currentVersion)
                        DispatchQueue.main.async {
                            guard let vc = UIApplication.getTopViewController() else {return}
//                            let topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                            vc.showAppUpdateAlert(Version: (info?.version)!, Force: force, AppURL: (info?.trackViewUrl)!)
                        }
                    }
                }
            }
        }
    }

    private func getAppInfo(completion: @escaping (AppInfo?, Error?) -> Void) -> URLSessionDataTask? {
        guard let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                DispatchQueue.main.async {
                    completion(nil, VersionError.invalidBundleInfo)
                }
                return nil
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let result = try JSONDecoder().decode(LookupResult.self, from: data)
                guard let info = result.results.first else { throw VersionError.invalidResponse }

                completion(info, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
}

extension UIViewController {
    @objc fileprivate func showAppUpdateAlert( Version : String, Force: Bool, AppURL: String) {
        let appName = Bundle.appName()

        let alertTitle = "Новая версия"
        let alertMessage = "Доступна новая версия \(Version)."

        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        if !Force {
            let notNowButton = UIAlertAction(title: "Не сейчас", style: .default)
            alertController.addAction(notNowButton)
        }

        let updateButton = UIAlertAction(title: "Обновить", style: .default) { (action:UIAlertAction) in
            guard let url = URL(string: AppURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }

        alertController.addAction(updateButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
extension Bundle {
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        if let version : String = dictionary["CFBundleName"] as? String {
            return version
        } else {
            return ""
        }
    }
}

extension UIWindow {
 open override func motionEnded(_ motion: UIEvent.EventSubtype, with event:   UIEvent?) {
     if motion == .motionShake {
        print("Device shaken")
//        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
//        UserDefaults.standard.set(MyVariables.onBalanceLabel.toggle(), forKey: "blurBalanceLabel")
        MyVariables.onBalanceLabel = false
        
        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
    }
  }
}

extension NSNotification.Name {
    public static let deviceDidShakeNotification = NSNotification.Name("MyDeviceDidShakeNotification")
}

struct MyVariables {
    static var onBalanceLabel = false
}
