//
//  SceneDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import Firebase
import FirebaseMessaging

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var netAlert: NetDetectAlert!
    var netStatus: Bool?
    
    lazy var appNavigationController = UINavigationController()
    lazy var appRouter = Router(navigationController: self.appNavigationController)
    lazy var appCoordinator = MainCoordinator(router: self.appRouter)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
//        // MARK: Window
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = appCoordinator.toPresentable()
        window?.backgroundColor = .red
        appCoordinator.start()
        window?.makeKeyAndVisible()
        
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
//        window?.windowScene = windowScene
//        let startController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
//        window?.rootViewController = startController
////        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
////        tapGesture.delegate = self
////        window?.addGestureRecognizer(tapGesture)
//        let userIsRegister = UserDefaults.standard.object(forKey: "UserIsRegister") as? Bool
//        if let userIsRegister = userIsRegister {
//            if userIsRegister {
//                self.goToPinVC(.validate)
//            } else {
//                self.goToRegisterVC()
//            }
//        } else {
//            self.goToRegisterVC()
//        }
//        window?.makeKeyAndVisible()
        
        NetStatus.shared.netStatusChangeHandler = {
            DispatchQueue.main.async { [weak self] in
                if NetStatus.shared.isConnected == true {
                    self?.netStatus = true
                    self?.netAlert?.removeFromSuperview()
                } else {
                    self?.netStatus = false
                    self?.netDetect()
                }
            }
        }
    }
    
    private func netDetect() {
        guard let vc = UIApplication.getTopViewController() else {return}
        self.netAlert = NetDetectAlert(vc.view)
        if self.netAlert != nil {
            vc.view.addSubview(self.netAlert)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.deleteBlure()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addBlure()
        }
        // Add blure affect
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else { return }
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let params = components.queryItems else {
            return
        }

        if let bankId = params.first?.value {
            let bankId = String(bankId.dropFirst(4))
            let isAuth = AppDelegate.shared.isAuth
            if isAuth == true {
                
                let body = ["bankId": bankId] as [String: AnyObject]
                NetworkManager<GetMe2MeDebitConsentDecodableModel>.addRequest(.getMe2MeDebitConsent, [:], body) { model, error in
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        DispatchQueue.main.async {
                            if model.data != nil {
                                
                                let topvc = UIApplication.topViewController()
                                
                                let vc = MeToMeRequestController()
                                let meToMeReq = RequestMeToMeModel(model: model)
                                vc.viewModel = meToMeReq
                                vc.modalPresentationStyle = .fullScreen
                                
                                topvc?.present(vc, animated: true, completion: {
                                    UserDefaults.standard.set(nil, forKey: "GetMe2MeDebitConsent")
                                })
                                
                            } else {
                                let topvc = UIApplication.topViewController()
                                
                                let vc = MeToMeRequestController()
                                let meToMeReq = RequestMeToMeModel(bank: bankId)
                                vc.viewModel = meToMeReq
                                vc.doneButtonTapped()
                                vc.modalPresentationStyle = .fullScreen
                                
                                topvc?.present(vc, animated: true, completion: {
                                    UserDefaults.standard.set(nil, forKey: "GetMe2MeDebitConsent")
                                })
                            }
                        }
                    }
                }
                
            } else {
                
                UserDefaults.standard.set(bankId, forKey: "GetMe2MeDebitConsent")
            }
        }
    }

}

extension SceneDelegate {
    
//    func goToRegisterVC() {
//        DispatchQueue.main.async { [weak self] in
//            let navVC = UINavigationController(rootViewController: LoginCardEntryViewController())
//            self?.window?.rootViewController = navVC
//        }
//    }
//
//    func goToPinVC(_ mode: ALMode) {
//        DispatchQueue.main.async { [weak self] in
//            var options = ALOptions()
//            options.isSensorsEnabled = UserDefaults().object(forKey: "isSensorsEnabled") as? Bool
//            options.onSuccessfulDismiss = { (mode: ALMode?, _) in
//                if let mode = mode {
//                    DispatchQueue.main.async { [weak self] in
//                        print("Password \(String(describing: mode)) successfully")
//                        let vc = MainTabBarViewController()
//                        vc.modalPresentationStyle = .fullScreen
//                        self?.window?.rootViewController = vc //MainTabBarViewController()
//                    }
//                } else {
//                    print("User Cancelled")
//                }
//            }
//            options.onFailedAttempt = { (mode: ALMode?) in
//                print("Failed to \(String(describing: mode))")
//            }
//            AppLocker.rootViewController(with: mode, and: options, window: self?.window)
//        }
//    }
}

//protocol StoreType: AnyObject {
//    var isLoggedIn: Bool { get }
//    var token: String? { get set }
//    var delegate: StoreDelegate? { get set }
//}
//
//protocol StoreDelegate: AnyObject {
//    func store(_ store: StoreType, didChangeLogginState isLoggedIn: Bool)
//}
//
///*
// The point of this project is not the store much so
// I'm making it as simple as possible. The store holds your service layer which
// should include your network and caching layers. I would probably use reactive
// components instead of delegation here so you can just bind your coordinator
// to variables but I'm trying to avoid using any third party libraries in this
// project.
//*/
//class Store: NSObject, StoreType {
//
//    weak var delegate: StoreDelegate?
//
//    var isLoggedIn: Bool = false {
//        didSet {
//            delegate?.store(self, didChangeLogginState: isLoggedIn)
//        }
//    }
//
//    var token: String? {
//        didSet {
//            isLoggedIn = token != nil
//        }
//    }
//
//    private let config: ConfigType
//
//    init(config: ConfigType) {
//        self.config = config
//        super.init()
//    }
//}
//
//public protocol ConfigProvidingType: AnyObject {
//    var config: ConfigType { get }
//}
//
//public protocol ConfigType {
//    var environment: Environment { get }
//    var appVersion: String { get }
//    var buildNumber: String { get }
//    var apiVersion: String { get }
//    var apiEndpoint: String { get }
//    var url: URL  { get }
//    var locale: Locale { get }
//    init(bundle: Bundle, locale: Locale)
//}
//
//public class Config: ConfigType {
//
//    public let environment: Environment
//    public let appVersion: String
//    public let buildNumber: String
//    public let apiVersion: String
//    public let apiEndpoint: String
//    public let locale: Locale
//
//    public lazy var url: URL = URL(string: "\(self.apiEndpoint)/\(self.apiVersion)")!
//
//    public required init(bundle: Bundle, locale: Locale) {
//        self.locale = locale
//
//        let endpoints = bundle.object(forInfoDictionaryKey: "API Endpoints") as! [String: String]
//        let env = bundle.object(forInfoDictionaryKey: "Environment") as! String
//
//        environment = Environment(rawValue: env.lowercased()) ?? .release
//
//        apiEndpoint = endpoints[env]!
//        appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
//
//        buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as! String
//        apiVersion = bundle.object(forInfoDictionaryKey: "API Version") as! String
//    }
//}
//
//public enum Environment: String {
//    case debug
//    case mock
//    case dev
//    case staging
//    case release
//}
