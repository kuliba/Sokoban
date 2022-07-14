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
        
        ZStack(alignment: .top) {
            
            TabView(selection: $viewModel.selected) {
                
                NavigationView {
                    
                    MainView(viewModel: viewModel.mainViewModel)
                }
                .tabItem {
                    
                    tabIcon(type: .main, selected: viewModel.selected)
                    Text(RootViewModel.TabType.main.name)
                        .foregroundColor(.black)
                }
                .tag(RootViewModel.TabType.main)
                
                NavigationView {
                    
                    PaymentsTransfersView(viewModel: viewModel.paymentsViewModel)
                }
                .tabItem {
                    
                    tabIcon(type: .payments, selected: viewModel.selected)
                    Text(RootViewModel.TabType.payments.name)
                        .foregroundColor(.black)
                }
                .tag(RootViewModel.TabType.payments)
                
                ChatView(viewModel: viewModel.chatViewModel)
                    .tabItem {
                        
                        tabIcon(type: .chat, selected: viewModel.selected)
                        Text(RootViewModel.TabType.chat.name)
                            .foregroundColor(.black)
                    }
                    .tag(RootViewModel.TabType.chat)
                
            }.accentColor(.black)
            
            InformerView(viewModel: viewModel.informerViewModel)
                .zIndex(1)
                .padding(.top, 64)
            
        }.alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
    }
}

extension RootView {
    
    private func tabIcon(type: RootViewModel.TabType, selected: RootViewModel.TabType) -> AnyView {
        
        if type == selected {
            
            switch type {
            case .main:
                return AnyView(
                    Image.ic24LogoForaColor
                        .renderingMode(.original)
                )
                
            case .payments:
                return AnyView(
                    Image.ic24PaymentsActive
                        .renderingMode(.original)
                )
                
            case .history:
                return AnyView(
                    Image.ic24HistoryActive
                        .renderingMode(.original)
                )
                
            case .chat:
                return AnyView(
                    Image.ic24ChatActive
                        .renderingMode(.original)
                )
            }
            
        } else {
            
            switch type {
            case .main:
                return AnyView(
                    Image.ic24LogoForaLine
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                )
                
            case .payments:
                return AnyView(
                    Image.ic24PaymentsInactive
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                )
                
            case .history:
                return AnyView(
                    Image.ic24HistoryInactive
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                )
                
            case .chat:
                return AnyView(
                    Image.ic24ChatInactive
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                )
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        RootView(viewModel: .init(.emptyMock))
    }
}
