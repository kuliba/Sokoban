//
//  CertificateClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

import PinCodeUI

typealias CertificateClient = CheckCertificateClient & ActivateCertificateClient & ConfirmWithOtpClient & ShowCVVClient & PinConfirmationCodeClient & ChangePinClient

protocol CheckCertificateClient {
    
    typealias CheckCertificateResult = Result<Void, CVVPinError.CheckError>
    typealias CheckCertificateCompletion = (CheckCertificateResult) -> Void
    
    func checkCertificate(completion: @escaping CheckCertificateCompletion)
}

protocol ActivateCertificateClient {
    
    typealias ActivateCertificateResult = Result<PinCodeUI.PhoneDomain.Phone, CVVPinError.ActivationError>
    typealias ActivateCertificateCompletion = (ActivateCertificateResult) -> Void
    
    func activateCertificate(completion: @escaping ActivateCertificateCompletion)
}

protocol ConfirmWithOtpClient {
    
    typealias ConfirmationResult = Result<Void, CVVPinError.OtpError>
    typealias ConfirmationCompletion = (ConfirmationResult) -> Void
    
    func confirmWith(otp: String, completion: @escaping ConfirmationCompletion)
}

protocol ShowCVVClient {

    typealias CVV = ProductView.ViewModel.CardInfo.CVV
    typealias ShowCVVResult = Result<CVV, CVVPinError.ShowCVVError>
    typealias ShowCVVCompletion = (ShowCVVResult) -> Void
    
    func showCVV(cardId: Int, completion: @escaping ShowCVVCompletion)
}

protocol ChangePinClient {
    
    typealias ChangePINResult = Result<Void, CVVPinError.ChangePinError>
    typealias ChangePINCompletion = (ChangePINResult) -> Void
    
    func changePin(
        cardId: Int,
        newPin:String,
        otp: String,
        completion: @escaping ChangePINCompletion
    )
}

protocol PinConfirmationCodeClient {
    
    typealias GetPinConfirmCodeResult = Result<String, CVVPinError.PinConfirmationError>
    typealias GetPinConfirmCodeCompletion = (GetPinConfirmCodeResult) -> Void
    
    func getPinConfirmCode(completion: @escaping GetPinConfirmCodeCompletion)
}
