//
//  ComposedCVVPINService+ShowCVVClient.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

import CVVPIN_Services

extension ComposedCVVPINService: ShowCVVClient {
    
    func showCVV(
        cardId cardID: Int,
        completion: @escaping ShowCVVCompletion
    ) {
        showCVV(
            .init(cardIDValue: cardID)
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map(\.cvvValue)
                    .map { .init($0) }
                    .mapError(ShowCVVError.init)
            )
        }
    }
}

private extension ShowCVVError {
    
    init(_ error: ShowCVVService.Error) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure:
            self = .serviceFailure
            
        case .network:
            self = .serviceFailure
            
        case .invalid:
            self = .serviceFailure
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case .serviceError:
            self = .serviceFailure
        }
    }
}
