//
//  ComposedCVVPINService+ShowCVVClient.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

import CVVPIN_Services

extension ComposedCVVPINService: ShowCVVClient {
    
    func showCVV(
        cardId: Int,
        completion: @escaping ShowCVVCompletion
    ) {
        showCVV(
            cardID: .init(cardIDValue: cardId)
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map(\.cvvValue)
                    .map { .init($0) }
                    .mapError(CVVPinError.ShowCVVError.init)
            )
        }
    }
}

private extension CVVPinError.ShowCVVError {
    
    init(_ error: ShowCVVService.Error) {
        
        switch error {
        case .invalid:
            self = .check(.connectivity)
            
        case .network:
            self =  .check(.connectivity)
            
        case let .server(_, errorMessage: errorMessage):
            self = .otp(.init(errorMessage: errorMessage, retryAttempts: 0))
            
        case .other:
            self = .check(.certificate)
        }
    }
}
