//
//  AnywayElementModelMapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain
import PaymentComponents

final class AnywayElementModelMapper {
    
    private let event: (Event) -> Void
    private let currencyOfProduct: CurrencyOfProduct
    private let getProducts: GetProducts
    
    init(
        event: @escaping (Event) -> Void,
        currencyOfProduct: @escaping CurrencyOfProduct,
        getProducts: @escaping GetProducts
    ) {
        self.event = event
        self.currencyOfProduct = currencyOfProduct
        self.getProducts = getProducts
    }
    
    typealias Event = AnywayPaymentEvent
    typealias CurrencyOfProduct = (ProductSelect.Product) -> String
    typealias GetProducts = () -> [ProductSelect.Product]
}

extension AnywayElementModelMapper {
    
    func map(
        _ element: AnywayElement
    ) -> AnywayElementModel {
        
        switch (element, element.uiComponent) {
        case let (_, .field(field)):
            return .field(field)
            
        case let (_, .parameter(parameter)):
            return .parameter(parameter)
            
        case let (.widget(widget), _):
            switch widget {
            case let .core(core):
                return .widget(.core(makeProductSelectViewModel(with: core), core.amount, core.currency.rawValue))
                
            case let .otp(otp):
                return .widget(.otp(makeModelForOTP(with: otp)))
            }
            
        default:
            fatalError("impossible case; would be removed on change to models")
        }
    }
}

private extension AnywayElementModelMapper {
    
#warning("extract?")
    func makeProductSelectViewModel(
        with core: AnywayElement.Widget.PaymentCore
    ) -> ObservingProductSelectViewModel {
        
        let products = getProducts()
        let selected = products.first { $0.isMatching(core.productID) }
        let initialState = ProductSelect(selected: selected)
        
        let reducer = ProductSelectReducer(getProducts: getProducts)
        
        return .init(
            initialState: initialState,
            reduce: { (reducer.reduce($0, $1), nil) },
            handleEffect: { _,_ in },
            observe: { [weak self] in
                
                guard let self else { return }
                
                guard let productID = $0.selected?.coreProductID,
                      let currency = $0.selected.map({ self.currencyOfProduct($0) })
                else { return }
                
                event(.widget(.product(productID, .init(currency))))
            }
        )
    }
}

private extension AnywayElementModelMapper {
    
#warning("extract?")
    func makeModelForOTP(
        with otp: Int?
    ) -> AnywayElementModel.Widget.OTPViewModel {
        
        return .init(
            initialState: .init(value: otp),
            reduce: { _, event in
                
                switch event {
                case let .input(input):
                    let digits = input.filter(\.isWholeNumber).prefix(6)
                    return (.init(value: Int(digits)), nil)
                }
            },
            handleEffect: { _,_ in },
            observe: { [weak self] in
                
                self?.event(.widget(.otp($0.value.map { "\($0)" } ?? "")))
            }
        )
    }
}

// MARK: - Helpers

private extension ProductSelect.Product {
    
    func isMatching(
        _ productID: AnywayPaymentDomain.AnywayElement.Widget.PaymentCore.ProductID
    ) -> Bool {
        
        switch productID {
        case let .accountID(accountID):
            return type == .account && id.rawValue == accountID.rawValue
            
        case let .cardID(cardID):
            return type == .card && id.rawValue == cardID.rawValue
        }
    }
    
    var coreProductID: AnywayPaymentDomain.AnywayElement.Widget.PaymentCore.ProductID {
        
        switch type {
        case .account:
            return .accountID(.init(id.rawValue))
            
        case .card:
            return .cardID(.init(id.rawValue))
        }
    }
}
