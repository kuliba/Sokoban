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
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .move(edge: .bottom)))
            
        case .login(let loginViewModel):
            NavigationView {
                
                AuthLoginView(viewModel: loginViewModel)
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .bottom)))
        }
    }
}

struct AuthLockVew_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AuthLockVew(viewModel: .init(state: .pincode(.sample), dismissAction: {}))
    }
}
