//
//  SceneDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var bindings = Set<AnyCancellable>()
    
    let rootViewModel = RootViewModel(AppDelegate.shared.model)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let rootViewController = RootViewHostingViewController(with: rootViewModel)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        bind(rootViewModel: rootViewModel)

        //FIXME: remove after refactor paymnets
        NotificationCenter.default
            .addObserver(self,
                         selector:#selector(dismissAll),
                         name: .dismissAllViewAndSwitchToMainTab,
                         object: nil)
    
        legacyNavigationBarBackground()
        setAlertAppearance()
    }
    
    //FIXME: remove after refactor paymnets
    @objc func dismissAll() {
        self.rootViewModel.action.send(RootViewModelAction.DismissAll())
        self.rootViewModel.action.send(RootViewModelAction.SwitchTab(tabType: .main))
    }
}

//MARK: - Bindings

extension SceneDelegate {
    
    func bind(rootViewModel: RootViewModel) {
        
        rootViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as RootViewModelAction.DismissAll:
                    window?.rootViewController?.dismiss(animated: false, completion: nil)
                    rootViewModel.link = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func legacyNavigationBarBackground() {
        // Настройка NavigationBar
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().titleTextAttributes =
            [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().isTranslucent = true
    }
    
    func setAlertAppearance() {
        
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .black
    }
}

//MARK: - Scene Lyfecycle

extension SceneDelegate {
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        DispatchQueue.main.async {
            self.window?.deleteBlure()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
        DispatchQueue.main.async {
            self.window?.addBlure()
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
        AppDelegate.shared.model.action.send(ModelAction.App.Activated())
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
        AppDelegate.shared.model.action.send(ModelAction.App.Inactivated())
    }
}

//MARK: - DeepLinks

extension SceneDelegate {
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        //FIXME: looks like some C2B deeplink
        
        /*
        guard let url = URLContexts.first?.url else { return }
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let params = components.queryItems else {
            return
        }

        if url.description.contains("qr.nspk.ru") {
            var strUrl = url.description.replacingOccurrences(of: "https2", with: "https")
            strUrl = strUrl.replacingOccurrences(of:"amp;", with:"")
            GlobalModule.c2bURL = strUrl
            let topvc = UIApplication.topViewController()
            let controller = C2BDetailsViewController.storyboardInstance()!
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            topvc?.present(nc, animated: false)
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
         */
    }
}
