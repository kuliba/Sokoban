//
//  UtilityPrepaymentFlowMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import AnywayPaymentDomain
import ForaTools
import Foundation
import RemoteServices
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
                completion(self.makeStartPaymentResult($0, lastPayment))
            }
            
        case let .operator(`operator`):
            getServices(for: `operator`, completion)
            
        case let .service(utilityService, `operator`):
            nanoServices.startAnywayPayment(
                .service(utilityService, for: `operator`)
            ) {
                let result = self.makeStartPaymentResult(from: $0, utilityService, `operator`)
                completion(result)
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
                let result = self.makeStartPaymentResult(from: $0, utilityService, `operator`)
                completion(result)
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
        _ lastPayment: LastPayment
    ) -> ProcessSelectionResult {
        
        let outline = makeAnywayPaymentOutline(lastPayment: lastPayment)
        return makeStartPaymentResult(result, outline, payload: .init(with: lastPayment))
    }
    
    private func makeStartPaymentResult(
        from result: NanoServices.StartAnywayPaymentResult,
        _ service: UtilityService,
        _ `operator`: Operator
    ) -> ProcessSelectionResult {
        
        let result = result.map { 
            // https://shorturl.at/cQ3zr
            $0.injectSelectedService(service, of: `operator`)
        }
        
        let outline = makeAnywayPaymentOutline(lastPayment: nil)
        let payload = AnywayPaymentDomain.AnywayPayment.Payload(
            puref: service.puref,
            operator: `operator`
        )
        return makeStartPaymentResult(result, outline, payload: payload)
    }
    
    private func makeAnywayPaymentOutline(
        lastPayment: LastPayment?
    ) -> AnywayPaymentOutline {
        
        nanoServices.makeAnywayPaymentOutline(lastPayment)
    }
    
    private func makeStartPaymentResult(
        _ result: NanoServices.StartAnywayPaymentResult,
        _ outline: AnywayPaymentOutline,
        payload: AnywayPaymentDomain.AnywayPayment.Payload
    ) -> ProcessSelectionResult {
        
        return result
            .map {
                switch $0 {
                case let .services(services, for: `operator`):
                    return .services(services, for: `operator`)
                    
                case let .startPayment(response):
                    let state = makeState(from: response, with: outline, and: payload)
                    
                    return .startPayment(state)
                }
            }
            .mapError(PrepaymentEvent.ProcessSelectionFailure.init)
    }
    
    private func makeState(
        from response: StartPaymentResponse,
        with outline: AnywayPaymentOutline,
        and payload: AnywayPaymentDomain.AnywayPayment.Payload
    ) -> AnywayTransactionState {
        
        let update = AnywayPaymentUpdate(response)
        
        let payment = AnywayPaymentDomain.AnywayPayment(
            payload: payload,
            update: update,
            outline: outline
        )
        
#warning("hardcoded `isValid: false`")
        let state = AnywayTransactionState(
            context: .init(
                payment: payment,
                staged: .init(),
                outline: outline,
                shouldRestart: false
            ),
            isValid: false
        )
        
        return state
    }
    
    typealias StartPaymentResponse = NanoServices.StartAnywayPaymentSuccess.StartPaymentResponse
    typealias StartPaymentSuccess = PrepaymentEvent.ProcessSelectionSuccess
}

// MARK: - Adapters

private extension AnywayPaymentDomain.AnywayPayment.Payload {
    
    init(
        with lastPayment: UtilityPaymentLastPayment
    ) {
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

private extension AnywayPaymentDomain.AnywayPayment {
    
    init(
        payload: AnywayPaymentDomain.AnywayPayment.Payload,
        update: AnywayPaymentUpdate,
        outline: AnywayPaymentOutline
    ) {
        let empty: Self = .init(
            elements: [],
            footer: .continue,
            infoMessage: nil,
            isFinalStep: false,
            isFraudSuspected: false,
            payload: payload
        )
        self = empty.update(with: update, and: outline)
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

// MARK: - Helpers

private extension UtilityPaymentNanoServices.StartAnywayPaymentSuccess {
    
    func injectSelectedService(
        _ service: UtilityService,
        of `operator`: UtilityPaymentOperator
    ) -> Self {
        
        switch self {
        case .services:
            return self
            
        case let .startPayment(startPayment):
            let startPayment = startPayment.injectSelectedService(service, of: `operator`)
            return .startPayment(startPayment)
        }
    }
}

private extension RemoteServices.ResponseMapper.CreateAnywayTransferResponse {
    
    func injectSelectedService(
        _ service: UtilityService,
        of `operator`: UtilityPaymentOperator
    ) -> Self {
        
        let field = Additional(
            fieldName: service.name,
            fieldValue: service.name,
            fieldTitle: "Услуга",
            md5Hash: `operator`.icon,
            recycle: false,
            svgImage: nil,
            typeIdParameterList: nil
        )
        
        return updating(additional: [field] + additional)
    }
    
    private func updating(
        additional: [Additional]
    ) -> Self {
        
        return .init(
            additional: additional,
            amount: amount,
            creditAmount: creditAmount,
            currencyAmount: currencyAmount,
            currencyPayee: currencyPayee,
            currencyPayer: currencyPayer,
            currencyRate: currencyRate,
            debitAmount: debitAmount,
            documentStatus: documentStatus,
            fee: fee,
            finalStep: finalStep,
            infoMessage: infoMessage,
            needMake: needMake,
            needOTP: needOTP,
            needSum: needSum,
            parametersForNextStep: parametersForNextStep,
            paymentOperationDetailID: paymentOperationDetailID,
            payeeName: payeeName,
            printFormType: printFormType,
            scenario: scenario,
            options: options
        )
    }
}

