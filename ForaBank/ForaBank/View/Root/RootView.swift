//
//  RootView.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import SwiftUI

struct RootView: View {
    
    @ObservedObject var viewModel: RootViewModel
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                Text("Главный эаран")
                
                Button {
                    
                    viewModel.showLock()
                    
                } label: {
                    
                    Text("Окно блокировки")
                }
                .padding()
            }
            
            
            if let loginViewModel = viewModel.login {
                
                NavigationView {
                    
                    AuthLoginView(viewModel: loginViewModel)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .bottom)))
            }
            
            if let lockViewModel = viewModel.lock {
                
                AuthLockVew(viewModel: lockViewModel)
            }
            
            if let spinnerViewModel = viewModel.spinner {
                
                SpinnerView(viewModel: spinnerViewModel)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        RootView(viewModel: .init(.emptyMock))
    }
}
