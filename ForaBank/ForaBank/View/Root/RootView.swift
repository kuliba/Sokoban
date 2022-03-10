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
            
            MainView(viewModel: .sampleProducts)
            
            if let loginViewModel = viewModel.login {
                
                NavigationView {
                    
                    AuthLoginView(viewModel: loginViewModel)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        RootView(viewModel: .init(.emptyMock))
    }
}
