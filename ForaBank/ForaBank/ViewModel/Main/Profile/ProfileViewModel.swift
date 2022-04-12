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
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var productViewModel: ProfileCardViewComponent.ViewModel
    @Published var buttonsViewModel: ProfileButtonsSectionView.ViewModel
    @Published var detailAccountViewModel: DetailAccountViewComponent.ViewModel?
    @Published var historyViewModel: HistoryViewComponent.ViewModel?
    
    private var bindings = Set<AnyCancellable>()
    private let model: Model
    
    internal init(productViewModel: ProfileCardViewComponent.ViewModel, historyViewModel: HistoryViewComponent.ViewModel?, model: Model = .emptyMock) {
        
        self.model = model
        self.productViewModel = productViewModel
        
        self.detailAccountViewModel = nil
        
        self.buttonsViewModel = .init(kind: productViewModel.product.productType, debit: true, credit: true)
        
        if productViewModel.product.productType == .loan {
            
            self.detailAccountViewModel = nil
        }
        
        self.historyViewModel = historyViewModel
        
        bind()
    }
}

//MARK: - Bindings

private extension ProfileViewModel {
    
    func bind() {
        
        model.products
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] products in
                withAnimation {
                    print(products)
                }
            }.store(in: &bindings)
    }
}
