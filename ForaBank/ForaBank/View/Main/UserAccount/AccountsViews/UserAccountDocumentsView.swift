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
    
        internal init(userData: ClientInfoData, isCollapsed: Bool) {
            
            self.items = []
            super.init(isCollapsed: isCollapsed)
            
            self.items = createItems(from: userData)
        }
        
        func createItems(from userData: ClientInfoData) -> [AccountCellDefaultViewModel] {
            
            var accountDocuments: [AccountCellDefaultViewModel] = [
                DocumentCellView.ViewModel(
                    itemType: .passport,
                    content: userData.pasportNumber.addMask(for: .passport),
                    action: { [weak self] in
                        self?.action.send(UserAccountViewModelAction.OpenDocument(type: .passport))
                    })
            ]
            
            if let userInn = userData.INN {
                accountDocuments.append(DocumentCellView.ViewModel(
                    itemType: .inn,
                    content: userInn.addMask(for: .inn),
                    action: { [weak self] in
                        self?.action.send(UserAccountViewModelAction.OpenDocument(type: .inn))
                    })
                )
            }
            
            accountDocuments.append(DocumentCellView.ViewModel(
                itemType: .adressPass,
                content: userData.address.addMask(for: .adressPass),
                action: { [weak self] in
                    self?.action.send(UserAccountViewModelAction.OpenDocument(type: .adressPass))
                })
            )
            
            if let addressResidential = userData.addressResidential {
                accountDocuments.append(DocumentCellView.ViewModel(
                    itemType: .adress,
                    content: addressResidential.addMask(for: .adress),
                    action: { [weak self] in
                        self?.action.send(UserAccountViewModelAction.OpenDocument(type: .adress))
                    })
                )
            }
            return accountDocuments
        }
    }
}

private extension String {
    
    func addMask(for type: DocumentCellType) -> String {
        switch type {
        case .passport:
            return String(self.prefix(4)) + "****" + String(self.suffix(2))
            
        case .inn:
            
            return String(self.prefix(4)) + "****" + String(self.suffix(4))
            
        default:
            return self
        }
    }
}

//MARK: - View

struct UserAccountDocumentsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {
                    
                    ForEach(viewModel.items) { itemViewModel in
                        if let viewModel = itemViewModel as? DocumentCellView.ViewModel {
                            
                            DocumentCellView(viewModel: viewModel)
                        }
                    }
                }.padding(.horizontal, 20)
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
