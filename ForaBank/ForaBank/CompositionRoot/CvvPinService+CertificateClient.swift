//
//  CvvPinService+CertificateClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import CvvPin
import Foundation

extension CvvPinService: CheckCertificateClient {
    
    typealias CheckCertificateResult = Result<Void, CVVPinError.CheckError>
    typealias CheckCertificateCompletion = (CheckCertificateResult) -> Void
    
    func checkCertificate(
        completion: @escaping CheckCertificateCompletion
    ) {
        #warning("replace with crypto storage request")
        completion(.failure(.certificate))
    }
}

extension CvvPinService: ActivateCertificateClient {
    
    typealias ActivateCertificateResult = Result<Void, CVVPinError.ActivationError>
    typealias ActivateCertificateCompletion = (ActivateCertificateResult) -> Void
    
    func activateCertificate(
        completion: @escaping ActivateCertificateCompletion
    ) {
        self.exchangeKey { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                #warning("fix error type: should have message")
                completion(.failure(.init(message: error.localizedDescription)))
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

extension CvvPinService: ConfirmWithOtpClient {
    
    typealias BindPublicKeyResult = Result<Void, CVVPinError.OtpError>
    typealias BindPublicKeyCompletion = (BindPublicKeyResult) -> Void
    
    func comfirmWith(
        otp: String,
        completion: @escaping BindPublicKeyCompletion
    ) {
        confirmExchange(
            withOTP: .init(value: otp)
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .failure(error):
                #warning("fix error type: should have retry attempts")
                completion(.failure(.init(errorMessage: error.localizedDescription, retryAttempts: 1)))
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

extension CvvPinService: ShowCVVClient {
    
    typealias CVV = ProductView.ViewModel.CardInfo.CVV
    typealias ShowCVVCompletion = (Result<CVV, CVVPinError.ShowCVVError>) -> Void

    func showCVV(
        completion: @escaping ShowCVVCompletion
    ) {
#warning("fix this")
        // completion(.success(.init("3")))
        // completion(.failure(.check(.certificate)))
        // completion(.failure(.check(.connectivity)))
        // completion(.failure(.activation(.init(message: "Возникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения"))))
        // completion(.failure(.otp(.init(errorMessage: "error", retryAttempts: 1))))
        completion(.failure(.otp(.init(errorMessage: "error", retryAttempts: 0))))
    }
}
