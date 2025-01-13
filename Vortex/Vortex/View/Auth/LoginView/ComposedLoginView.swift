//
//  ComposedLoginView.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.09.2023.
//

import SwiftUI
import LandingUIComponent

struct ComposedLoginView: View {
    
    @ObservedObject private var viewModel: AuthLoginViewModel
    
    private let authLoginViewModel: AuthLoginViewModel
    
    init(viewModel: ComposedLoginViewModel) {
        
        self.viewModel = viewModel.authLoginViewModel
        self.authLoginViewModel = viewModel.authLoginViewModel
    }
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            loginView()
            Spacer()
            landingButtonsView()
            navLink()
        }
        .padding(.top, 24)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(
            Image.imgRegistrationBg
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    private func loginView() -> some View {
        
        AuthLoginView(viewModel: authLoginViewModel)
    }
    
    private func landingButtonsView() -> some View {
        
        LandingButtonsView(viewModel: authLoginViewModel)
    }
    
    private func navLink() -> some View {
        
        NavigationLink(
            "",
            isActive: .init(
                get: { viewModel.link != nil },
                set: { if !$0 { viewModel.link = nil }}
            )
        ) {
            if let link = viewModel.link  {
                
                switch link {
                case let .confirm(confirmViewModel):
                    AuthConfirmView(viewModel: confirmViewModel)
                                        
                case let .products(productsViewModel):
                    AuthProductsView(viewModel: productsViewModel)
                    
                case let .landing(viewModel):
                    LandingWrapperView(viewModel: viewModel)
                        .navigationBarBackButtonHidden(true)
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct ComposedLoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ComposedLoginView(
            viewModel: .init(
                authLoginViewModel: .preview
            )
        )
    }
}
