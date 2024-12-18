//
//  OpenNewProductsViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 02.11.2022.
//

import Foundation
import SwiftUI
import Combine

class OpenNewProductsViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published
    var items: [NewProductButton.ViewModel]
    
    private let displayButtonsTypes: [ProductType] = [.card, .deposit, .account, .loan]
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    var displayButtons: [String] {
        
        var items = (displayButtonsTypes.map { $0.rawValue } + ["INSURANCE", "MORTGAGE"])
        items.insert(contentsOf: ["STICKER"], at: 3)
        return items
    }
    
    init(items: [NewProductButton.ViewModel], model: Model = .emptyMock) {
        
        self.items = items
        self.model = model
    }
    
    typealias MakeNewProductButtons = ((ProductType) -> Void) -> [NewProductButton.ViewModel]
    
    init(
        _ model: Model,
        makeItems: @escaping MakeNewProductButtons
    ) {
        self.items = []
        self.model = model
        self.items = makeItems { [weak self] in
            
            let action = OpenNewProductsViewModelAction.Tapped.NewProduct(productType: $0)
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

extension ProductType {
    
    var openButtonIcon: Image {
        
        switch self {
        case .card: return .ic24NewCardColor
        case .account: return .ic24FilePluseColor
        case .deposit: return .ic24DepositPlusColor
        case .loan: return .ic24CreditColor
        }
    }
    
    var openButtonTitle: String {
        
        switch self {
        case .card: return "Карту"
        case .account: return "Счет"
        case .deposit: return "Вклад"
        case .loan: return "Кредит"
        }
    }
}

enum OpenNewProductsViewModelAction {
    
    enum Tapped {
        
        struct NewProduct: Action {
            let productType: ProductType
        }
    }
}
