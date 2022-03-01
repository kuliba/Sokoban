//
//  RootViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation
import SwiftUI

class RootViewModel: ObservableObject {
    
    @Published var login: AuthLoginViewModel?
    @Published var lock: AuthLockViewModel?
    @Published var spinner: SpinnerView.ViewModel?
    
    private let model: Model
    
    init(_ model: Model) {
        
        self.model = model
    }
    
    func showLogin() {
        
        login = AuthLoginViewModel(model, rootActions: .init(dismiss: {[weak self] in
            withAnimation {
                self?.login = nil
            }
        }, spinner: .init(show: {[weak self] in
            withAnimation {
                self?.spinner = SpinnerView.ViewModel()
            }
        }, hide: {[weak self] in
            withAnimation {
                self?.spinner = nil
            }
        })))
    }
    
    func showLock() {
        
        withAnimation {
            
            lock = AuthLockViewModel(model, rootActions: .init(dismiss: {[weak self] in
                withAnimation {
                    self?.lock = nil
                }
            }, spinner: .init(show: {[weak self] in
                withAnimation {
                    self?.spinner = SpinnerView.ViewModel()
                }
            }, hide: {[weak self] in
                withAnimation {
                    self?.spinner = nil
                }
            })))
        }
    }
}

extension RootViewModel {
    
    struct AuthActions {
        
        let dismiss: () -> Void
        let spinner: Spinner
        
        struct Spinner {
            
            let show: () -> Void
            let hide: () -> Void
        }
    }
}
