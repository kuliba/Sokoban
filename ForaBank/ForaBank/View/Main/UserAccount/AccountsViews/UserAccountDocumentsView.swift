//
//  UserAccountDocumentsView.swift
//  ForaBank
//
//  Created by Mikhail on 22.04.2022.
//

import SwiftUI

extension UserAccountDocumentsView {
    
    class ViewModel: UserAccountViewModel.AccountSectionCollapsableViewModel {
        
        override var type: UserAccountViewModel.AccountSectionType { .documents }
        var items: [AccountCellDefaultViewModel]
        
        internal init(items: [AccountCellDefaultViewModel], isCollapsed: Bool) {
            
            self.items = items
            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - View

struct UserAccountDocumentsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {
                    
                    ForEach(viewModel.items) { itemViewModel in
                        if let viewModel = itemViewModel as? DocumentCellView.ViewModel {
                            
                            DocumentCellView(viewModel: viewModel)
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct UserAccountDocumentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountDocumentsView(viewModel: .documents)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension UserAccountDocumentsView.ViewModel {
    
    static let documents = UserAccountDocumentsView.ViewModel(
        items: [DocumentCellView.ViewModel.passport,
                DocumentCellView.ViewModel.inn,
                DocumentCellView.ViewModel.address,
                DocumentCellView.ViewModel.address2],
        isCollapsed: false)
    
}
