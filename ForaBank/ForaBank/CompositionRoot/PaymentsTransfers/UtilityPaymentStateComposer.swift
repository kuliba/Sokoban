//
//  UtilityPaymentStateComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import Foundation
import ProductSelectComponent

final class UtilityPaymentStateComposer {
    
    private let flag: Flag
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    private let spinnerActions: SpinnerActions?
    
    init(
        flag: Flag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        spinnerActions: SpinnerActions?
    ) {
        self.flag = flag
        self.model = model
        self.httpClient = httpClient
        self.log = log
        self.spinnerActions = spinnerActions
    }
    
    typealias Flag = UtilitiesPaymentsFlag
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    typealias SpinnerActions = RootViewModel.RootActions.Spinner
}

extension UtilityPaymentStateComposer {
    
    typealias NotifyStatus = (AnywayTransactionStatus?) -> Void
    
    func makeUtilityPaymentState(
        transaction: AnywayTransactionState.Transaction,
        notify: @escaping NotifyStatus
    ) -> UtilityServicePaymentFlowState<AnywayTransactionViewModel> {
        
        let composer = makeComposer()
        
        let viewModel = composer.makeAnywayTransactionViewModel(
            transaction: transaction
        )
        
        let subscription = viewModel.$state
            .dropFirst()
            .map(\.transaction.status)
            .removeDuplicates()
            .handleEvents(receiveOutput: {
#if DEBUG || MOCK
                print("===>>>", ObjectIdentifier(viewModel), "notify: viewModel.$state.transaction.status:", $0 ?? "nil", "\(#file):\(#line)")
#endif
            })
            .sink(receiveValue: notify)
        
        return .init(viewModel: viewModel, subscription: subscription)
    }
    
    private func makeComposer(
    ) -> AnywayTransactionViewModelComposer {
        
        let elementMapper = AnywayElementModelMapper(
            currencyOfProduct: currencyOfProduct,
            format: format,
            getProducts: model.productSelectProducts,
            flag: flag.optionOrStub
        )
        
        let microServices = composeMicroServices()
        
        return .init(
            getCurrencySymbol: getCurrencySymbol,
            elementMapper: elementMapper,
            microServices: microServices,
            spinnerActions: spinnerActions
        )
    }
    
    private func format(currency: String?, amount: Decimal) -> String {
        
        return model.formatted(amount, with: currency ?? "") ?? ""
    }
    
    private func composeMicroServices(
    ) -> AnywayTransactionEffectHandlerMicroServices {
        
        typealias NanoServicesComposer = AnywayTransactionEffectHandlerNanoServicesComposer
        typealias MicroServicesComposer = AnywayTransactionEffectHandlerMicroServicesComposer
        
        let nanoServicesComposer = NanoServicesComposer(
            flag: flag.optionOrStub,
            httpClient: httpClient,
            log: log
        )
        
        let microServicesComposer = MicroServicesComposer(
            nanoServices: nanoServicesComposer.compose()
        )
        
        return microServicesComposer.compose()
    }
    
    private func getCurrencySymbol(
        for currency: String
    ) -> String {
        
        model.dictionaryCurrencySymbol(for: currency) ?? ""
    }
    
    private func currencyOfProduct(
        product: ProductSelect.Product
    ) -> String {
        
        model.currencyOf(product: product) ?? ""
    }
}
