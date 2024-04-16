//
//  TransactionPerformer.swift
//
//
//  Created by Igor Malyarov on 24.03.2024.
//

public final class TransactionPerformer<DocumentStatus, OperationDetails> {
    
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
    
    typealias Report = TransactionReport<DocumentStatus, OperationDetails>
    typealias PaymentOperationDetailID = Report.Details.PaymentOperationDetailID
    
    typealias GetDetailsResult = OperationDetails?
    typealias GetDetailsCompletion = (GetDetailsResult) -> Void
    typealias GetDetails = (PaymentOperationDetailID, @escaping GetDetailsCompletion) -> Void
    
    typealias MakeTransferResult = MakeTransferResponse?
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (VerificationCode, @escaping MakeTransferCompletion) -> Void
    
    typealias ProcessResult = TransactionReport<DocumentStatus, OperationDetails>?
    typealias Completion = (ProcessResult) -> Void
}

extension TransactionPerformer {
    
    public struct MakeTransferResponse {
        
        public let documentStatus: DocumentStatus
        public let paymentOperationDetailID: PaymentOperationDetailID
        
        public init(
            documentStatus: DocumentStatus,
            paymentOperationDetailID: PaymentOperationDetailID
        ) {
            self.documentStatus = documentStatus
            self.paymentOperationDetailID = paymentOperationDetailID
        }
    }
}

extension TransactionPerformer.MakeTransferResponse: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable {}

private extension TransactionPerformer {
    
    func getDetails(
        _ response: MakeTransferResponse,
        _ completion: @escaping Completion
    ) {
        getDetails(response.paymentOperationDetailID) { [weak self] in
            
            guard self != nil else { return }
            
            completion(.init(response: response, operationDetails: $0))
        }
    }
}

private extension TransactionReport {
    
    init(
        response: TransactionPerformer<DocumentStatus, OperationDetails>.MakeTransferResponse,
        operationDetails: OperationDetails?
    ) {
        switch operationDetails {
        case .none:
            self.documentStatus = response.documentStatus
            self.details = .paymentOperationDetailID(response.paymentOperationDetailID)
            
            
        case let .some(operationDetails):
            self.documentStatus = response.documentStatus
            self.details = .operationDetails(operationDetails)
        }
    }
}
