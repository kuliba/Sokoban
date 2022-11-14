//
//  ContactsSectionCollapsableViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import Combine
import SwiftUI

class ContactsSectionCollapsableViewModel: ContactsSectionViewModel, ObservableObject {

    @Published var header: ContactsSectionHeaderView.ViewModel
    @Published var isCollapsed: Bool

    init(header: ContactsSectionHeaderView.ViewModel, isCollapsed: Bool = false, mode: Mode, model: Model) {
        
        self.isCollapsed = isCollapsed
        self.header = header
        super.init(model: model, mode: mode)
        
        bind()
    }
    
    func bind() {
        
        header.$isCollapsed
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCollapsed in
                
                withAnimation {
                    
                    self?.isCollapsed.toggle()
                }

            }.store(in: &bindings)
    }
}

//MARK: - Action

extension ContactsSectionViewModelAction {
    
    enum Collapsable {
        
        struct SearchDidTapped: Action {}
    }
}
