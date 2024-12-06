//
//  ComposedLoginViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.09.2023.
//

import Foundation

final class ComposedLoginViewModel {
    
    let authLoginViewModel: AuthLoginViewModel
    
    init(authLoginViewModel: AuthLoginViewModel) {
        
        self.authLoginViewModel = authLoginViewModel
    }
}
