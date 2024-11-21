//
//  PaymentsTransfersFlowManagerComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import AnywayPaymentAdapters
import AnywayPaymentBackend
import AnywayPaymentCore
import AnywayPaymentDomain
import CombineSchedulers
import OperatorsListComponents
import ForaTools
import Foundation
import GenericRemoteService
import LatestPaymentsBackendV2
import PaymentComponents
import RemoteServices
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain
import UIKit

final class PaymentsTransfersFlowManagerComposer {
    
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.httpClient = httpClient
        self.log = log
        self.scheduler = scheduler
    }
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
}

extension PaymentsTransfersFlowManagerComposer {
    
    func compose(
        _ spinnerActions: RootViewModel.RootActions.Spinner?
    ) -> FlowManager {
        
        let utilityComposer = UtilityPaymentStateComposer(
            model: model,
            httpClient: httpClient,
            log: log,
            spinnerActions: spinnerActions
        )
        
        let composer = makeReducerFactoryComposer()
        let factory = composer.compose(
            makeUtilityPaymentState: utilityComposer.makeUtilityPaymentState
        )
        
        return .init(
            handleEffect: makeHandleEffect(),
            makeReduce: makeReduce(with: factory)
        )
    }
    
    typealias FlowManager = PaymentsTransfersFlowManager
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = AnywayTransactionViewModel
}

private extension PaymentsTransfersFlowManagerComposer {
    
    struct Settings: Equatable {
        
        let pageSize: Int = 50
        let observeLast: Int = 10
        let fraudDelay: Double
        let utilityNavTitle = "Услуги ЖКХ"
        
        static let live: Self = .init(fraudDelay: 120)
        static let stub: Self = .init(fraudDelay: 12)
    }
    
    var settings: Settings { .live }
}

private extension PaymentsTransfersFlowManagerComposer {
    
    func makeHandleEffect() -> FlowManager.HandleEffect {
        
        let microServices = composeUtilityPaymentMicroServices()
        let prepaymentEffectHandler = PrepaymentFlowEffectHandler(
            microServices: microServices
        )
        let paymentFlowEffectHandler = PaymentFlowEffectHandler(
            utilityPrepaymentEffectHandle: prepaymentEffectHandler.handleEffect(_:_:)
        )
        
        let effectHandler = PaymentsTransfersFlowEffectHandler(
            microServices: .init(
                initiatePayment: initiatePayment(microServices: microServices)
            ),
            utilityEffectHandle: paymentFlowEffectHandler.handleEffect(_:_:)
        )
        
        return effectHandler.handleEffect(_:_:)
    }
    
    typealias PaymentFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, Service>
    
    private func initiatePayment(
        microServices: PrepaymentFlowEffectHandler.MicroServices
    ) -> PaymentsTransfersFlowEffectHandlerMicroServices.InitiatePayment {
        
        return initiatePaymentLive(microServices)
    }
    
    private func initiatePaymentLive(
        _ microServices: PrepaymentFlowEffectHandler.MicroServices
    ) -> PaymentsTransfersFlowEffectHandlerMicroServices.InitiatePayment {
        
        return { payload, completion in
            
            guard let lastPayment = payload.lastPayment
            else {
                completion(.failure(.connectivityError))
                self.log(.error, .payments, "LastPayment creation failure.", #file, #line)
                return
            }
            
            microServices.processSelection(.lastPayment(lastPayment)) {
                
                switch $0 {
                case let .failure(failure):
                    switch failure {
                    case .operatorFailure, .serviceFailure(.connectivityError):
                        completion(.failure(.connectivityError))
                        
                    case let .serviceFailure(.serverError(message)):
                        completion(.failure(.serverError(message)))
                    }
                    
                case let .success(success):
                    switch success {
                    case .services:
                        completion(.failure(.connectivityError))
                        
                    case let .startPayment(transaction):
                        completion(.success(transaction))
                    }
                }
            }
        }
    }

    private func composeUtilityPaymentMicroServices(
    ) -> PrepaymentFlowEffectHandler.MicroServices {
        
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            model: model,
            httpClient: httpClient,
            log: log,
            loadOperators: loadOperators
        )
        let composer = AnywayTransactionComposer(
            model: model,
            validator: .init()
        )
        let microComposer = UtilityPrepaymentFlowMicroServicesComposer(
            composer: composer,
            nanoServices: nanoComposer.compose(),
            makeLegacyPaymentsServicesViewModel: makeLegacyViewModel
        )
        
        return microComposer.compose()
    }
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, Service>
    
    private func loadOperators(
        _ completion: @escaping ([Operator]) -> Void
    ) {
        let load = loadOperators()
        
        load(.init()) { completion($0); _ = load }
    }
    
    private func makeLegacyViewModel(
        payload: MakePaymentPayload
    ) -> PaymentsServicesViewModel {
        
        let composer = PaymentsServicesViewModelComposer(model: model)
        return composer.compose(payload: payload)
    }
    
    typealias PrepaymentEffect = UtilityPrepaymentFlowEffect<LastPayment, Operator, Service>
    typealias MakePaymentPayload = PrepaymentEffect.LegacyPaymentPayload
    
    func makeReduce(
        with factory: ReducerFactory
    ) -> FlowManager.MakeReduce {
        
        let makeReducer = {
            
            FlowReducer(
                handlePaymentTriggerEvent: self.handlePaymentTriggerEvent,
                factory: factory,
                closeAction: $0,
                notify: $1,
                hideKeyboard: self.hideKeyboard
            )
        }
        
        return { makeReducer($0, $1).reduce(_:_:) }
    }
    
    private func hideKeyboard() {
     
        UIApplication.shared.endEditing()
    }
    
    private func handlePaymentTriggerEvent(
        event: PaymentTriggerEvent
    ) -> (PaymentTriggerState) {
        
        switch event {
        case let .latestPayment(latestPaymentData):
            return .v1
        }
    }
    
    typealias ReducerFactory = PaymentsTransfersFlowReducerFactory
    typealias FlowReducer = PaymentsTransfersFlowReducer
    
    private func makeReducerFactoryComposer(
    ) -> PaymentsTransfersFlowReducerFactoryComposer {
        
        let nanoServices = UtilityPrepaymentNanoServices(
            loadOperators: loadOperators
        )
        let microComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: settings.pageSize,
            nanoServices: nanoServices
        )
        
        return .init(
            model: model,
            settings: .init(
                observeLast: settings.observeLast,
                fraudDelay: settings.fraudDelay,
                navTitle: settings.utilityNavTitle
            ),
            microServices: microComposer.compose(for: .housingAndCommunalService),
            scheduler: scheduler
        )
    }
    
    private func loadOperators(
        payload: LoadOperatorsPayload,
        completion: @escaping ([Operator]) -> Void
    ) {
        let load = loadOperators()
        
        typealias Payload = UtilityPaymentOperatorLoaderComposer.Payload
        
        let payload = Payload(
            operatorID: payload.operatorID,
            searchText: payload.searchText
        )
        
        load(payload) { completion($0); _ = load }
    }
    
    typealias LoadOperatorsPayload = UtilityPrepaymentNanoServices<Operator>.LoadOperatorsPayload
    
    private func loadOperators(
    ) -> (
        UtilityPaymentOperatorLoaderComposer.Payload,
        @escaping ([Operator]) -> Void
    ) -> Void {
        
        let loaderComposer = UtilityPaymentOperatorLoaderComposer(
            model: model,
            pageSize: settings.pageSize
        )
        
        return loaderComposer.compose()
    }
}

// MARK: - Adapters

private extension LatestPaymentData {
    
    var lastPayment: UtilityPaymentLastPayment? {
        
        guard let data  = self as? PaymentServiceData
        else { return nil }
        
        return .init(
            date: data.date,
            amount: .init(data.amount),
            name: data.lastPaymentName ?? "",
            md5Hash: nil,
            puref: data.puref,
            additionalItems: data.additionalList.map { .init(data: $0) }
        )
    }
}

private extension UtilityPaymentLastPayment.AdditionalItem {
    
    init(data: PaymentServiceData.AdditionalListData) {
        
        self.init(fieldName: data.fieldName, fieldValue: data.fieldValue, fieldTitle: data.fieldTitle, svgImage: data.svgImage)
    }
}
