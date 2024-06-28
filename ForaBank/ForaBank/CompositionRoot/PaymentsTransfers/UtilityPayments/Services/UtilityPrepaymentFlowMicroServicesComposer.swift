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
        
        let outline = makeOutline(
            lastPayment: lastPayment,
            payload: .init(with: lastPayment)
        )
        
        return makeStartPaymentResult(result, outline)
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
        
        let payload = AnywayPaymentOutline.Payload(
            puref: service.puref,
            operator: `operator`
        )
        let outline = makeOutline(
            lastPayment: nil,
            payload: payload
        )
        
        return makeStartPaymentResult(result, outline)
    }
    
    private func makeOutline(
        lastPayment: LastPayment?,
        payload: AnywayPaymentOutline.Payload
    ) -> AnywayPaymentOutline {
        
        nanoServices.makeAnywayPaymentOutline(lastPayment, payload)
    }
    
    private func makeStartPaymentResult(
        _ result: NanoServices.StartAnywayPaymentResult,
        _ outline: AnywayPaymentOutline
    ) -> ProcessSelectionResult {
        
        switch result {
        case let .failure(failure):
            return .failure(.init(failure))
            
        case let .success(success):
            switch success {
            case let .services(services, for: `operator`):
                return .success(.services(services, for: `operator`))
                
            case let .startPayment(response):
                let update = AnywayPaymentUpdate(response)
                
                switch update {
                case .none:
                    return .failure(.serviceFailure(.connectivityError))
                    
                case let .some(update):
                    let state = initiateTransaction(from: update, with: outline)
                    
                    return .success(.startPayment(state))
                }
            }
        }
    }
    
    private func initiateTransaction(
        from update: AnywayPaymentUpdate,
        with outline: AnywayPaymentOutline
    ) -> AnywayTransactionState.Transaction {
        
        let payment = AnywayPaymentDomain.AnywayPayment(
            update: update,
            outline: outline
        )
        
        let context = AnywayPaymentContext(
            initial: .init(
                elements: [],
                footer: .continue,
                infoMessage: nil,
                isFinalStep: false
            ),
            payment: payment,
            staged: .init(),
            outline: outline,
            shouldRestart: false
        )
        
        let transaction = AnywayTransactionState.Transaction(
            context: context,
            isValid: validatePayment(context)
        )
        
        return transaction
    }
    
    typealias StartPaymentResponse = NanoServices.StartAnywayPaymentSuccess.StartPaymentResponse
    typealias StartPaymentSuccess = PrepaymentEvent.ProcessSelectionSuccess
    
    private func validatePayment(
        _ context: AnywayPaymentContext
    ) -> Bool {
        
        let validator = AnywayPaymentContextValidator()
        
        return validator.validate(context) == nil
    }
}

// MARK: - Adapters

private extension AnywayPaymentOutline.Payload {
    
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
        update: AnywayPaymentUpdate,
        outline: AnywayPaymentOutline
    ) {
        let empty: Self = .init(
            elements: [],
            footer: .continue,
            infoMessage: nil,
            isFinalStep: false
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
