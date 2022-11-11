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
    var items: [ButtonNewProduct.ViewModel]
    
    private let displayButtonsTypes: [ProductType] = [.card, .deposit, .account, .loan]
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    var displayButtons: [String] { displayButtonsTypes.map {$0.rawValue} + ["INSURANCE", "MORTGAGE"] }
    
    init(items: [ButtonNewProduct.ViewModel], model: Model = .emptyMock) {
        
        self.items = items
        self.model = model
    }
    
    init(_ model: Model) {
        
        self.items = []
        self.model = model
        self.items = createItems()
        
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
    
    private func createItems() -> [ButtonNewProduct.ViewModel] {
        
        var viewModel: [ButtonNewProduct.ViewModel] = []
        
        for typeStr in displayButtons {
            
            if let type = ProductType(rawValue: typeStr) {
                
                let id = type.rawValue
                let icon = type.openButtonIcon
                let title = type.openButtonTitle
                let subTitle = description(for: type)
                
                switch type {
                case .loan:
                    viewModel.append(ButtonNewProduct.ViewModel(id: id, icon: icon, title: title,
                        subTitle: subTitle, url: model.productsOpenLoanURL))
                    
                default:
                    viewModel.append(ButtonNewProduct.ViewModel(id: id, icon: icon, title: title,
                        subTitle: subTitle, action: { [weak self] in
                            self?.action.send(OpenNewProductsViewModelAction
                                                .Tapped.NewProduct(productType: type))
                    }))
                }
                
                } else { //no ProductType
                   
                    switch typeStr {
                    case "INSURANCE":
                        viewModel.append(ButtonNewProduct.ViewModel(id: typeStr, icon: .ic24InsuranceColor, title: "Страховку", subTitle: "Надежно", url: model.productsOpenInsuranceURL))
                        
                    case "MORTGAGE":
                        viewModel.append(ButtonNewProduct.ViewModel(id: typeStr, icon: .ic24Mortgage, title: "Ипотеку", subTitle: "Удобно", url: model.productsOpenMortgageURL))
                        
                    default: break
                    }
                } //if
        } //for
        
        return viewModel
    }
    
    private func description(for type: ProductType) -> String {
        
        switch type {
        case .card: return "С кэшбэк"
        case .account: return "Бесплатно"
        case .deposit: return depositDescription(with: model.deposits.value)
        case .loan: return "Выгодно"
        }
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
