//
//  UtilityPrepaymentFlowMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import AnywayPaymentDomain
import ForaTools
import Foundation
import UtilityServicePrepaymentDomain

final class UtilityPrepaymentFlowMicroServicesComposer {
    
    private let flag: Flag
    private let nanoServices: NanoServices
    private let makeLegacyPaymentsServicesViewModel: MakeLegacyPaymentsServicesViewModel
    
    init(
        flag: Flag,
        nanoServices: NanoServices,
        makeLegacyPaymentsServicesViewModel: @escaping MakeLegacyPaymentsServicesViewModel
    ) {
        self.flag = flag
        self.nanoServices = nanoServices
        self.makeLegacyPaymentsServicesViewModel = makeLegacyPaymentsServicesViewModel
    }
    
    typealias Flag = StubbedFeatureFlag
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator, UtilityService>
    typealias MicroServices = UtilityPrepaymentFlowMicroServices<LastPayment, Operator, UtilityService>
    
    typealias LegacyPayload = PrepaymentEffect.LegacyPaymentPayload
    typealias MakeLegacyPaymentsServicesViewModel = (LegacyPayload) -> PaymentsServicesViewModel
    
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>
    typealias PrepaymentEffect = Effect.UtilityPrepaymentFlowEffect
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
}

extension UtilityPrepaymentFlowMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiateUtilityPayment: initiateUtilityPayment(_:_:),
            startPayment: startPayment(_:_:)
        )
    }
}

// MARK: - initiateUtilityPayment

private extension UtilityPrepaymentFlowMicroServicesComposer {
    
    /// `legacy`: create `PaymentsServicesViewModel`.
    /// `v1`: Load last payments and operators.
    func initiateUtilityPayment(
        _ payload: LegacyPayload,
        _ completion: @escaping InitiateUtilityPaymentCompletion
    ) {
        switch flag {
        case .inactive:
            completion(.legacy(makeLegacyPaymentsServicesViewModel(payload)))
            
        case .active:
            nanoServices.getOperatorsListByParam { [weak self] in
                
                self?.getAllLatestPayments($0, completion)
            }
        }
    }
    
    private func getAllLatestPayments(
        _ operators: [Operator],
        _ completion: @escaping InitiateUtilityPaymentCompletion
    ) {
        nanoServices.getAllLatestPayments { [weak self] in
            
            guard self != nil else { return }
            
            completion(.v1(
                .init(lastPayments: $0, operators: operators, searchText: "")
            ))
        }
    }
    
    typealias InitiateUtilityPaymentCompletion = (PrepaymentEvent.Initiated) -> Void
}

// MARK: - startPayment

private extension UtilityPrepaymentFlowMicroServicesComposer {
    
    func startPayment(
        _ payload: StartPaymentPayload,
        _ completion: @escaping StartPaymentCompletion
    ) {
        switch payload {
        case let .lastPayment(lastPayment):
            nanoServices.startAnywayPayment(
                .lastPayment(lastPayment)
            ) {
                completion(self.makeStartPaymentResult($0, lastPayment, puref: lastPayment.puref))
            }
            
        case let .operator(`operator`):
            getServices(for: `operator`, completion)
            
        case let .service(utilityService, `operator`):
            nanoServices.startAnywayPayment(
                .service(utilityService, for: `operator`)
            ) {
                completion(self.makeStartPaymentResult($0, puref: utilityService.puref))
            }
        }
    }
    
    typealias StartPaymentPayload = PrepaymentEffect.Select
    typealias StartPaymentResult = PrepaymentEvent.StartPaymentResult
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias PrepaymentEvent = Event.UtilityPrepaymentFlowEvent
    
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
            nanoServices.startAnywayPayment(
                .service(utilityService, for: `operator`)
            ) {
                completion(self.makeStartPaymentResult($0, puref: .init(utilityService.puref)))
            }
            
        default:
            if let services = MultiElementArray(services) {
                completion(.success(.services(services, for: `operator`)))
            } else {
                completion(.failure(.operatorFailure(`operator`)))
            }
        }
    }
    
    private func makeStartPaymentResult(
        _ result: NanoServices.StartAnywayPaymentResult,
        _ lastPayment: LastPayment,
        puref: String
    ) -> StartPaymentResult {
        
        let outline = makeAnywayPaymentOutline(lastPayment: lastPayment)
        return makeStartPaymentResult(result, outline, puref: puref)
    }
    
    private func makeStartPaymentResult(
        _ result: NanoServices.StartAnywayPaymentResult,
        puref: String
    ) -> StartPaymentResult {
        
        let outline = makeAnywayPaymentOutline(lastPayment: nil)
        return makeStartPaymentResult(result, outline, puref: puref)
    }
    
    private func makeStartPaymentResult(
        _ result: NanoServices.StartAnywayPaymentResult,
        _ outline: AnywayPaymentOutline,
        puref: String
    ) -> StartPaymentResult {
        
        return result
            .map {
                switch $0 {
                case let .services(services, for: `operator`):
                    return .services(services, for: `operator`)
                    
                case let .startPayment(response):
                    let payment = AnywayPaymentDomain.AnywayPayment(
                        puref: .init(puref),
                        update: .init(response),
                        outline: outline
                    )
                    
#warning("hardcoded `isValid: false`")
                    let state = AnywayTransactionState(
                        payment: .init(
                            payment: payment,
                            staged: .init(),
                            outline: outline,
                            shouldRestart: false
                        ),
                        isValid: false
                    )
                    
                    return .startPayment(state)
                }
            }
            .mapError(PrepaymentEvent.StartPaymentFailure.init)
    }
    
    typealias StartPaymentResponse = NanoServices.StartAnywayPaymentSuccess.StartPaymentResponse
    
    func makeAnywayPaymentOutline(
        lastPayment: LastPayment?
    ) -> AnywayPaymentOutline {
        
        nanoServices.makeAnywayPaymentOutline(lastPayment)
    }
}

// MARK: - Adapters

private extension AnywayPaymentDomain.AnywayPayment {
    
    init(
        puref: Puref,
        update: AnywayPaymentUpdate,
        outline: AnywayPaymentOutline
    ) {
        let empty: Self = .init(elements: [], infoMessage: nil, isFinalStep: false, isFraudSuspected: false, puref: puref)
        self = empty.update(with: update, and: outline)
    }
}

private extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentFailure {
    
    init(
        _ error: NanoServices.StartAnywayPaymentFailure
    ) {
        switch error {
        case let .operatorFailure(`operator`):
            self = .operatorFailure(`operator`)
            
        case let .serviceFailure(failure):
            switch failure {
            case .connectivityError:
                self = .serviceFailure(.connectivityError)
                
            case let .serverError(message):
                self = .serviceFailure(.serverError(message))
            }
        }
    }
    
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator, UtilityService>
}
