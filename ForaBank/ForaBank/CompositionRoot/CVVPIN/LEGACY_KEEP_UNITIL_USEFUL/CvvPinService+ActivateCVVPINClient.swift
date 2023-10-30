//
//  CvvPinService+ActivateCVVPINClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import CvvPin
import Foundation
import PinCodeUI

extension CvvPinService: ActivateCVVPINClient {
    
    typealias ActivateCertificateResult = Result<PhoneDomain.Phone, ActivateCVVPINError>
    typealias ActivateCertificateCompletion = (ActivateCertificateResult) -> Void
    
    func activate(
        completion: @escaping ActivateCertificateCompletion
    ) {
        self.exchangeKey { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
#warning("fix error type: should have message")
                completion(.failure(.serviceFailure))
                
            case .success:
#warning("fix this: should have phone")
                let phone: PhoneDomain.Phone = "+1....77"
                completion(.success(phone))
            }
        }
    }
    
    func confirmWith(
        otp: String,
        completion: @escaping ConfirmationCompletion
    ) {
#warning("fix this")
        completion(.success(()))
    }
}

extension CvvPinService: ShowCVVClient {
    
    typealias CVV = ProductView.ViewModel.CardInfo.CVV
    typealias ShowCVVCompletion = (Result<CVV, ShowCVVError>) -> Void
    
    func showCVV(
        cardId: Int,
        completion: @escaping ShowCVVCompletion
    ) {
#warning("fix this")
        // completion(.success(.init("3")))
        completion(.failure(.serviceFailure))
        // completion(.failure(.check(.connectivity)))
        // completion(.failure(.activation(.init(message: "Возникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения"))))
        // completion(.failure(.otp(.init(errorMessage: "error", retryAttempts: 1))))
        //completion(.failure(.otp(.init(errorMessage: "error", retryAttempts: 0))))
    }
}

extension CvvPinService: ChangePINClient {
    
    typealias CheckCertificateResult = Result<Void, CheckCVVPINFunctionalityError>
    typealias CheckCertificateCompletion = (CheckCertificateResult) -> Void
    
    func checkFunctionality(
        completion: @escaping CheckCertificateCompletion
    ) {
#warning("replace with crypto storage request")
        completion(.failure(.activationFailure))
    }

    typealias BindPublicKeyResult = Result<Void, GetPINConfirmationCodeError>
    typealias BindPublicKeyCompletion = (BindPublicKeyResult) -> Void
    
    func confirmWith(
        otp: String,
        completion: @escaping BindPublicKeyCompletion
    ) {
        confirmExchange(
            withOTP: .init(value: otp)
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .failure(error):
#warning("fix error type: should have real message")
                // alertMessage = (retryAttempts == 0) ? "Возникла техническая ошибка" : "Введен некорректный код.\nПопробуйте еще раз"
                
                completion(.failure(.server(statusCode: -1, errorMessage: error.localizedDescription)))
            case .success:
                completion(.success(()))
            }
        }
    }
    
    func getPINConfirmationCode(
        completion: @escaping (Result<String, GetPINConfirmationCodeError>) -> Void
    ) {
#warning("fix this")
        
        completion(.success("+79630000022"))
    }
    
    typealias ChangePinCompletion = (Result<Void, ChangePINError>) -> Void
    
    func changePin(
        cardId: Int,
        newPin: String,
        otp: String,
        completion: @escaping ChangePinCompletion
    ) {
#warning("fix this")
        completion(.failure(.server(statusCode: 7056, errorMessage: "error")))
        // completion(.success(()))
    }
}
