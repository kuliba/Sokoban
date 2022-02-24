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
    
    private let model: Model
    
    init(_ model: Model) {
        
        self.model = model
    }
    
    func showLogin() {
        
        login = AuthLoginViewModel(model, dismissAction: {[weak self] in
            withAnimation {
                self?.login = nil
            }})
    }
    
    func showLock() {
        
        withAnimation {
            
            lock = AuthLockViewModel(model, dismissAction: {[weak self] in
                withAnimation {
                    self?.lock = nil
                }
            })
        }
    }
}
