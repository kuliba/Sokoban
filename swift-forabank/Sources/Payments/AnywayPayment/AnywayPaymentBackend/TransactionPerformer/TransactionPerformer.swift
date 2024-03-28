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
            case let .failure(makeTransferError):
                completion(.failure(makeTransferError))
                
            case let .success(response):
                getDetails(response, completion)
            }
        }
    }
}

public extension TransactionPerformer {
    
    typealias GetDetailsResult = Result<Details, Error>
    typealias GetDetailsCompletion = (GetDetailsResult) -> Void
    typealias DetailsID = MakeTransferResponse.DetailsID
    typealias GetDetails = (DetailsID, @escaping GetDetailsCompletion) -> Void
    
    
    typealias MakeTransferResult = Result<MakeTransferResponse, MakeTransferError>
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (Code, @escaping MakeTransferCompletion) -> Void
    
    typealias ProcessResult = Result<ProcessResponse, MakeTransferError>
    typealias Completion = (ProcessResult) -> Void
}

extension TransactionPerformer {
    
    public struct MakeTransferError: Error, Equatable {
        
        public init() {}
    }
    
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
            
            switch $0 {
            case .failure:
                completion(.success(.init(
                    makeTransferResponse: response,
                    details: nil
                )))
                
            case let .success(details):
                completion(.success(.init(
                    makeTransferResponse: response,
                    details: details
                )))
            }
        }
    }
}
