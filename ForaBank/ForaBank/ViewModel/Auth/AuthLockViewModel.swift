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
    
    private let parentActions: AuthLoginViewModel.ParentActions
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(state: State, parentActions: AuthLoginViewModel.ParentActions, model: Model = .emptyMock) {
        
        self.state = state
        self.parentActions = parentActions
        self.model = model
    }
    
    init(_ model: Model, parentActions: AuthLoginViewModel.ParentActions) {
        
        self.state = .pincode(.init(model, mode: .unlock(attempt: 0), backAction: {}, dismissAction: {}))
        self.parentActions = parentActions
        self.model = model
        
        let pincodeBackAction: () -> Void = { [weak self] in
            
            guard let self = self else {
                return
            }
            
            withAnimation {
                
                self.state = .login(AuthLoginViewModel(self.model, parentActions: parentActions))
            }
        }
        
        self.state = .pincode(.init(model, mode: .unlock(attempt: 1), backAction: pincodeBackAction, dismissAction: parentActions.dismiss))
    }
    
    enum State {
        
        case pincode(AuthPinCodeViewModel)
        case login(AuthLoginViewModel)
    }
}
