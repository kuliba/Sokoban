//
//  UserAccountContactsView.swift
//  ForaBank
//
//  Created by Mikhail on 21.04.2022.
//

import SwiftUI

extension UserAccountContactsView {
    
    class ViewModel: UserAccountViewModel.AccountSectionCollapsableViewModel {
        
        override var type: UserAccountViewModel.AccountSectionType { .contacts }
        var items: [AccountCellDefaultViewModel]
        
        internal init(items: [AccountCellDefaultViewModel], isCollapsed: Bool) {
            
            self.items = items
            super.init(isCollapsed: isCollapsed)
        }
        
        internal init(userData: ClientInfoData, customName: String?, isCollapsed: Bool) {
            
            let name = customName != nil ? customName! : userData.firstName
            
            self.items = []
            super.init(isCollapsed: isCollapsed)
            
            self.items = [
                AccountCellButtonView.ViewModel(
                    icon: .ic24User,
                    content: name,
                    title: "Имя",
                    button: .init(icon: .ic24Edit2, action: { [weak self] in
                        self?.action.send(UserAccountViewModelAction.ChangeUserName())
                    })
                ),
                
                AccountCellInfoView.ViewModel(
                    icon: .ic24Smartphone,
                    content: userData.phone,
                    title: "Телефон"
                ),
                
                AccountCellInfoView.ViewModel(
                    icon: .ic24Mail,
                    content: userData.email ?? "",
                    title: "Электронная почта"
                )
            ]
        }
    }
}

//MARK: - View

struct UserAccountContactsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            VStack(spacing: 4) {
                
                ForEach(viewModel.items) { itemViewModel in
                    
                    switch itemViewModel {
                        
                    case let model as AccountCellButtonView.ViewModel:
                        AccountCellButtonView(viewModel: model)
                        
                    case let model as AccountCellInfoView.ViewModel:
                        AccountCellInfoView(viewModel: model)
                        
                    default:
                        EmptyView()
                    }
                }
            }.padding(.horizontal, 20)
        }
    }
}

//MARK: - Preview

struct UserAccountContactsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountContactsView(viewModel: .contact)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension UserAccountContactsView.ViewModel {
    
    static let contact = UserAccountContactsView.ViewModel(
        items: [AccountCellButtonView.ViewModel.name,
                AccountCellInfoView.ViewModel.phone,
                AccountCellInfoView.ViewModel.email],
        isCollapsed: false)
    
}
