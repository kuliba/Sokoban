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
import OperatorsListComponents
import ForaTools
import Foundation
import GenericRemoteService
import LatestPayments
import PaymentComponents
import RemoteServices
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain
import UIKit

final class PaymentsTransfersFlowManagerComposer {
    
    private let flag: Flag
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    
    init(
        flag: Flag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log
    ) {
        self.flag = flag
        self.model = model
        self.httpClient = httpClient
        self.log = log
    }
    
    typealias Flag = UtilitiesPaymentsFlag
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
}

extension PaymentsTransfersFlowManagerComposer {
    
    func compose(
        _ spinnerActions: RootViewModel.RootActions.Spinner?
    ) -> FlowManager {
        
        let utilityComposer = UtilityPaymentStateComposer(
            flag: flag,
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
    
    var settings: Settings {
        
        flag.isStub ? .stub : .live
    }
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
        
        switch flag.optionOrStub {
        case .live: return initiatePaymentLive(microServices)
        case .stub: return initiatePaymentStub(microServices)
        }
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

    private func initiatePaymentStub(
        _ microServices: PrepaymentFlowEffectHandler.MicroServices
    ) -> PaymentsTransfersFlowEffectHandlerMicroServices.InitiatePayment {
        
        return { payload, completion in
            
            DispatchQueue.global().delay(for: .seconds(2)) {
                
                completion(.failure(.connectivityError))
            }
        }
    }
        
    private func composeUtilityPaymentMicroServices(
    ) -> PrepaymentFlowEffectHandler.MicroServices {
        
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            flag: flag,
            model: model,
            httpClient: httpClient,
            log: log,
            loadOperators: loadOperators
        )

        let microComposer = UtilityPrepaymentFlowMicroServicesComposer(
            flag: flag.rawValue,
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
        
        let operators = model.operators(for: payload.type) ?? []
        
        let navigationBarViewModel = NavigationBarView.ViewModel.allRegions(
            titleButtonAction: { [weak model] in
                
                model?.action.send(PaymentsServicesViewModelWithNavBarAction.OpenCityView())
            },
            navLeadingAction: payload.navLeadingAction,
            navTrailingAction: payload.navTrailingAction
        )
        
        let lastPaymentsKind: LatestPaymentData.Kind = .init(rawValue: payload.type.rawValue) ?? .unknown
        let latestPayments = PaymentsServicesLatestPaymentsSectionViewModel(model: model, including: [lastPaymentsKind])
        
        return .init(
            searchBar: .withText("Наименование или ИНН"),
            navigationBar: navigationBarViewModel,
            model: model,
            latestPayments: latestPayments,
            allOperators: operators,
            addCompanyAction: payload.addCompany,
            requisitesAction: payload.requisites
        )
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
            if flag.isActive {
                return .v1
            } else {
                return .legacy(.latestPayment(latestPaymentData))
            }
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
            microServices: microComposer.compose()
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
            flag: flag.optionOrStub,
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
