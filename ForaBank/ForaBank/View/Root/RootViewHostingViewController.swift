//
//  RootViewHostingViewController.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation
import SwiftUI
import Combine

class RootViewHostingViewController: UIHostingController<RootView> {
    
    private let viewModel: RootViewModel
    private var cover: Cover?
    private var isCoverDismissing: Bool
    private var spinner: UIViewController?
    private var bindings = Set<AnyCancellable>()

    init(with viewModel: RootViewModel) {
        
        self.viewModel = viewModel
        self.cover = nil
        self.isCoverDismissing = false
        super.init(rootView: RootView(viewModel: viewModel))
        
        bind()
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        
        print("SessionAgent: RootViewHostingViewController BIND")
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as RootViewModelAction.Cover.ShowLogin:
                    dismissCover(animated: false)
                    let loginView = AuthLoginView(viewModel: payload.viewModel)
                    let loginViewController = UIHostingController(rootView: loginView)
                    let navigation = UINavigationController(rootViewController: loginViewController)
                    presentCover(navigation, of: .login, animated: false)
                    print("SessionAgent: PRESENT LOGIN, childs: \(children.count) , addr:\(Unmanaged.passUnretained(navigation).toOpaque())")
                    
                case let payload as RootViewModelAction.Cover.ShowLock:
                    dismissCover(animated: false)
                    let lockView = AuthPinCodeView(viewModel: payload.viewModel)
                    let lockViewController = UIHostingController(rootView: lockView)
                    presentCover(lockViewController, of: .lock, animated: payload.animated)
                    print("SessionAgent: PRESENT LOCK")
      
                case _ as RootViewModelAction.Cover.Hide:
                    if isCoverDismissing == false {
                        dismissCover(animated: true)
                    }
                    print("SessionAgent: DISMISS COVER")
                    
                case let payload as RootViewModelAction.Spinner.Show:
                    presentSpinner(viewModel: payload.viewModel)
                    print("SessionAgent: SPINNER SHOW")
                    
                case _ as RootViewModelAction.Spinner.Hide:
                    dismissSpinner()
                    print("SessionAgent: SPINNER HIDE")
                    
                default:
                    return
                    
                }
                
            }.store(in: &bindings)
    }
    
    private func presentCover(_ viewController: UIViewController, of type: Cover.Kind, animated: Bool) {
        
        guard let scene = view.window?.windowScene else {
            return
        }
        
        let window = UIWindow(windowScene: scene)
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        viewController.view.frame = UIScreen.main.bounds
        
        if animated == true {
            
            let screenHeight = UIScreen.main.bounds.height
            viewController.view.transform = CGAffineTransform(translationX: 0, y: screenHeight)
            UIView.animate(withDuration: 0.28, delay: 0.1, options: .curveEaseInOut) {
                
                viewController.view.transform = .identity
                
            } completion: { _ in
                
                self.cover = Cover(type: type, controller: viewController, window: window)
            }
            
        } else {
            
            self.cover = Cover(type: type, controller: viewController, window: window)
        }
    }
    
    private func dismissCover(animated: Bool) {
        
        guard let cover = cover else {
            return
        }
        
        if animated == true {
            
            isCoverDismissing = true
            switch cover.type {
            case .login:
                let screenWidth = UIScreen.main.bounds.width
                UIView.animate(withDuration: 0.28, delay: 0.1, options: .curveEaseInOut) {
                    
                    cover.controller.view.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
                    
                } completion: { _ in
                    
                    cover.window.isHidden = true
                    self.cover = nil
                    self.isCoverDismissing = false
                }
                
            case .lock:
                let screenHeight = UIScreen.main.bounds.height
                UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseInOut) {
                    
                    cover.controller.view.transform = CGAffineTransform(translationX: 0, y: screenHeight)
                    
                } completion: { _ in
                    
                    cover.window.isHidden = true
                    self.cover = nil
                    self.isCoverDismissing = false
                }
            }
            
            print("SessionAgent: COVER DISMISSED ANIMATED, addr:\(Unmanaged.passUnretained(cover.controller).toOpaque())")
            
        } else {
            
            cover.window.isHidden = true
            self.cover = nil
            
            print("SessionAgent: COVER DISMISSED addr:\(Unmanaged.passUnretained(cover.controller).toOpaque())")
        }
    }
    
    func presentSpinner(viewModel: SpinnerView.ViewModel) {
        
        let spinnerView = SpinnerView(viewModel: viewModel)
        let spinnerController = UIHostingController(rootView: spinnerView)
        spinnerController.view.backgroundColor = .clear
        
        addChild(spinnerController)
        view.addSubview(spinnerController.view)
        spinnerController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinnerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spinnerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spinnerController.view.topAnchor.constraint(equalTo: view.topAnchor),
            spinnerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        spinnerController.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            
            spinnerController.view.alpha = 1.0
            
        } completion: { _ in
            
            spinnerController.didMove(toParent: self)
        }
        
        self.spinner = spinnerController
    }
    
    func dismissSpinner() {
        
        spinner?.willMove(toParent: nil)
        UIView.animate(withDuration: 0.3) {
            
            self.spinner?.view.alpha = 0
            
        } completion: { _ in
            
            self.spinner?.view.removeFromSuperview()
            self.spinner?.removeFromParent()
            self.spinner = nil
        }
    }
}

extension RootViewHostingViewController {
    
    struct Cover {
        
        let type: Kind
        let controller: UIViewController
        let window: UIWindow
        
        enum Kind {
            
            case login
            case lock
        }
    }
    
    enum Layer: Hashable, CaseIterable {
        
        case login
        case spinner
        case lock
    }
    
    enum AnimationStyle {
        
        case vertical
        case horizontal
        case fade
    }
}
