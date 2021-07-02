//
//  SceneDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import FirebaseMessaging

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

//    static var shared: SceneDelegate { return UIApplication.shared.delegate as? SceneDelegate }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        AppDelegate.shared.getCSRF { error in
            if error != nil {
                print("DEBUG: Error getCSRF: ", error!)
            }
            let userIsRegister = UserDefaults.standard.object(forKey: "UserIsRegister") as? Bool
//            userIsRegister = false
            if let userIsRegister = userIsRegister {
                if userIsRegister {
                    self.goToPinVC(.validate)
                } else {
                    self.goToRegisterVC()
                }
            } else {
                self.goToRegisterVC()
            }
        }
        window?.makeKeyAndVisible()
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
        
//        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.deleteBlure()
//        }
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


}

extension SceneDelegate {
    
    func goToRegisterVC() {
        DispatchQueue.main.async { [weak self] in
            let navVC = UINavigationController(rootViewController: LoginCardEntryViewController())
            self?.window?.rootViewController = navVC
        }
        
    }
    
    func goToPinVC(_ mode: ALMode) {
        DispatchQueue.main.async { [weak self] in
            var options = ALOptions()
            options.isSensorsEnabled = true
            options.onSuccessfulDismiss = { (mode: ALMode?) in
                if let mode = mode {
                    DispatchQueue.main.async { [weak self] in
                        print("Password \(String(describing: mode)) successfully")
                        let vc = MainTabBarViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self?.window?.rootViewController = vc //MainTabBarViewController()
                    }
                } else {
                    print("User Cancelled")
                }
            }
            options.onFailedAttempt = { (mode: ALMode?) in
                print("Failed to \(String(describing: mode))")
            }
            AppLocker.rootViewController(with: mode, and: options, window: self?.window)
        }
    }
}


extension AppDelegate {
    func getCSRF(completion: @escaping (_ error: String?) ->()) {
        let parameters = [
            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
            "pushFcmToken": Messaging.messaging().fcmToken as String?,
            "model": UIDevice().model,
            "operationSystem": "IOS"
        ] as [String : AnyObject]
        
        NetworkManager<CSRFDecodableModel>.addRequest(.csrf, [:], parameters) { request, error in
            if error != nil {
                completion(error)
            }
            guard let token = request?.data?.token else {
                completion("error")
                return
            }
            print("DEBUG: CSRF DONE!")
            CSRFToken.token = token
            
            NetworkManager<InstallPushDeviceDecodebleModel>.addRequest(.installPushDevice, [:], parameters) { model, error in
                if error != nil {
                    print("DEBUG: installPushDevice error", error ?? "nil")
                    completion(error)
                }
                print("DEBUG: CSRF DONE!")
//                print("DEBUG: installPushDevice model", model ?? "nil")
                completion(nil)
            }
            
        }
    }
}
