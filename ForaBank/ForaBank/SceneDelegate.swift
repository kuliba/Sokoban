//
//  SceneDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import Combine
import CombineSchedulers
import MarketShowcase
import PayHubUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var factory: RootFactory = ModelRootFactory.shared
    private lazy var featureFlags = loadFeatureFlags()
    
    private typealias RootDomain = RootViewDomain<RootViewModel>
    
    private lazy var binder: RootDomain.Binder = {
        
        var bindings = Set<AnyCancellable>()
        let rootViewModel = factory.makeRootViewModel(
            featureFlags,
            bindings: &bindings
        )
        
        let getNavigation = factory.makeGetRootNavigation(featureFlags)
        let composer = RootDomain.BinderComposer(
            bindings: bindings,
            dismiss: { [weak self] in
                
                let root = self?.window?.rootViewController
                root?.dismiss(animated: false, completion: nil)
            },
            getNavigation: getNavigation,
            schedulers: .init(),
            witnesses: .default
        )
        
        return composer.compose(with: rootViewModel)
    }()
    
    private lazy var rootViewFactory = factory.makeRootViewFactory(featureFlags)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        configureWindow()
        
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        
        if let userActivity = connectionOptions.userActivities.first {
            
            self.scene(scene, continue: userActivity)
        }
    }
    
    func configureWindow() {
        
        let rootViewController = RootViewHostingViewController(
            with: binder,
            rootViewFactory: rootViewFactory
        )
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        //FIXME: remove after refactor payments
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(dismissAll),
                         name: .dismissAllViewAndSwitchToMainTab,
                         object: nil)
        
        legacyNavigationBarBackground()
        setAlertAppearance()
    }
    
    // FIXME: remove after refactor payments
    @objc func dismissAll() {
        
        self.binder.content.action.send(RootViewModelAction.DismissAll())
        self.binder.content.action.send(RootViewModelAction.SwitchTab(tabType: .main))
    }
}

// MARK: - helpers

private extension SceneDelegate {
    
    func loadFeatureFlags() -> FeatureFlags {
        
        let retrieve = { UserDefaults.standard.string(forKey: $0) }
        let loader = FeatureFlagsLoader(
            retrieve: { retrieve($0.rawValue) }
        )
        
        return loader.load()
    }
}

// MARK: - appearance

extension SceneDelegate {
    
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

// MARK: - Scene Lifecycle

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

// MARK: - DeepLinks

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
