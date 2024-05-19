//
//  TransactionEffectHandlerMicroServicesComposer.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain

final class TransactionEffectHandlerMicroServicesComposer {
    
    private let nanoServices: NanoServices
    
    init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
}

extension TransactionEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiatePayment: initiatePayment,
            makePayment: makePayment,
            paymentEffectHandle: paymentEffectHandle,
            processPayment: processPayment
        )
    }
}

extension TransactionEffectHandlerMicroServicesComposer {
    
    typealias NanoServices = TransactionEffectHandlerNanoServices
    typealias MicroServices = _TransactionEffectHandlerMicroServices
}

private extension TransactionEffectHandlerMicroServicesComposer {
    
    func initiatePayment(
        _ digest: PaymentDigest,
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
        _ effect: PaymentEffect,
        _ dispatch: @escaping MicroServices.PaymentDispatch
    ) {
#warning("FIXME")
    }
    
    func processPayment(
        _ digest: PaymentDigest,
        _ completion: @escaping MicroServices.ProcessCompletion
    ) {
#warning("FIXME")
    }
}

private extension TransactionEffectHandlerNanoServices.MakeTransferResponse {
    
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
