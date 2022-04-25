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
    }
}

//MARK: - View

struct UserAccountContactsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        MainSectionCollapsableView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
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
            }
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
