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
    
    private lazy var model: Model = AppDelegate.shared.model
    private lazy var logger: LoggerAgentProtocol = LoggerAgent.shared
    private lazy var httpClient: HTTPClient = { model.authenticatedHTTPClient()
    }()
    private lazy var rootViewModel = RootViewModelFactory.make(
        httpClient: httpClient,
        model: model,
        logger: logger,
        qrResolverFeatureFlag: .init(.active),
        fastPaymentsSettingsFlag: .init(.active(.live)),
        utilitiesPaymentsFlag: .init(.inactive)
    )
    private lazy var rootViewFactory = RootViewFactoryComposer(model: model).compose()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let rootViewController = RootViewHostingViewController(
            with: rootViewModel,
            rootViewFactory: rootViewFactory
        )
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
        
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
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
                    rootViewModel.resetLink()
                    rootViewModel.reset()
                    
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
        
        self.window?.deleteBlure()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
        self.window?.addBlure()
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

        guard let context = URLContexts.first, let deepLinkType = DeepLinkType(url: context.url) else { return }
          
        AppDelegate.shared.model.action.send(ModelAction.DeepLink.Set(type: deepLinkType))
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
                   let url = userActivity.webpageURL else { return }

        guard let deepLink = DeepLinkType(url: url) else { return }
        
        AppDelegate.shared.model.action.send(ModelAction.DeepLink.Set(type: deepLink))
    }
}
