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
            return makeParameterViewModel(with: parameter)
            
        case let (.widget(widget), _):
            return makeWidgetViewModel(with: widget)
            
        default:
            fatalError("impossible case; would be removed on change to models")
        }
    }
}

private extension AnywayElementModelMapper {
    
    func makeParameterViewModel(
        with parameter: AnywayElement.UIComponent.Parameter
    ) -> AnywayElementModel {
        
        switch parameter.type {
        case .hidden:
            return .parameter(.hidden(parameter))
            
        case .nonEditable:
            return .parameter(.nonEditable(parameter))
            
        case .numberInput:
#warning("how to add differentiation for numeric input")
            return .parameter(.numberInput(makeInputViewModel(with: parameter)))
            
        case let .select(option, options):
            if let selector = try? Selector(option: option, options: options) {
                return .parameter(.select(makeSelectorViewModel(with: selector, and: parameter)))
            } else {
                return .parameter(.unknown(parameter))
            }
            
        case .textInput:
            return .parameter(.textInput(makeInputViewModel(with: parameter)))
            
        case .unknown:
            return .parameter(.unknown(parameter))
        }
    }
}

private extension AnywayElementModelMapper {
    
#warning("extract?")
    func makeInputViewModel(
        with parameter: AnywayElement.UIComponent.Parameter
    ) -> ObservingInputViewModel {
        
        let inputState = InputState(parameter)
        let reducer = InputReducer<String>()
        
        return .init(
            initialState: inputState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in },
            observe: { [weak self] in
                
                self?.event(.setValue($0.dynamic.value, for: parameter.id))
            }
        )
    }
    
    func makeSelectorViewModel(
        with selector: Selector<Option>,
        and parameter: AnywayElement.UIComponent.Parameter
    ) -> ObservingSelectorViewModel<Option> {
        
        let reducer = SelectorReducer<Option>()
        
        return .init(
            initialState: selector,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in },
            observe: { [weak self] in
                
                self?.event(.setValue($0.selected.key, for: parameter.id))
            }
        )
    }
    
    typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
}

private extension AnywayElementModelMapper {
    
    func makeWidgetViewModel(
        with widget: AnywayElement.Widget
    ) -> AnywayElementModel {
        
        switch widget {
        case let .product(product):
            return .widget(.product(makeProductSelectViewModel(with: product)))
            
        case let .otp(otp):
            return .widget(.otp(makeModelForOTP(with: otp)))
        }
    }
    
#warning("extract?")
    private func makeProductSelectViewModel(
        with core: AnywayElement.Widget.Product
    ) -> ObservingProductSelectViewModel {
        
        let products = getProducts()
        let selected = products.first { $0.isMatching(core) }
        let initialState = ProductSelect(selected: selected)
        
        let reducer = ProductSelectReducer(getProducts: getProducts)
        
        return .init(
            initialState: initialState,
            reduce: { (reducer.reduce($0, $1), nil) },
            handleEffect: { _,_ in },
            observe: { [weak self] in
                
                guard let self else { return }
                
                guard let productID = $0.selected?.id.rawValue,
                      let currency = $0.selected.map({ self.currencyOfProduct($0) }),
                      let productType = $0._productType
                else { return }
                
                event(.widget(.product(productID, productType, currency)))
            }
        )
    }
    
#warning("extract?")
    private func makeModelForOTP(
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

// MARK: - Adapters

private extension InputState where Icon == String {
    
#warning("FIXME: replace stubbed with values from parameter")
    init(_ parameter: AnywayPaymentDomain.AnywayElement.UIComponent.Parameter) {
        
        self.init(
            dynamic: .init(
                value: parameter.value ?? "",
                warning: nil
            ),
            settings: .init(
                hint: nil,
                icon: "",
                keyboard: .default,
                title: parameter.title,
                subtitle: parameter.subtitle
            )
        )
    }
}

private extension Selector where T == AnywayElement.UIComponent.Parameter.ParameterType.Option {
    
    init(option: Option, options: [Option]) throws {
        
        try self.init(
            selected: option,
            options: options,
            filterPredicate: { $0.contains($1) }
        )
    }
    
    typealias Option = AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option
}

private extension AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option {
    
    func contains(_ string: String) -> Bool {
        
        key.contains(string) || value.contains(string)
    }
}

// MARK: - Helpers

private extension ProductSelect {
    
    var _productType: AnywayPaymentEvent.Widget.ProductType? {
        
        switch selected?.productType {
        case .card:    return .card
        case .account: return .account
        default:       return nil
        }
    }
}

private extension ProductSelect.Product {
    
    func isMatching(
        _ product: AnywayPaymentDomain.AnywayElement.Widget.Product
    ) -> Bool {
        
        switch product.productType {
        case .account:
            return type == .account && id.rawValue == product.productID
            
        case .card:
            return type == .card && id.rawValue == product.productID
        }
    }
}
