//
//  UtilityPrepaymentFlowMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import ForaTools
import Foundation
import UtilityServicePrepaymentDomain

final class UtilityPrepaymentFlowMicroServicesComposer<LastPayment, Operator>
where Operator: Identifiable {
    
    private let nanoServices: NanoServices
    
    init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
}

extension UtilityPrepaymentFlowMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiateUtilityPayment: initiateUtilityPayment(_:),
            startPayment: startPayment(_:_:)
        )
    }
}

extension UtilityPrepaymentFlowMicroServicesComposer {
    
    typealias MicroServices = UtilityPrepaymentFlowMicroServices<LastPayment, Operator, UtilityService>
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator>
}

private extension UtilityPrepaymentFlowMicroServicesComposer {
    
    // MARK: - initiateUtilityPayment
    
    func initiateUtilityPayment(
        _ completion: @escaping InitiateUtilityPaymentCompletion
    ) {
        nanoServices.getOperatorsListByParam { [weak self] in
            
            self?.getAllLatestPayments($0, completion)
        }
    }
    
    private func getAllLatestPayments(
        _ operators: [Operator],
        _ completion: @escaping InitiateUtilityPaymentCompletion
    ) {
        nanoServices.getAllLatestPayments { [weak self] in
            
            guard self != nil else { return }
            
            completion(.init(lastPayments: $0, operators: operators, searchText: ""))
        }
    }
    
    typealias InitiateUtilityPaymentCompletion = (Event.UtilityPrepaymentPayload) -> Void
    
    // MARK: - startPayment
    
    func startPayment(
        _ payload: StartPaymentPayload,
        _ completion: @escaping StartPaymentCompletion
    ) {
        switch payload {
        case let .lastPayment(lastPayment):
            nanoServices.startAnywayPayment(.lastPayment(lastPayment), completion)
            
        case let .operator(`operator`):
            getServices(for: `operator`, completion)
            
        case let .service(utilityService, _):
            nanoServices.startAnywayPayment(.service(utilityService), completion)
        }
    }
    
    typealias StartPaymentPayload = Effect.Select
    typealias StartPaymentResult = Event.StartPaymentResult
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEffect
    
    private func getServices(
        for `operator`: Operator,
        _ completion: @escaping StartPaymentCompletion
    ) {
        nanoServices.getServicesFor(`operator`) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.operatorFailure(`operator`)))
                
            case let .success(services):
                handle(services, for: `operator`, with: completion)
            }
        }
    }
    
    private func handle(
        _ services: [UtilityService],
        for `operator`: Operator,
        with completion: @escaping StartPaymentCompletion
    ) {
        switch (services.count, services.first) {
        case (0, _):
            completion(.failure(.operatorFailure(`operator`)))
            
        case let (1, .some(utilityService)):
            nanoServices.startAnywayPayment(.service(utilityService), completion)
            
        default:
            if let services = MultiElementArray(services) {
                completion(.success(.services(services, for: `operator`)))
            } else {
                completion(.failure(.operatorFailure(`operator`)))
            }
        }
    }
}
