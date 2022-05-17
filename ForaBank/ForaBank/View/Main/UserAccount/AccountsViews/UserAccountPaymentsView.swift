//
//  UserAccountPaymentsView.swift
//  ForaBank
//
//  Created by Mikhail on 22.04.2022.
//

import SwiftUI

extension UserAccountPaymentsView {
    
    class ViewModel: UserAccountViewModel.AccountSectionCollapsableViewModel {
        
        override var type: UserAccountViewModel.AccountSectionType { .payments }
        var items: [AccountCellDefaultViewModel]
        
        internal init(items: [AccountCellDefaultViewModel], isCollapsed: Bool) {
            
            self.items = items
            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - View

struct UserAccountPaymentsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            VStack(spacing: 4) {
                
                ForEach(viewModel.items) { itemViewModel in
                    
                    if let viewModel = itemViewModel as? AccountCellButtonView.ViewModel {
                        AccountCellButtonView(viewModel: viewModel)
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct UserAccountPaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountPaymentsView(viewModel: .payments)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension UserAccountPaymentsView.ViewModel {
    
    static let payments = UserAccountPaymentsView.ViewModel(
        items: [AccountCellButtonView.ViewModel.paymentSPF],
        isCollapsed: false)
    
}
