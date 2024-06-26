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
    private let getProducts: GetProducts
    private let settings: Settings
    
    init(
        currencyOfProduct: @escaping CurrencyOfProduct,
        getProducts: @escaping GetProducts,
        flag: StubbedFeatureFlag.Option
    ) {
        self.currencyOfProduct = currencyOfProduct
        self.getProducts = getProducts
        self.settings = flag == .stub ? .test : .default
    }
    
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
        with parameter: AnywayElement.UIComponent.Parameter,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> AnywayElementModel {
        
        switch parameter.type {
        case .hidden:
            return .parameter(.hidden(parameter))
            
        case .nonEditable:
            return .parameter(.nonEditable(parameter))
            
        case .numberInput:
#warning("how to add differentiation for numeric input")
            return .parameter(.numberInput(makeInputViewModel(with: parameter, event: event)))
            
        case let .select(option, options):
            if let selector = try? Selector(option: option, options: options) {
                return .parameter(.select(makeSelectorViewModel(with: selector, and: parameter, event: event)))
            } else {
                return .parameter(.unknown(parameter))
            }
            
        case .textInput:
            return .parameter(.textInput(makeInputViewModel(with: parameter, event: event)))
            
        case .unknown:
            return .parameter(.unknown(parameter))
        }
    }
}

private extension AnywayElementModelMapper {
    
#warning("extract?")
    func makeInputViewModel(
        with parameter: AnywayElement.UIComponent.Parameter,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> ObservingInputViewModel {
        
        let inputState = InputState(parameter)
        let reducer = InputReducer<String>()
        
        return .init(
            initialState: inputState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in },
            observe: { event(.setValue($0.dynamic.value, for: parameter.id)) }
        )
    }
    
    func makeSelectorViewModel(
        with selector: Selector<Option>,
        and parameter: AnywayElement.UIComponent.Parameter,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> ObservingSelectorViewModel {
        
        let reducer = SelectorReducer<Option>()
        
        return .init(
            initialState: .init(
                title: parameter.title,
                image: parameter.image,
                selector: selector
            ),
            reduce: { state, event in
            
                let (selector, effect) = reducer.reduce(state.selector, event)
                return (.init(title: state.title, image: state.image, selector: selector), effect)
            },
            handleEffect: { _,_ in },
            observe: { event(.setValue($0.selector.selected.key, for: parameter.id)) }
        )
    }
    
    func makeSelectorViewModel(
        with selector: Selector<Option>,
        and parameter: AnywayElement.UIComponent.Parameter,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> ObservingSelectViewModel {
        
        let reducer = SelectReducer()
        
        let image: Image = {
            
#warning("FIXME")
            // extract image from parameter.image with fallback to .ic24MoreHorizontal
            return .ic24MoreHorizontal
        }()
        
        let initialState = SelectUIState(
            image: image,
            state: .init(selector)
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in },
            observe: { event(.setValue($0.state.selected?.id ?? "", for: parameter.id)) }
        )
    }
    
    typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
}

private extension AnywayElementModelMapper {
    
#warning("event here is too wide, contain to widget")
    func makeWidgetViewModel(
        with widget: AnywayElement.Widget,
        event: @escaping (NotifyEvent) -> Void
    ) -> AnywayElementModel {
        
        switch widget {
        case let .otp(otp):
#warning("add duration to settings")
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
        let otpInputReducer = OTPInputReducer(
            countdownReduce: decorated,
            otpFieldReduce : otpFieldReducer.reduce(_:_:)
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
