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
        
        internal override init(isCollapsed: Bool) {
            
            self.items = []
            super.init(isCollapsed: isCollapsed)
            
            self.items = [AccountCellButtonView.ViewModel(
                icon: Image("sbp-logo"),
                content: "Система быстрых платежей",
                button: .init(icon: .ic24ChevronRight, action: { [weak self] in
                    self?.action.send(UserAccountModelAction.OpenFastPayment())
                }))]
        }
    }
}

//MARK: - View

struct UserAccountPaymentsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            VStack(spacing: 4) {
                
                ForEach(viewModel.items) { itemViewModel in
                    
                    if let viewModel = itemViewModel as? AccountCellButtonView.ViewModel {
                        AccountCellButtonView(viewModel: viewModel)
                    }
                }
            }.padding(.horizontal, 20)
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
