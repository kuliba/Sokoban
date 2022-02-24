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
    
    private let dismissAction: () -> Void
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    
    init(state: State, dismissAction: @escaping () -> Void, model: Model = .emptyMock) {
        
        self.state = state
        self.dismissAction = dismissAction
        self.model = model
    }
    
    init(_ model: Model, dismissAction: @escaping () -> Void) {
        
        self.state = .pincode(.init(model, mode: .unlock(attempt: 0), backAction: {}, dismissAction: {}))
        self.dismissAction = dismissAction
        self.model = model
        
        let pincodeBackAction: () -> Void = { [weak self] in
            
            guard let self = self else {
                return
            }
            
            withAnimation {
                
                self.state = .login(AuthLoginViewModel(self.model, dismissAction: self.dismissAction))
            }
        }
        
        self.state = .pincode(.init(model, mode: .unlock(attempt: 1), backAction: pincodeBackAction, dismissAction: dismissAction))
    }
    
    enum State {
        
        case pincode(AuthPinCodeViewModel)
        case login(AuthLoginViewModel)
    }
}
