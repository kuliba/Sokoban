//
//  UserAccountSecurityView.swift
//  ForaBank
//
//  Created by Mikhail on 22.04.2022.
//

import SwiftUI

extension UserAccountSecurityView {
    
    class ViewModel: UserAccountViewModel.AccountSectionCollapsableViewModel {
        
        override var type: UserAccountViewModel.AccountSectionType { .security }
        var items: [AccountCellDefaultViewModel]
        
        internal init(items: [AccountCellDefaultViewModel], isCollapsed: Bool) {
            
            self.items = items
            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - View

struct UserAccountSecurityView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        MainSectionCollapsableView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            VStack(spacing: 4) {
                
                ForEach(viewModel.items) { itemViewModel in
                    
                    if let viewModel = itemViewModel as? AccountCellSwitchView.ViewModel {
                        AccountCellSwitchView(viewModel: viewModel)
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct UserAccountSecurityView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountSecurityView(viewModel: .security)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}

//MARK: - Preview Content

extension UserAccountSecurityView.ViewModel {
    
    static let security = UserAccountSecurityView.ViewModel(
        items: [AccountCellSwitchView.ViewModel.appleId, AccountCellSwitchView.ViewModel.push],
        isCollapsed: false)
    
}
