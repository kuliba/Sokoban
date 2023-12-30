//
//  GetConsentListAndDefaultBankServiceAdapter.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

import Tagged

#warning("keep to preserve API; move to compsition root")
extension ComposedGetConsentListAndDefaultBankService: GetConsentListAndDefaultBankService {}

public final class GetConsentListAndDefaultBankServiceAdapter {
    
    public typealias Service = GetConsentListAndDefaultBankService
    
    public typealias LoadCompletion = (DefaultBank) -> Void
    public typealias Load = (@escaping LoadCompletion) -> Void
    
    private let service: Service
    private let load: Load
    
    public init(
        service: Service,
        load: @escaping Load
    ) {
        self.service = service
        self.load = load
    }
}

public extension GetConsentListAndDefaultBankServiceAdapter {
    
    typealias GetConsentListAndDefaultBankResult = Result<GetConsentListAndDefaultBank, GetConsentListAndDefaultBankError>
    typealias Completion = (GetConsentListAndDefaultBankResult) -> Void
    
    func process(
        _ payload: PhoneNumber,
        completion: @escaping Completion
    ) {
        service.process(payload) { [weak self] results in
            
            guard let self else { return }
            
            switch (results.consentListResult, results.defaultBankResult) {
                
                // b1c1, b1c2, b2c1, b2c2
            case let (.success(consentList), .success(defaultBank)):
                completion(.success(.init(
                    consentList: consentList,
                    defaultBank: defaultBank
                )))
                
                // b4c1, b4c2
            case let (.failure(.connectivity), .success(defaultBank)):
                completion(.success(.init(
                    consentList: [],
                    defaultBank: defaultBank
                )))
                
                // b3c1, b3c2
            case let (
                .failure(.server(_, errorMessage: errorMessage)),
                .success(defaultBank)
            ):
                completion(.failure(.server(
                    message: errorMessage,
                    .init(consentList: [], defaultBank: defaultBank)
                )))
                
                // b4c3, b4c4, b4c5
            case let (
                .failure(.connectivity),
                .failure(defaultBankError)
            ):
                handleGetDefaultBankError([], defaultBankError, completion)
                
                // b3c5
            case let (
                .failure(.server(_, errorMessage: errorMessage)),
                .failure(.connectivity)
            ),
                // b3c4
                let (
                    .failure(.server(_, errorMessage: errorMessage)),
                    .failure(.server)
                ):
                handleErrors(errorMessage, completion)
                
                // b3c3
            case let (
                .failure(.server),
                .failure(.limit(message: message))
            ):
                // defaultBankError has higher priority, consentListError is ignored
                handleLimit(message, completion)
               
                // b1c3, b2c3, b1c4, b2c4, b1c5, b2c5
            case let (.success(consentList), .failure(defaultBankError)):
                handleGetDefaultBankError(consentList, defaultBankError, completion)
            }
        }
    }
    
    private func handleErrors(
        _ errorMessage: String,
        _ completion: @escaping Completion
    ) {
        load { [weak self] defaultBank in
            
            guard self != nil else { return }
            
            completion(.failure(.server(
                message: errorMessage,
                .init(consentList: [], defaultBank: defaultBank)
            )))
        }
    }
    
    private func handleLimit(
        _ message: String,
        _ completion: @escaping Completion
    ) {
        load { [weak self] defaultBank in
            
            guard self != nil else { return }
            
            completion(.failure(.limit(
                message: message,
                .init(consentList: [], defaultBank: defaultBank)
            )))
        }
    }
    
    private typealias GetDefaultBankError = GetConsentListAndDefaultBankResults.GetDefaultBankError

    private func handleGetDefaultBankError(
        _ consentList: ConsentList,
        _ defaultBankError: GetDefaultBankError,
        _ completion: @escaping Completion
    ) {
        load { [weak self] defaultBank in
            
            guard self != nil else { return }
            
            switch defaultBankError {
            case .connectivity, .server:
                completion(.success(.init(
                    consentList: consentList,
                    defaultBank: defaultBank
                )))
                
            case let .limit(message):
                completion(.failure(.limit(
                    message: message,
                    .init(
                        consentList: consentList,
                        defaultBank: defaultBank
                    )
                )))
            }
        }
    }
}

public extension GetConsentListAndDefaultBankServiceAdapter {
    
    enum GetConsentListAndDefaultBankError: Error, Equatable {
        
        case limit(message: String, GetConsentListAndDefaultBank)
        case server(message: String, GetConsentListAndDefaultBank)
    }
}

