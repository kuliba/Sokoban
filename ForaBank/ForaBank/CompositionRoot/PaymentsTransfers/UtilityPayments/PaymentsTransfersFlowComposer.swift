//
//  PaymentsTransfersFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import AnywayPaymentAdapters
import AnywayPaymentBackend
import AnywayPaymentDomain
import OperatorsListComponents
import ForaTools
import Foundation
import GenericRemoteService
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain

final class PaymentsTransfersFlowComposer {
    
    private let flag: StubbedFeatureFlag.Option
    private let httpClient: HTTPClient
    private let log: Log
    private let model: Model
    private let loaderComposer: LoaderComposer
    private let pageSize: Int
    private let observeLast: Int
    
    init(
        flag: StubbedFeatureFlag.Option,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        pageSize: Int,
        observeLast: Int
    ) {
        self.flag = flag
        self.httpClient = httpClient
        self.log = log
        self.model = model
        self.loaderComposer = .init(flag: flag, model: model, pageSize: pageSize)
        self.pageSize = pageSize
        self.observeLast = observeLast
    }
}

extension PaymentsTransfersFlowComposer {
    
    func compose() -> FlowManager {
        
        return .init(
            handleEffect: makeEffectHandler().handleEffect(_:_:),
            makeReduce: makeReduce()
        )
    }
    
    typealias Log = (String, StaticString, UInt) -> Void
    
    typealias LoaderComposer = UtilityPaymentOperatorLoaderComposer
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingAnywayTransactionViewModel
    
    typealias FlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}

private extension PaymentsTransfersFlowComposer {
    
    func makeEffectHandler() -> EffectHandler {
        
        let loadOperators = loaderComposer.compose()
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            flag: composerFlag,
            httpClient: httpClient,
            log: log,
            loadOperators: { loadOperators(.init(), $0) }
        )
        let microComposer = UtilityPrepaymentFlowMicroServicesComposer(
            nanoServices: nanoComposer.compose()
        )
        let composer = UtilityPaymentsFlowComposer(
            microServices: microComposer.compose()
        )
        let handler = composer.makeEffectHandler()
        
        return .init(utilityEffectHandle: handler.handleEffect(_:_:))
    }
    
    private var composerFlag: ComposerFlag {
        
        switch flag {
        case .live:
            return .live
            
        case .stub:
            return .stub(stub)
        }
    }
    
    typealias ComposerFlag = UtilityPaymentNanoServicesComposer.Flag
    
    typealias EffectHandler = PaymentsTransfersFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    func makeReduce() -> FlowManager.MakeReduce {
        
        let factory = makeReducerFactoryComposer().compose()
        
        typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
        
        let makeReducer = {
            
            Reducer(factory: factory, closeAction: $0, notify: $1)
        }
        
        return { makeReducer($0, $1).reduce(_:_:) }
    }
    
    private func makeReducerFactoryComposer(
    ) -> PaymentsTransfersFlowReducerFactoryComposer {
        
        let nanoServices = UtilityPrepaymentNanoServices(
            loadOperators: loadOperators
        )
        let microComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: pageSize,
            nanoServices: nanoServices
        )
        
        return .init(
            model: model,
            observeLast: observeLast,
            microServices: microComposer.compose(),
            makeTransactionViewModel: makeTransactionViewModel
        )
    }
    
    private func loadOperators(
        payload: LoadOperatorsPayload,
        completion: @escaping ([Operator]) -> Void
    ) {
        loaderComposer.compose()(.init(operatorID: payload.operatorID, searchText: payload.searchText), completion)
    }
    
    private typealias LoadOperatorsPayload = UtilityPrepaymentNanoServices<Operator>.LoadOperatorsPayload
    
    private func makeTransactionViewModel(
        initialState: AnywayTransactionState
    ) -> AnywayTransactionViewModel {
        
        let composer: AnywayTransactionViewModelComposer
        
        switch flag {
        case .live:
            let microServicesComposer = AnywayTransactionEffectHandlerMicroServicesComposer(
                nanoServices: .init(
                    getDetails: { _,_ in fatalError() },
                    makeTransfer: makeTransfer()
                )
            )
            composer = AnywayTransactionViewModelComposer(
                microServices: microServicesComposer.compose()
            )
            
        case .stub:
            
            //    let microServicesComposer = AnywayTransactionEffectHandlerMicroServicesComposer(
            //        nanoServices: .stubbed(with: .init(
            //            getDetailsResult: "Operation Detail",
            //            makeTransferResult: .init(
            //                status: .completed,
            //                detailID: 54321
            //            )
            //        ))
            //    )

            composer = AnywayTransactionViewModelComposer(
                microServices: .stubbed(with: .init(
                    initiatePayment: .success(.preview),
                    makePayment: .init(
                        status: .completed,
                        info: .details("Operation Detail")
                    ),
                    processPayment: .success(.preview))
                )
            )
        }
        
        return composer.compose(initialState: initialState)
    }
    
    #warning("extract to nano services composer")
    private func makeTransfer(
    ) -> AnywayTransactionEffectHandlerNanoServices.MakeTransfer {

        let createRequest = ForaBank.RequestFactory.createMakeTransferRequest
        let mapResponse = AnywayPaymentBackend.ResponseMapper.mapMakeTransferResponse
        
        let service = RemoteService(
            createRequest: createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: mapResponse
        )
        
        return { payload, completion in
        
            return service(.init(payload.rawValue)) {
             
                completion(try? $0.map(\.response).get())
            }
        }
    }
}

// MARK: - Adapters

private extension AnywayPaymentBackend.ResponseMapper.MakeTransferResponse {
    
    var response: AnywayTransactionEffectHandlerNanoServices.MakeTransferResponse {
    
        .init(status: self.status, detailID: operationDetailID)
    }
}

private extension AnywayPaymentBackend.ResponseMapper.MakeTransferResponse {
    
    var status: ForaBank.DocumentStatus {
        
        switch documentStatus {
        case .complete:   return .completed
        case .inProgress: return .inflight
        case .rejected:   return .rejected
        }
    }
}

// MARK: - Stubs

private extension PaymentsTransfersFlowComposer {
    
    func stub(
        for payload: UtilityPaymentNanoServices<LastPayment, Operator>.StartAnywayPaymentPayload
    ) -> PrepaymentMicroServices.StartPaymentResult {
        
        switch payload {
        case let .lastPayment(lastPayment):
            return stub(for: lastPayment)
            
        case let .service(service, for: `operator`):
            return stub(for: service)
        }
    }
    
    typealias PrepaymentMicroServices = UtilityPrepaymentFlowMicroServices<LastPayment, Operator, UtilityService>
    
    private func stub(
        for lastPayment: LastPayment
    ) -> PrepaymentMicroServices.StartPaymentResult {
        
        switch lastPayment.id {
        case "failure":
            return .failure(.serviceFailure(.connectivityError))
            
        default:
            return .success(.startPayment(.preview))
        }
    }
    
    private func stub(
        for `operator`: Operator
    ) -> PrepaymentMicroServices.StartPaymentResult {
        
        switch `operator`.id {
        case "single":
            return .success(.startPayment(.preview))
            
        case "singleFailure":
            return .failure(.operatorFailure(`operator`))
            
        case "multiple":
            let services = MultiElementArray<UtilityService>([
                .init(name: UUID().uuidString, puref: "failure"),
                .init(name: UUID().uuidString, puref: UUID().uuidString),
            ])!
            return .success(.services(services, for: `operator`))
            
        case "multipleFailure":
            return .failure(.serviceFailure(.serverError("Server Failure")))
            
        default:
            return .success(.startPayment(.preview))
        }
    }
    
    private func stub(
        for service: UtilityService
    ) -> PrepaymentMicroServices.StartPaymentResult {
        
        switch service.id {
        case "failure":
            return .failure(.serviceFailure(.serverError("Server Failure")))
            
        default:
            return .success(.startPayment(.preview))
        }
    }
}

private extension AnywayTransactionEffectHandlerMicroServices {
    
    static func stubbed(
        with stub: Stub
    ) -> Self {
        
        return .init(
            initiatePayment: _initiatePayment(with: stub.initiatePayment),
            makePayment: _makePayment(with: stub.makePayment),
            paymentEffectHandle: { _,_ in }, // AnywayPaymentEffect is empty
            processPayment: _processPayment(with: stub.processPayment)
        )
    }
    
    struct Stub {
        
        let initiatePayment: ProcessResult
        let makePayment: Report?
        let processPayment: ProcessResult
    }
    
    private static func _initiatePayment(
        with stub: ProcessResult
    ) -> InitiatePayment {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
    
    private static func _makePayment(
        with stub: Report?
    ) -> MakePayment {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
    
    private static func _processPayment(
        with stub: ProcessResult
    ) -> ProcessPayment {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
}

private extension AnywayPaymentUpdate {
    
    static let preview: Self = .init(
        details: .preview,
        fields: [],
        parameters: []
    )
}

private extension AnywayPaymentUpdate.Details {
    
    static let preview: Self = .init(
        amounts: .preview,
        control: .preview,
        info: .preview
    )
}

private extension AnywayPaymentUpdate.Details.Amounts {
    
    static let preview: Self = .init(
        amount: nil,
        creditAmount: nil,
        currencyAmount: nil,
        currencyPayee: nil,
        currencyPayer: nil,
        currencyRate: nil,
        debitAmount: nil,
        fee: nil
    )
}

private extension AnywayPaymentUpdate.Details.Control {
    
    static let preview: Self = .init(
        isFinalStep: false,
        isFraudSuspected: false,
        needMake: false,
        needOTP: false,
        needSum: false
    )
}

private extension AnywayPaymentUpdate.Details.Info {
    
    static let preview: Self = .init(
        documentStatus: nil,
        infoMessage: nil,
        payeeName: nil,
        paymentOperationDetailID: nil,
        printFormType: nil
    )
}
