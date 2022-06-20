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
        
        let faceId = AccountCellSwitchView.ViewModel(
            content: "Вход по Face ID",
            icon: .ic24FaceId)
        
        let push = AccountCellSwitchView.ViewModel(
            content: "Push-уведомления",
            icon: .ic24Bell)
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(items: [AccountCellDefaultViewModel], isCollapsed: Bool) {
            
            self.items = items
            super.init(isCollapsed: isCollapsed)
        }
        
        internal override init(isCollapsed: Bool) {
            
            self.items = [faceId, push]
            super.init(isCollapsed: isCollapsed)
            bind()
        }
        
        func bind() {
            
            faceId.$isActive
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isActive in
                    action.send(UserAccountModelAction.FaceIdSwitch(value: isActive))
                    
                }.store(in: &bindings)
            
            push.$isActive
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isActive in
                    action.send(UserAccountModelAction.NotificationSwitch(value: isActive))
                    
                }.store(in: &bindings)
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
