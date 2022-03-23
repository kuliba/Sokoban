//
//  ProfileViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import Foundation

class ProfileViewModel: ObservableObject {
    
    @Published var productViewModel: ProfileCardViewComponent.ViewModel
    @Published var buttonsViewModel: ProfileButtonsSectionView.ViewModel
    @Published var historyViewModel: HistoryViewComponent.ViewModel
    
    init(productViewModel: ProfileCardViewComponent.ViewModel, buttonsViewModel: ProfileButtonsSectionView.ViewModel, historyViewModel: HistoryViewComponent.ViewModel) {
        
        self.productViewModel = productViewModel
        self.buttonsViewModel = buttonsViewModel
        self.historyViewModel = historyViewModel
    }
}
