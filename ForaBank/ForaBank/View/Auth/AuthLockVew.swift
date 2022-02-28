//
//  AuthLockVew.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import SwiftUI

struct AuthLockVew: View {
    
    @ObservedObject var viewModel: AuthLockViewModel
    
    var body: some View {
        
        switch viewModel.state {
        case .pincode(let pincodeViewModel):
            AuthPinCodeView(viewModel: pincodeViewModel)
                .transition(.opacity.combined(with: .scale))
            
        case .login(let loginViewModel):
            NavigationView {
                
                AuthLoginView(viewModel: loginViewModel)
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
            }
        }
    }
}

struct AuthLockVew_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AuthLockVew(viewModel: .init(state: .pincode(.sample), parentActions: .init(dismiss: {}, spinner: .init(show: {}, hide: {}))))
    }
}
