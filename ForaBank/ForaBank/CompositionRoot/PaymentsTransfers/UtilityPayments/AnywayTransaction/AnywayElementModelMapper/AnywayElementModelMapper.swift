//
//  AnywayElementModelMapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain
import ForaTools
import PaymentComponents
import SwiftUI

final class AnywayElementModelMapper {
    
    private let currencyOfProduct: CurrencyOfProduct
    private let format: Format
    private let getProducts: GetProducts
    private let settings: Settings
    
    init(
        currencyOfProduct: @escaping CurrencyOfProduct,
        format: @escaping Format,
        getProducts: @escaping GetProducts,
        flag: StubbedFeatureFlag.Option
    ) {
        self.currencyOfProduct = currencyOfProduct
        self.format = format
        self.getProducts = getProducts
        self.settings = flag == .stub ? .test : .default
    }
    
    typealias Currency = String
    typealias Format = (Currency?, Decimal) -> String
    typealias CurrencyOfProduct = (ProductSelect.Product) -> String
    typealias GetProducts = () -> [ProductSelect.Product]
    
    struct Settings: Equatable {
        
        let timerDuration: Int
        let otpLength: Int
        
        static let `default`: Self = .init(timerDuration: 60, otpLength: 6)
        static let test: Self = .init(timerDuration: 6, otpLength: 6)
    }
}

extension AnywayElementModelMapper {
    
    func map(
        _ element: AnywayElement,
        _ event: @escaping (NotifyEvent) -> Void
    ) -> AnywayElementModel {
        
        switch (element, element.uiComponent) {
        case let (_, .field(field)):
            return .field(field)
            
        case let (_, .parameter(parameter)):
            return makeParameterViewModel(
                with: parameter,
                event: { event(.payment($0)) }
            )
            
        case let (.widget(widget), _):
            return makeWidgetViewModel(with: widget, event: event)
            
        default:
            fatalError("impossible case; would be removed on change to models")
        }
    }
    
    typealias NotifyEvent = AnywayTransactionViewModel.NotifyEvent
}

private extension AnywayElementModelMapper {
    
    func makeParameterViewModel(
        with parameter: AnywayElement.Parameter,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> AnywayElementModel {
        
        switch parameter.uiComponent.type {
        case .hidden:
            return .parameter(.init(
                origin: parameter.uiComponent,
                type: .hidden
            ))
            
        case .nonEditable:
            return .parameter(.init(
                origin: parameter.uiComponent,
                type: .nonEditable
            ))
            
        case .numberInput:
            return .parameter(.init(
                origin: parameter.uiComponent,
                type: .numberInput(makeInputViewModel(with: parameter, event: event))
            ))
            
        case let .select(option, options):
            let model = makeSelectorViewModel(
                initialState: .init(
                    items: options,
                    filteredItems: options,
                    selected: option
                ),
                and: parameter.uiComponent,
                event: event
            )
            return .parameter(.init(
                origin: parameter.uiComponent,
                type: .select(model)
            ))
            
        case .textInput:
            return .parameter(.init(
                origin: parameter.uiComponent,
                type: .textInput(makeInputViewModel(with: parameter, event: event))
            ))
            
        case .unknown:
            return .parameter(.init(
                origin: parameter.uiComponent,
                type: .unknown
            ))
        }
    }
}

private extension AnywayElementModelMapper {
    
    func makeWidgetViewModel(
        with widget: AnywayElement.Widget,
        event: @escaping (NotifyEvent) -> Void
    ) -> AnywayElementModel {
        
        switch widget {
        case let .info(info):
            return .widget(.info(makeInfoViewModel(info)))
            
            // initially there could be no OTP warning, so it's safe to ignore it
        case let .otp(otp, _):
            return .widget(.otp(makeOTPViewModel(otp: otp, event: event)))
            
        case let .product(product):
            return .widget(.product(makeProductSelectViewModel(with: product, event: { event(.payment($0)) })))
        }
    }
    
#warning("event here is too wide, contain to widget")
    private func makeProductSelectViewModel(
        with core: AnywayElement.Widget.Product,
        event: @escaping (AnywayPaymentEvent) -> Void
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
    
    private func makeInfoViewModel(
        _ info: AnywayElement.Widget.Info
    ) -> AnywayElementModel.Widget.Info {
        
        return .init(
            fields: info.fields.map {
                
                return .init($0, currencySymbol: info.currency, format: format)
            }
        )
    }
    
    private func makeOTPViewModel(
        otp: Int?,
        event: @escaping (NotifyEvent) -> Void
    ) -> AnywayElementModel.Widget.OTPViewModel {
        
        return .init(
            otpText: otp.map { "\($0)" } ?? "",
            timerDuration: settings.timerDuration,
            otpLength: settings.otpLength,
            resend: { event(.getVerificationCode) },
            observe: { event(.payment(.widget(.otp($0)))) }
        )
    }

    #warning("event here is too wide, contain to widget")
    private func makeSimpleOTPViewModel(
        with otp: Int?,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> AnywayElementModel.Widget.SimpleOTPViewModel {
        
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
            observe: { event(.widget(.otp($0.value.map { "\($0)" } ?? ""))) }
        )
    }
}

// MARK: - Adapters

private extension TimedOTPInputViewModel {
    
    convenience init(
        otpText: String,
        timerDuration: Int,
        otpLength: Int,
        timer: any TimerProtocol = RealTimer(),
        resend: @escaping () -> Void,
        observe: @escaping Observe = { _ in },
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let countdownReducer = CountdownReducer(duration: timerDuration)
        let decorated: OTPInputReducer.CountdownReduce = { state, event in
            
            if case (.completed, .start) = (state, event) {
                resend()
            }
            
            return countdownReducer.reduce(state, event)
        }
        
        let otpFieldReducer = OTPFieldReducer(length: otpLength)
        let decoratedOTPFieldReduce: OTPInputReducer.OTPFieldReduce = { state, event in
            
            switch event {
            case let .edit(text):
                let text = text.digits.prefix(otpLength)
                return otpFieldReducer.reduce(state, .edit(.init(text)))
                
            default:
                return otpFieldReducer.reduce(state, event)
            }
        }
        let otpInputReducer = OTPComponentInputReducer(
            countdownReduce: decorated,
            otpFieldReduce : decoratedOTPFieldReduce
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: { _ in })
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: { _,_ in })
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))

        self.init(
            initialState: .starting(
                phoneNumber: "",
                duration: timerDuration,
                text: otpText
            ),
            reduce: otpInputReducer.reduce(_:_:),
            handleEffect: otpInputEffectHandler.handleEffect(_:_:),
            timer: timer,
            observe: observe,
            scheduler: scheduler
        )
    }
}

private extension InputState where Icon == AnywayElement.UIComponent.Icon? {
    
    init(_ parameter: Parameter) {
        
        self.init(
            dynamic: .init(
                value: parameter.uiComponent.value ?? "",
                warning: nil
            ),
            settings: .init(
                hint: parameter.uiComponent.subtitle,
                icon: parameter.uiComponent.icon,
                keyboard: .default,
                title: parameter.uiComponent.title,
                subtitle: parameter.uiComponent.subtitle,
                regExp: parameter.validation.regExp,
                limit: parameter.validation.maxLength ?? 255
            )
        )
    }
    
    typealias Parameter = AnywayPaymentDomain.AnywayElement.Parameter
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

private extension SelectState {
    
    var selected: Option? {
        
        switch self {
        case let .collapsed(selected, _):  return selected
        case let .expanded(selected, _,_): return selected
        }
    }
    
    init(_ selector: Selector<AnywayElementOption>) {

        let selectOption = selector.selectedOption
        let options = selector.selectStataOptions

        if selector.isShowingOptions {
            self = .expanded(
                selectOption: selectOption,
                options: options,
                searchText: selector.searchQuery
            )
        } else {
            self = .collapsed(
                option: selectOption,
                options: options
            )
        }
    }
    
    typealias AnywayElementOption = AnywayElement.UIComponent.Parameter.ParameterType.Option
}

private extension Selector<AnywayElement.UIComponent.Parameter.ParameterType.Option> {
    
    var selectedOption: SelectState.Option {
        
        return .init(id: selected.key, title: selected.value, isSelected: true)
    }
    
    var selectStataOptions: [SelectState.Option] {
        
        options.map {
            
            return .init(id: $0.key, title: $0.value, isSelected: $0 == self.selected)
        }
    }
}

private extension ProductSelect {
    
    var _productType: AnywayPaymentEvent.Widget.ProductType? {
        
        switch selected?.productType {
        case .card:    return .card
        case .account: return .account
        default:       return nil
        }
    }
}

private extension AnywayElementModel.Widget.Info.Field {
    
    init(
        _ field: AnywayElement.Widget.Info.Field,
        currencySymbol: CurrencySymbol?,
        format: @escaping (CurrencySymbol?, Decimal) -> String
    ) {
        switch field {
        case let .amount(amount):
            self = .amount(format(currencySymbol, amount))
            
        case let .fee(fee):
            self = .fee(format(currencySymbol, fee))
            
        case let .total(total):
            self = .total(format(currencySymbol, total))
            
        }
    }
    
    typealias CurrencySymbol = String
}

// MARK: - Helpers

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
