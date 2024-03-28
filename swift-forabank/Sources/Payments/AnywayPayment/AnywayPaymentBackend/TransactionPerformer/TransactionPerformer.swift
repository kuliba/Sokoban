//
//  TransactionPerformer.swift
//
//
//  Created by Igor Malyarov on 24.03.2024.
//

public protocol Detailable<DetailsID> {
    
    associatedtype DetailsID
    
    var detailsID: DetailsID { get }
}

public final class TransactionPerformer<Code, Details, MakeTransferResponse: Detailable> {
    
    private let makeTransfer: MakeTransfer
    private let getDetails: GetDetails
    
    public init(
        makeTransfer: @escaping MakeTransfer,
        getDetails: @escaping GetDetails
    ) {
        self.makeTransfer = makeTransfer
        self.getDetails = getDetails
    }
}

public extension TransactionPerformer {
    
    func process(
        _ code: Code,
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
    
    typealias GetDetailsResult = Details?
    typealias GetDetailsCompletion = (GetDetailsResult) -> Void
    typealias DetailsID = MakeTransferResponse.DetailsID
    typealias GetDetails = (DetailsID, @escaping GetDetailsCompletion) -> Void
    
    typealias MakeTransferResult = MakeTransferResponse?
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (Code, @escaping MakeTransferCompletion) -> Void
    
    typealias ProcessResult = ProcessResponse?
    typealias Completion = (ProcessResult) -> Void
}

extension TransactionPerformer {
    
    public struct ProcessResponse {
        
        public let makeTransferResponse: MakeTransferResponse
        public let details: Details?
        
        public init(
            makeTransferResponse: MakeTransferResponse,
            details: Details?
        ) {
            self.makeTransferResponse = makeTransferResponse
            self.details = details
        }
    }
}

extension TransactionPerformer.ProcessResponse: Equatable where MakeTransferResponse: Equatable, Details: Equatable {}

private extension TransactionPerformer {
    
    func getDetails(
        _ response: MakeTransferResponse,
        _ completion: @escaping Completion
    ) {
        getDetails(response.detailsID) { [weak self] in
            
            guard self != nil else { return }
            
            completion(.init(
                makeTransferResponse: response,
                details: $0
            ))
        }
    }
}
