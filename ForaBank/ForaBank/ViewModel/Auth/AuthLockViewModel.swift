//
//  AuthLockViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation
import SwiftUI
import Combine

class AuthLockViewModel: ObservableObject {
    
    @Published var state: State
    
    private let rootActions: RootViewModel.AuthActions
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(state: State, rootActions: RootViewModel.AuthActions, model: Model = .emptyMock) {
        
        self.state = state
        self.rootActions = rootActions
        self.model = model
    }
    
    init(_ model: Model, rootActions: RootViewModel.AuthActions) {
        
        self.state = .pincode(.init(model, mode: .unlock(attempt: 0), backAction: {}, dismissAction: {}))
        self.rootActions = rootActions
        self.model = model
        
        let pincodeBackAction: () -> Void = { [weak self] in
            
            guard let self = self else {
                return
            }
            
            withAnimation {
                
                self.state = .login(AuthLoginViewModel(self.model, rootActions: rootActions))
            }
        }
        
        self.state = .pincode(.init(model, mode: .unlock(attempt: 1), backAction: pincodeBackAction, dismissAction: rootActions.dismiss))
    }
    
    enum State {
        
        case pincode(AuthPinCodeViewModel)
        case login(AuthLoginViewModel)
    }
}
