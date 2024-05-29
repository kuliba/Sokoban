//
//  AnywayTransactionEffectHandlerMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain

final class AnywayTransactionEffectHandlerMicroServicesComposer {
    
    private let nanoServices: NanoServices
    
    init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
}

extension AnywayTransactionEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiatePayment: initiatePayment(_:_:),
            makePayment: makePayment(_:_:),
            paymentEffectHandle: paymentEffectHandle(_:_:),
            processPayment: processPayment(_:_:)
        )
    }
}

extension AnywayTransactionEffectHandlerMicroServicesComposer {
    
    typealias NanoServices = AnywayTransactionEffectHandlerNanoServices
    typealias MicroServices = AnywayTransactionEffectHandlerMicroServices
}

private extension AnywayTransactionEffectHandlerMicroServicesComposer {
    
    func initiatePayment(
        _ digest: AnywayPaymentDigest,
        _ completion: @escaping MicroServices.ProcessCompletion
    ) {
#warning("FIXME")
    }
    
    func makePayment(
        _ code: VerificationCode,
        _ completion: @escaping MakePaymentCompletion
    ) {
        nanoServices.makeTransfer(code) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .none:
                completion(nil)
                
            case let .some(response):
                getDetails(response, completion)
            }
        }
    }
    
    typealias MakePaymentCompletion = MicroServices.MakePaymentCompletion
    
    private func getDetails(
        _ response: NanoServices.MakeTransferResponse,
        _ completion: @escaping MakePaymentCompletion
    ) {
        nanoServices.getDetails(response.detailID) { [weak self] in
            
            guard self != nil else { return }
            
            completion(response.makeTransactionReport(with: $0))
        }
    }
    
    func paymentEffectHandle(
        _ effect: AnywayPaymentEffect,
        _ dispatch: @escaping MicroServices.PaymentDispatch
    ) {
#warning("FIXME")
        fatalError()
    }
    
    func processPayment(
        _ digest: AnywayPaymentDigest,
        _ completion: @escaping MicroServices.ProcessCompletion
    ) {
#warning("FIXME")
        fatalError()
    }
}

private extension AnywayTransactionEffectHandlerNanoServices.MakeTransferResponse {
    
    func makeTransactionReport(
        with operationDetails: OperationDetails?
    ) -> TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails>> {
        
        switch operationDetails {
        case .none:
            return .init(
                status: status,
                info: .detailID(detailID)
            )
            
        case let .some(operationDetails):
            return .init(
                status: status,
                info: .details(operationDetails)
            )
        }
    }
}
