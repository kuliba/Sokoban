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
            
            GeometryReader { geo in
                
                TabView(selection: $viewModel.selected) {
                    
                    NavigationView {
                        
                        MainView(viewModel: viewModel.mainViewModel)
                        
                    }
                    .tabItem {
                        
                        tabIcon(type: .main, selected: viewModel.selected)
                        Text(RootViewModel.TabType.main.name)
                            .foregroundColor(.black)
                            .accessibilityIdentifier("tabBarMainButton")
                    }
                    .tag(RootViewModel.TabType.main)
                    
                    NavigationView {
                        
                        PaymentsTransfersView(viewModel: viewModel.paymentsViewModel)
                    }
                    .tabItem {
                        
                        tabIcon(type: .payments, selected: viewModel.selected)
                        Text(RootViewModel.TabType.payments.name)
                            .foregroundColor(.black)
                            .accessibilityIdentifier("tabBarTransferButton")
                    }
                    .tag(RootViewModel.TabType.payments)
                    
                    ChatView(viewModel: viewModel.chatViewModel)
                        .tabItem {
                            
                            tabIcon(type: .chat, selected: viewModel.selected)
                            Text(RootViewModel.TabType.chat.name)
                                .foregroundColor(.black)
                                .accessibilityIdentifier("tabBarChatButton")
                        }
                        .tag(RootViewModel.TabType.chat)
                    
                } //tabView
                .accentColor(.black)
                .accessibilityIdentifier("tabBar")
                .environment(\.mainWindowSize, geo.size)
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case .messages(let messagesHistoryViewModel):
                        MessagesHistoryView(viewModel: messagesHistoryViewModel)
                            .zIndex(.greatestFiniteMagnitude)
                        
                    case .me2me(let requestMeToMeModel):
                        MeToMeRequestView(viewModel: requestMeToMeModel)
                            .zIndex(.greatestFiniteMagnitude)
                        
                    case .c2b(let viewModel):
                        
                        NavigationView {
                            
                            C2BDetailsView(viewModel: viewModel)
                                .navigationBarTitle("", displayMode: .inline)
                                .navigationBarBackButtonHidden(true)
                                .edgesIgnoringSafeArea(.all)
                        }
                        
                    case .userAccount(let viewModel):
                        
                        NavigationView {
                            
                            UserAccountView(viewModel: viewModel)
                        }
                    }
                }
            } //geo
        }
        .alert(item: $viewModel.alert, content: { alertViewModel in
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
