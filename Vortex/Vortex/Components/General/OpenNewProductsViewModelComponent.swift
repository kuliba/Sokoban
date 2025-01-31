//
//  OpenNewProductsViewModel.swift
//  Vortex
//
//  Created by Dmitry Martynov on 02.11.2022.
//

import Foundation
import SwiftUI
import Combine

class OpenNewProductsViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var items: [NewProductButton.ViewModel]
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
        
    init(items: [NewProductButton.ViewModel], model: Model = .emptyMock) {
        
        self.items = items
        self.model = model
    }
    
    typealias NewProductAction = (OpenProductType) -> Void
    typealias MakeNewProductButtons = (@escaping NewProductAction) -> [NewProductButton.ViewModel]
    
    init(
        _ model: Model,
        makeOpenNewProductButtons: @escaping MakeNewProductButtons
    ) {
        self.items = []
        self.model = model
        
        self.items = makeOpenNewProductButtons { [weak self] productType in
            
            let action = OpenNewProductsViewModelAction.Tapped.NewProduct(productType: productType)
            self?.action.send(action)
        }
        
        bind()
    }
    
    func bind() {
        
        model.deposits
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] deposits in
                
                guard let deposit = self.items.first(where: { $0.id == ProductType.deposit.rawValue})
                else { return }
                
                deposit.subTitle = depositDescription(with: deposits)
                
            }.store(in: &bindings)
    }
    
    private func depositDescription(with deposits: [DepositProductData]) -> String {
        
        guard let maxRate = deposits.map({ $0.generalСondition.maxRate }).max(),
              let maxRateString = NumberFormatter.persent.string(from: NSNumber(value: maxRate / 100))
        else { return "..." }
        
        return "\(maxRateString)"
    }
    
}

enum OpenNewProductsViewModelAction {
    
    enum Tapped {
        
        struct NewProduct: Action {
            
            let productType: OpenProductType
        }
    }
}
