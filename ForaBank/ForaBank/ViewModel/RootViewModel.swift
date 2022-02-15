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
    
    private let model: Model
    
    init(_ model: Model) {
        
        self.model = model
    }
    
    func showLogin() {
        
        login = AuthLoginViewModel()
    }
}
