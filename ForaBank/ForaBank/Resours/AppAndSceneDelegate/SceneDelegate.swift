//
//  SceneDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import Firebase
import FirebaseMessaging
import Combine
import Network

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - NetMonitor
    private var cancellables = Set<AnyCancellable>()
    private let monitorQueue = DispatchQueue(label: "monitor")

    var window: UIWindow?
    
    var netAlert: NetDetectAlert!
    var netStatus: Bool?
    
    lazy var appNavigationController = UINavigationController()
    lazy var appRouter = Router(navigationController: self.appNavigationController)
    lazy var appCoordinator = MainCoordinator(router: self.appRouter)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // MARK: Window
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = appCoordinator.toPresentable()
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        self.appCoordinator.start()
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.delegate = self
        window?.addGestureRecognizer(tapGesture)
        
        // NetMonitoring observer
        self.observeNetworkStatus()

    }
    
    private func observeNetworkStatus() {
        NWPathMonitor()
            .publisher(queue: monitorQueue)
            .receive(on: DispatchQueue.main)
            .sink { status in
                DispatchQueue.main.async { [weak self] in
                    if status == .satisfied {
                        self?.netStatus = true
                        self?.netAlert?.removeFromSuperview()
                        self?.netAlert = nil
                    } else {
                        guard let vc = UIApplication.getTopViewController() else {return}
                        if self?.netAlert == nil {
                            self?.netAlert = NetDetectAlert(vc.view)
                            vc.view.addSubview((self?.netAlert)!)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.deleteBlure()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addBlure()
        }
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

