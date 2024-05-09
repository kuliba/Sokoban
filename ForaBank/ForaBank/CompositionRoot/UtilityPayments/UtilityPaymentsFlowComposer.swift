//
//  UtilityPaymentsFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import ForaTools
import Foundation
import OperatorsListComponents

#warning("use in factory and delete")
private func a() {
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
}

final class UtilityPaymentsFlowComposer {
    
    private let flag: Flag
    
    init(flag: Flag) {
        self.flag = flag
    }
}

extension UtilityPaymentsFlowComposer {
    
    func makeEffectHandler(
    ) -> UtilityFlowEffectHandler {
        
        let prepaymentEffectHandler = PrepaymentEffectHandler(
            initiateUtilityPayment: initiateUtilityPayment(),
            startPayment: startPayment()
        )
        
        return .init(
            utilityPrepaymentEffectHandle: prepaymentEffectHandler.handleEffect(_:_:)
        )
    }
}

extension UtilityPaymentsFlowComposer {
    
    typealias Flag = StubbedFeatureFlag.Option
    
    typealias LastPayment = OperatorsListComponents.LatestPayment
    typealias Operator = OperatorsListComponents.Operator
    
    typealias UtilityFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
}

private extension UtilityPaymentsFlowComposer {
    
    typealias PrepaymentEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    func initiateUtilityPayment(
    ) -> PrepaymentEffectHandler.InitiateUtilityPayment {
        
        switch flag {
        case .live:
            fatalError("unimplemented live")
            
        case .stub:
            return stub(.init(
                lastPayments: [],
                operators: [.failure, .list, .single]
            ))
        }
    }
    
    func startPayment(
    ) -> PrepaymentEffectHandler.StartPayment {
        
        switch flag {
        case .live:
            fatalError("unimplemented live")
            
        case .stub:
            return stub()
        }
    }
}

// MARK: - Stubs

private extension UtilityPaymentsFlowComposer {
    
    typealias PrepaymentPayload = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    
    func stub(
        _ stub: PrepaymentPayload
    ) -> PrepaymentEffectHandler.InitiateUtilityPayment {
        
        return { completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
    
    func stub() -> PrepaymentEffectHandler.StartPayment {
        
        return { payload, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub(for: payload))
            }
        }
        
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
    }
}

// TODO: make private
/*private*/ extension OperatorsListComponents.Operator {
    
    static let failure: Self = .init("failure", "Failure")
    static let list: Self = .init("list", "List")
    static let single: Self = .init("single", "Single")
    
    private init(_ id: String, _ title: String) {
        
        self.init(id: id, title: title, subtitle: nil, image: nil)
    }
}
