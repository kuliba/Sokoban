//
//  PaymentsTransfersComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents
import ForaTools
import Foundation

final class PaymentsTransfersComposer {
    
    private let utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    
    init(utilitiesPaymentsFlag: UtilitiesPaymentsFlag) {
        self.utilitiesPaymentsFlag = utilitiesPaymentsFlag
    }
}

extension PaymentsTransfersComposer {
    
    func makeFlowManager(
    ) -> PTFlowManger {
        
#warning("use in factory")
        let createAnywayTransfer: PaymentsTransfersEffectHandler.CreateAnywayTransfer = { payload, completion in
            
#warning("replace with NanoService.createAnywayTransfer")
            DispatchQueue.main.delay(for: .seconds(2)) {
                
                switch payload {
                case let .latestPayment(latestPayment):
                    completion(.details(.init()))
                    
                case let .service(`operator`, utilityService):
                    switch utilityService.id {
                    case "server error":
                        completion(.serverError("Error [#12345]."))
                        
                    case "empty", "just sad":
                        completion(.failure)
                        
                    default:
                        completion(.details(.init()))
                    }
                }
            }
        }
        
        let getOperatorsListByParam: PaymentsTransfersEffectHandler.GetOperatorsListByParam = { payload, completion in
            
#warning("replace with NanoService.getOperatorsListByParam")
            
            DispatchQueue.main.delay(for: .seconds(2)) {
                
                switch payload {
                case "list":
                    completion(.list([
                        .init(id: "happy"),
                        .init(id: "server error"),
                        .init(id: "empty"),
                        .init(id: "just sad"),
                    ]))
                    
                case "single":
                    completion(.single(.init()))
                    
                default:
                    completion(.failure)
                }
            }
        }
        
        let _effectHandler = PaymentsTransfersEffectHandler(
            createAnywayTransfer: createAnywayTransfer,
            getOperatorsListByParam: getOperatorsListByParam
        )
        
        let utilityPaymentReducer = UtilityPaymentReducer()
        
        typealias LastPayment = OperatorsListComponents.LatestPayment
        typealias Operator = OperatorsListComponents.Operator
        
        typealias PTFlowManger = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
        typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
        typealias ReducerFactory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
        
        typealias PrepaymentEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
        
        typealias PrepaymentPayload = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
        
        let prepaymentPayloadStub = PrepaymentPayload(
            lastPayments: [],
            operators: [.failure, .list, .single]
        )
        
        func stub(
            for payload: PrepaymentEffectHandler.StartPaymentPayload
        ) -> PrepaymentEffectHandler.StartPaymentResult {
            
            switch payload {
            case let .lastPayment(lastPayment):
                switch lastPayment.id {
                case "failure":
                    return .failure(.serviceFailure(.connectivityError))
                default:
                    return .success(.startPayment(.init()))
                }
                
            case let .operator(`operator`):
                switch `operator`.id {
                case "single":
                    return .success(.startPayment(.init()))
                case "singleFailure":
                    return .failure(.operatorFailure(`operator`))
                case "multiple":
                    let services = MultiElementArray<UtilityService>([
                        
                        .init(id: "failure"),
                        .init(id: UUID().uuidString),
                    ])!
                    return .success(.services(services, for: `operator`))
                case "multipleFailure":
                    return .failure(.serviceFailure(.serverError("Server Failure")))
                default:
                    return .success(.startPayment(.init()))
                }
                
            case let .service(service, _):
                switch service.id {
                case "failure":
                    return .failure(.serviceFailure(.serverError("Server Failure")))
                default:
                    return .success(.startPayment(.init()))
                }
            }
        }
        
        let utilitiesPaymentsFlag = utilitiesPaymentsFlag
#warning("extract to helper")
        let prepaymentEffectHandler = PrepaymentEffectHandler(
            initiateUtilityPayment: { completion in
                
                DispatchQueue.main.delay(for: .seconds(1)) {
                    
                    switch utilitiesPaymentsFlag.rawValue {
                    case .inactive:
                        fatalError("wrong flow")
                        
                    case .active(.live):
                        fatalError("wrong flow")
                        
                    case .active(.stub):
                        completion(prepaymentPayloadStub)
                    }
                }
            },
            startPayment: { payload, completion in
                
                DispatchQueue.main.delay(for: .seconds(1)) {
                    
                    completion(stub(for: payload))
                }
            }
        )
        
        typealias UtilityFlowEffectHandle = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
        
        let utilityFlowEffectHandler = UtilityFlowEffectHandle(
            utilityPrepaymentEffectHandle: prepaymentEffectHandler.handleEffect(_:_:)
        )
        
        typealias EffectHandler = PaymentsTransfersFlowEffectHandler<LastPayment, Operator, UtilityService>
        
        let effectHandler = EffectHandler(
            utilityEffectHandle: utilityFlowEffectHandler.handleEffect(_:_:)
        )
        
#warning("extract to helper")
        let factory = ReducerFactory(
            makeUtilityPrepaymentViewModel: { payload in
                
                let reducer = UtilityPrepaymentReducer()
                let effectHandler = UtilityPrepaymentEffectHandler()
                
                return .init(
                    initialState: payload.state,
                    reduce: reducer.reduce(_:_:),
                    handleEffect: effectHandler.handleEffect(_:_:)
                )
            },
            makePaymentViewModel: { _, notify in
                
                return .init(notify: notify)
            }
        )
        
        let makeReducer = { notify in
            
            Reducer(factory: factory, notify: notify)
        }
        
        return .init(
            handleEffect: effectHandler.handleEffect(_:_:),
            makeReduce: { makeReducer($0).reduce(_:_:) }
        )
    }
}

extension PaymentsTransfersComposer {
    
    typealias LatestPayment = OperatorsListComponents.LatestPayment
    typealias Operator = OperatorsListComponents.Operator
    
    typealias PTFlowManger = PaymentsTransfersFlowManager<LatestPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
}

// MARK: - Stubs

// TODO: make private
/*private*/ extension OperatorsListComponents.Operator {
    
    static let failure: Self = .init("failure", "Failure")
    static let list: Self = .init("list", "List")
    static let single: Self = .init("single", "Single")
    
    private init(_ id: String, _ title: String) {
        
        self.init(id: id, title: title, subtitle: nil, image: nil)
    }
}
