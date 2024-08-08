//
//  UtilityPrepaymentFlowMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import ForaTools
import Foundation
import RemoteServices
import UtilityServicePrepaymentDomain

final class UtilityPrepaymentFlowMicroServicesComposer {
    
    private let composer: AnywayTransactionComposer
    private let flag: Flag
    private let nanoServices: NanoServices
    private let makeLegacyPaymentsServicesViewModel: MakeLegacyPaymentsServicesViewModel
    
    init(
        composer: AnywayTransactionComposer,
        flag: Flag,
        nanoServices: NanoServices,
        makeLegacyPaymentsServicesViewModel: @escaping MakeLegacyPaymentsServicesViewModel
    ) {
        self.composer = composer
        self.flag = flag
        self.nanoServices = nanoServices
        self.makeLegacyPaymentsServicesViewModel = makeLegacyPaymentsServicesViewModel
    }
    
    typealias Flag = StubbedFeatureFlag
    typealias NanoServices = UtilityPaymentNanoServices
    typealias MicroServices = UtilityPrepaymentFlowMicroServices<LastPayment, Operator, Service>
    
    typealias LegacyPayload = PrepaymentEffect.LegacyPaymentPayload
    typealias MakeLegacyPaymentsServicesViewModel = (LegacyPayload) -> PaymentsServicesViewModel
    
    typealias PrepaymentEffect = UtilityPrepaymentFlowEffect<LastPayment, Operator, Service>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
}

extension UtilityPrepaymentFlowMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiateUtilityPayment: initiateUtilityPayment(_:_:),
            processSelection: processSelection(_:_:)
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
    
    typealias InitiateUtilityPaymentCompletion = MicroServices.InitiateUtilityPaymentCompletion
}

// MARK: - startPayment

private extension UtilityPrepaymentFlowMicroServicesComposer {
    
    func processSelection(
        _ payload: ProcessSelectionPayload,
        _ completion: @escaping ProcessSelectionCompletion
    ) {
        switch payload {
        case let .lastPayment(lastPayment):
            nanoServices.startAnywayPayment(
                .lastPayment(lastPayment)
            ) {
                completion(self.map($0, with: .lastPayment(lastPayment)))
            }
            
        case let .operator(`operator`):
            getServices(for: `operator`, completion)
            
        case let .oneOf(utilityService, `operator`):
            nanoServices.startAnywayPayment(
                .service(utilityService, for: `operator`)
            ) {
                completion(self.map($0, with: .oneOf(utilityService, `operator`)))
            }
            
        case let .singleService(utilityService, `operator`):
            nanoServices.startAnywayPayment(
                .service(utilityService, for: `operator`)
            ) {
                completion(self.map($0, with: .singleService(utilityService, `operator`)))
            }
        }
    }
    
    typealias ProcessSelectionPayload = MicroServices.ProcessSelectionPayload
    typealias ProcessSelectionResult = MicroServices.ProcessSelectionResult
    typealias ProcessSelectionCompletion = MicroServices.ProcessSelectionCompletion
    
    typealias PrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    
    private func getServices(
        for `operator`: Operator,
        _ completion: @escaping ProcessSelectionCompletion
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
        with completion: @escaping ProcessSelectionCompletion
    ) {
        switch (services.count, services.first) {
        case (0, _):
            completion(.failure(.operatorFailure(`operator`)))
            
        case let (1, .some(utilityService)):
            nanoServices.startAnywayPayment(
                .service(utilityService, for: `operator`)
            ) {
                completion(self.map($0, with: .singleService(utilityService, `operator`)))
            }
            
        default:
            if let services = MultiElementArray(services) {
                completion(.success(.services(services, for: `operator`)))
            } else {
                completion(.failure(.operatorFailure(`operator`)))
            }
        }
    }
    
    func map(
        _ result:  UtilityPaymentNanoServices.StartAnywayPaymentResult,
        with payload: MakeAnywayTransactionPayload
    ) -> ProcessSelectionResult {
    
        switch result {
        case .failure(.operatorFailure):
            return .failure(.serviceFailure(.connectivityError))
            
        case .failure(.serviceFailure(.connectivityError)):
            return .failure(.serviceFailure(.connectivityError))
            
        case let .failure(.serviceFailure(.serverError(message))):
            return .failure(.serviceFailure(.serverError(message)))
            
        case let .success(.services(services, for: `operator`)):
            return .success(.services(services, for: `operator`))
            
        case let .success(.startPayment(response)):
            guard let transaction = composer.makeTransaction(from: response, with: payload)
            else {
                return .failure(.serviceFailure(.connectivityError))
            }
            
            return .success(.startPayment(transaction))
        }
    }
}

// MARK: - Helpers

private extension AnywayPaymentContext {
    
    init(
        from update: AnywayPaymentUpdate,
        with outline: AnywayPaymentOutline,
        service: UtilityService?
    ) {
        let firstField = AnywayElement.Field(
            service: service,
            icon: outline.payload.icon
        )
        let initialPayment = AnywayPaymentDomain.AnywayPayment(
            amount: outline.amount,
            elements: [firstField.map { .field($0) }].compactMap { $0 },
            footer: .continue,
            isFinalStep: false
        )

        self.init(
            initial: initialPayment,
            payment: initialPayment.update(with: update, and: outline),
            staged: .init(),
            outline: outline,
            shouldRestart: false
        )
    }
}

extension AnywayTransactionState.Transaction {
    
    init(from context: AnywayPaymentContext) {
        
        let validator = AnywayPaymentContextValidator()
        
        self.init(
            context: context,
            isValid: validator.validate(context) == nil
        )
    }
}

// MARK: - Adapters

private extension AnywayPaymentOutline.Payload {
    
    init(with lastPayment: UtilityPaymentLastPayment) {
        
        self.init(
            puref: lastPayment.puref,
            title: lastPayment.name,
            subtitle: "",
            icon: lastPayment.md5Hash
        )
    }
    
    init(
        puref: String,
        `operator`: UtilityPaymentOperator
    ) {
        self.init(
            puref: puref,
            title: `operator`.title,
            subtitle: `operator`.subtitle,
            icon: `operator`.icon
        )
    }
}

private extension UtilityPrepaymentFlowEvent.ProcessSelectionFailure where Operator == UtilityPaymentOperator{
    
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
    
    typealias NanoServices = UtilityPaymentNanoServices
}
