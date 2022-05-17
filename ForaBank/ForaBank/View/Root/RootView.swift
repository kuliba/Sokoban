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
        
        TabView(selection: $viewModel.selected) {
            
            NavigationView {
                
                MainView(viewModel: viewModel.mainViewModel)
            }
            .tabItem {
                
                RootViewModel.TabType.main.image(for: viewModel.selected)
                Text(RootViewModel.TabType.main.name)
                    .foregroundColor(.black)
            }
            .tag(RootViewModel.TabType.main)
            
            PaymentsTransfersView(viewModel: viewModel.paymentsViewModel)
                .tabItem {
                    
                    RootViewModel.TabType.payments.image(for: viewModel.selected)
                    Text(RootViewModel.TabType.payments.name)
                        .foregroundColor(.black)
                }
                .tag(RootViewModel.TabType.payments)
            
            Color.white
                .tabItem {
                    
                    RootViewModel.TabType.history.image(for: viewModel.selected)
                    Text(RootViewModel.TabType.history.name)
                        .foregroundColor(.black)
                }
                .tag(RootViewModel.TabType.history)
            
            ChatView(viewModel: viewModel.chatViewModel)
                .tabItem {
                    
                    RootViewModel.TabType.chat.image(for: viewModel.selected)
                    Text(RootViewModel.TabType.chat.name)
                        .foregroundColor(.black)
                }
                .tag(RootViewModel.TabType.chat)
            
        }
        .accentColor(.black)
    }
}

struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        RootView(viewModel: .init(.emptyMock))
    }
}
