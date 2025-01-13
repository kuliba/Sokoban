//
//  TransactionEffectHandlerMicroServicesComposer.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

import AnywayPaymentDomain
import Tagged

#warning("move to Composition Root, remove generics")
final class TransactionEffectHandlerMicroServicesComposer<DocumentStatus, OperationDetailID, OperationDetails> {
    
    private let nanoServices: NanoServices
    
    init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
}

extension TransactionEffectHandlerMicroServicesComposer {
    
#warning("fixme, add tests")
    // func compose() -> MicroServices {}
}

extension TransactionEffectHandlerMicroServicesComposer {
    
    typealias _OperationInfo = OperationInfo<OperationDetailID, OperationDetails>
    typealias _TransactionReport = TransactionReport<DocumentStatus, _OperationInfo>
    
#warning("fixme")
    // typealias MicroServices = TransactionEffectHandlerMicroServices
    typealias NanoServices = TransactionEffectHandlerNanoServices<DocumentStatus, OperationDetailID, OperationDetails>
}

private extension TransactionEffectHandlerMicroServicesComposer {
    
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
    
    typealias MakePaymentCompletion = (_TransactionReport?) -> Void
    
    private func getDetails(
        _ response: NanoServices.MakeTransferResponse,
        _ completion: @escaping MakePaymentCompletion
    ) {
        nanoServices.getDetails(response.detailID) { [weak self] in
            
            guard self != nil else { return }
            
            completion(response.makeTransactionReport(with: $0))
        }
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
