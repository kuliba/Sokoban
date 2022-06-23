//
//  UserAccountView.swift
//  ForaBank
//
//  Created by Mikhail on 18.04.2022.
//

import SwiftUI
import Introspect

struct UserAccountView: View {
    
    @ObservedObject var viewModel: UserAccountViewModel
    
    @State private var tabBarController: UITabBarController?
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 20) {
                
                avatarView
                
                ForEach(viewModel.sections) { section in
                    
                    switch section {
                        
                    case let sectionViewModel as UserAccountContactsView.ViewModel:
                        UserAccountContactsView(viewModel: sectionViewModel)
                        
                    case let sectionViewModel as UserAccountPaymentsView.ViewModel:
                        UserAccountPaymentsView(viewModel: sectionViewModel)
                        
                    case let sectionViewModel as UserAccountSecurityView.ViewModel:
                        UserAccountSecurityView(viewModel: sectionViewModel)
                        
                    case let sectionViewModel as UserAccountDocumentsView.ViewModel:
                        UserAccountDocumentsView(viewModel: sectionViewModel)
                        
                    default:
                        EmptyView()
                    }
                    
                }
                
                if let button = viewModel.exitButton {
                    AccountCellFullButtonView(viewModel: button)
                        .padding(.horizontal, 20)
                }
            }
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case .userDocument(let userDocumentViewModel):
                        UserDocumentView(viewModel: userDocumentViewModel)
                        
                    case let .fastPaymentSettings(meToMeSettingsViewModel):
                        MeToMeSettingView(viewModel: meToMeSettingsViewModel)
                    }
                }
            }
        }
        .sheet(item: $viewModel.sheet, content: { sheet in
            switch sheet.sheetType {
                
            case let .userDocument(userDocumentViewModel):
                UserDocumentView(viewModel: userDocumentViewModel)
                
            }
        })
        .bottomSheet(item: $viewModel.bottomSheet, content: { sheet in
            switch sheet.sheetType {
                
            case let .inn(model):
                UserAccountDocumentInfoView(viewModel: model)
                
            }
        })
        .navigationBar(with: viewModel.navigationBar)
        .introspectTabBarController(customize: { tabBarController in
            
            self.tabBarController = tabBarController
            tabBarController.tabBar.isHidden = true
//            UIView.transition(with: tabBarController.view, duration: 0.05, options: .transitionCrossDissolve, animations: nil)
        })
        .onDisappear {
            
            if let tabBarController = tabBarController {
                
                tabBarController.tabBar.isHidden = false
//                UIView.transition(with: tabBarController.view, duration: 0.05, options: .transitionCrossDissolve, animations: nil)
            }
            
        }
    }
    
    var avatarView: some View {
        
        ZStack {
            
            if let avatar = viewModel.avatar {
                
                if let avatarImage = avatar.image {
                    
                    avatarImage
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 96, height: 96)
                        .overlay(Circle()
                            .stroke(lineWidth: 0)
                        )
                    
                } else {
                    
                    //Avatar Placeholder
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 96, height: 96)
                    
                    Image.ic24User
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.iconGray)
                }
                
                Button(action: avatar.action) {
                    
                    ZStack {
                        
                        Circle()
                            .foregroundColor(.iconBlack)
                            .frame(width: 32, height: 32)
                        
                        Image.ic16Edit2
                            .foregroundColor(.iconWhite)
                    }
                }
                .offset(x: 32, y: -32)
            }
        }
    }
}

struct UserAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountView(viewModel: .sample)
    }
}

extension UserAccountViewModel {
    
    static let sample = UserAccountViewModel(
        navigationBar: .sample,
        avatar: .init(
            image: Image("imgMainBanner2"),
            //image: nil,
            action: {
                print("Open peacker")
            }),
        sections:
            [UserAccountContactsView.ViewModel.contact,
             UserAccountDocumentsView.ViewModel.documents,
             UserAccountPaymentsView.ViewModel.payments,
             UserAccountSecurityView.ViewModel.security
            ],
        exitButton: .init(
            icon: .ic24LogOut,
            content: "Выход из приложения",
            action: {
                print("Exit action")
            })
    )
}
