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
    @Published var historyViewModel: HistoryViewComponent.ViewModel
    
    private var bindings = Set<AnyCancellable>()
    private let model: Model
    
    internal init(productViewModel: ProfileCardViewComponent.ViewModel, buttonsViewModel: ProfileButtonsSectionView.ViewModel, detailAccountViewModel: DetailAccountViewComponent.ViewModel?, historyViewModel: HistoryViewComponent.ViewModel, model: Model) {
        
        self.model = model
        self.productViewModel = productViewModel
        self.buttonsViewModel = buttonsViewModel
        self.detailAccountViewModel = detailAccountViewModel
        self.historyViewModel = historyViewModel
        
        model.action.send(ModelAction.Products.Update.Total.Single.Request.init(productType: .card))
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
