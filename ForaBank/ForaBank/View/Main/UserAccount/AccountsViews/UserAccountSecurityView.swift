//
//  UserAccountSecurityView.swift
//  ForaBank
//
//  Created by Mikhail on 22.04.2022.
//

import SwiftUI
import Combine

extension UserAccountSecurityView {
    
    class ViewModel: UserAccountViewModel.AccountSectionCollapsableViewModel {
        
        override var type: UserAccountViewModel.AccountSectionType { .security }
        var items: [AccountCellDefaultViewModel]
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(items: [AccountCellDefaultViewModel], isCollapsed: Bool) {
            
            self.items = items
            super.init(isCollapsed: isCollapsed)
        }
        
        internal init(isActiveFaceId: Bool, isActivePush: Bool, isCollapsed: Bool) {
            
            let items = [
                //TODO: - Временно убран Switch FaceId
//                AccountCellSwitchView.ViewModel(type: .faceId, isActive: isActiveFaceId),
                AccountCellSwitchView.ViewModel(type: .notification, isActive: isActivePush)]
            self.items = items
            super.init(isCollapsed: isCollapsed)
            bind(items)
        }
        
        func bind(_ items: [AccountCellSwitchView.ViewModel]) {
            
            for item in items {
                
                item.$isActive
                    .dropFirst()
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] isActive in
                        action.send(UserAccountViewModelAction.Switch(type: item.type, value: isActive))
                    }.store(in: &bindings)
                
            }
        }
    }
}

//MARK: - View

struct UserAccountSecurityView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            VStack(spacing: 4) {
                
                ForEach(viewModel.items) { itemViewModel in
                    
                    if let viewModel = itemViewModel as? AccountCellSwitchView.ViewModel {
                        AccountCellSwitchView(viewModel: viewModel)
                    }
                }
            }.padding(.horizontal, 20)
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
