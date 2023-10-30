//
//  CVVPINComposer+cvvPINService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

import CVVPINServices
import Foundation
import PinCodeUI

// `CVVPINService` conforms to `CertificateClient` by complying with the protocols of which it is composed.

extension CVVPINComposer: ActivateCVVPINClient {
    
    func activate(
        completion: @escaping ActivateCompletion
    ) {
        fatalError()
    }
    
    func confirmWith(
        otp: String,
        completion: @escaping ConfirmationCompletion
    ) {
        fatalError()
    }
}

extension CVVPINComposer: ShowCVVClient {
    
    func showCVV(
        cardId: Int,
        completion: @escaping ShowCVVCompletion
    ) {
        fatalError()
    }
}

extension CVVPINComposer: ChangePINClient {
    
    // TODO: move implementation to the module and hide fields of CVVPINComposer
    func checkFunctionality(
        completion: @escaping CheckFunctionalityCompletion
    ) {
        infra.loadRSAKeyPair { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.activationFailure))
                
            case .success:
                completion(.success(()))
            }
        }
    }
        
    func getPINConfirmationCode(
        completion: @escaping GetPINConfirmationCodeCompletion
    ) {
        fatalError()
    }
    
    func changePin(
        cardId: Int,
        newPin: String,
        otp: String,
        completion: @escaping ChangePINCompletion
    ) {
        fatalError()
    }
}
