//
//  InitiateAnywayPaymentMicroService.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.08.2024.
//

@testable import ForaBank

final class InitiateAnywayPaymentMicroService<Source, Payload, Response, Transaction> {
    
    private let parseSource: ParseSource
    private let processPayload: ProcessPayload
    private let initiateTransaction: InitiateTransaction
    
    init(
        parseSource: @escaping ParseSource,
        processPayload: @escaping ProcessPayload,
        initiateTransaction: @escaping InitiateTransaction
    ) {
        self.parseSource = parseSource
        self.processPayload = processPayload
        self.initiateTransaction = initiateTransaction
    }
}

extension InitiateAnywayPaymentMicroService {
    
    typealias ParseSource = (Source) -> Payload?
    
    typealias ProcessPayloadCompletion = (Result<Response, ServiceFailure>) -> Void
    typealias ProcessPayload = (Payload, @escaping ProcessPayloadCompletion) -> Void
    
    typealias InitiateTransaction = (Response) -> Transaction?
    
    typealias ServiceFailure = ServiceFailureAlert.ServiceFailure
}

extension InitiateAnywayPaymentMicroService {
    
    typealias InitiatePaymentResult = Result<Transaction, ServiceFailure>
    typealias Completion = (InitiatePaymentResult) -> Void
    
    func initiatePayment(
        _ source: Source,
        _ completion: @escaping Completion
    ) {
        guard let payload = parseSource(source) else {
            
            return completion(.failure(.connectivityError))
        }
        
        processPayload(payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case let .success(response):
                guard let transaction = initiateTransaction(response) else {
                    
                    return completion(.failure(.connectivityError))
                }
                
                completion(.success(transaction))
            }
        }
    }
}
