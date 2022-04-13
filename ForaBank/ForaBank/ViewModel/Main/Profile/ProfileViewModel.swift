//
//  ProfileViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import Foundation
import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    @Published var productViewModel: ProfileCardViewComponent.ViewModel
    @Published var buttonsViewModel: ProfileButtonsSectionView.ViewModel
    @Published var detailAccountViewModel: DetailAccountViewComponent.ViewModel?
    @Published var historyViewModel: HistoryViewComponent.ViewModel?
    
    private let model: Model
    
    internal init(productViewModel: ProfileCardViewComponent.ViewModel, model: Model = .emptyMock) {
        
        self.productViewModel = productViewModel
        
        self.detailAccountViewModel = nil
        
        self.buttonsViewModel = .init(kind: productViewModel.product.productType)
        
        if productViewModel.product.productType == .loan {
            
            self.detailAccountViewModel = nil
        }
        
        self.model = model
    }
}
