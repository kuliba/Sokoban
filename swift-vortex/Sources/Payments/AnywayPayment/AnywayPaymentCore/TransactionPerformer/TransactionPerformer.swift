//
//  TransactionPerformer.swift
//
//
//  Created by Igor Malyarov on 24.03.2024.
//

import AnywayPaymentDomain

public final class TransactionPerformer<DocumentStatus, OperationDetailID, OperationDetails> {
    
    private let getDetails: GetDetails
    private let makeTransfer: MakeTransfer
    
    public init(
        getDetails: @escaping GetDetails,
        makeTransfer: @escaping MakeTransfer
    ) {
        self.getDetails = getDetails
        self.makeTransfer = makeTransfer
    }
}

public extension TransactionPerformer {
    
    func process(
        _ code: VerificationCode,
        _ completion: @escaping Completion
    ) {
        makeTransfer(code) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .none:
                completion(nil)
                
            case let .some(response):
                getDetails(response, completion)
            }
        }
    }
}

public extension TransactionPerformer {
    
    typealias Report = TransactionReport<DocumentStatus, _OperationInfo>
    typealias _OperationInfo = OperationInfo<OperationDetailID, OperationDetails>
    
    typealias GetDetailsResult = OperationDetails?
    typealias GetDetailsCompletion = (GetDetailsResult) -> Void
    typealias GetDetails = (OperationDetailID, @escaping GetDetailsCompletion) -> Void
    
    typealias MakeTransferResult = MakeTransferResponse?
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (VerificationCode, @escaping MakeTransferCompletion) -> Void
    
    typealias ProcessResult = TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails>>?
    typealias Completion = (ProcessResult) -> Void
}

extension TransactionPerformer {
#warning("reuse generic TransactionReport")
    public struct MakeTransferResponse {
        
        public let status: DocumentStatus
        public let detailID: OperationDetailID
        
        public init(
            status: DocumentStatus,
            detailID: OperationDetailID
        ) {
            self.status = status
            self.detailID = detailID
        }
    }
}

extension TransactionPerformer.MakeTransferResponse: Equatable where DocumentStatus: Equatable, OperationDetailID: Equatable, OperationDetails: Equatable {}

private extension TransactionPerformer {
    
    func getDetails(
        _ response: MakeTransferResponse,
        _ completion: @escaping Completion
    ) {
        getDetails(response.detailID) { [weak self] in
            
            guard self != nil else { return }
            
            completion(response.makeTransactionReport(with: $0))
        }
    }
}

private extension TransactionPerformer.MakeTransferResponse {
    
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
