//
//  ComposedCVVPINService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import CVVPIN_Services

public final class ComposedCVVPINService {
    
    public typealias Activate = (@escaping CVVPINFunctionalityActivationService.ActivateCompletion) -> Void
    public typealias ChangePIN = (ChangePINService.CardID, ChangePINService.PIN, ChangePINService.OTP, @escaping ChangePINService.ChangePINCompletion) -> Void
    public typealias CheckActivation = (@escaping (Swift.Result<Void, Swift.Error>) -> Void) -> Void
    public typealias ConfirmActivation = (CVVPINFunctionalityActivationService.OTP, @escaping CVVPINFunctionalityActivationService.ConfirmCompletion) -> Void
    public typealias GetPINConfirmationCode = (@escaping ChangePINService.GetPINConfirmationCodeCompletion) -> Void
    public typealias ShowCVV = (ShowCVVService.CardID, @escaping ShowCVVService.Completion) -> Void

    public let activate: Activate
    public let changePIN: ChangePIN
    public let checkActivation: CheckActivation
    public let confirmActivation: ConfirmActivation
    public let getPINConfirmationCode: GetPINConfirmationCode
    public let showCVV: ShowCVV
    
    public init(
        activate: @escaping Activate,
        changePIN: @escaping ChangePIN,
        checkActivation: @escaping CheckActivation,
        confirmActivation: @escaping ConfirmActivation,
        getPINConfirmationCode: @escaping GetPINConfirmationCode,
        showCVV: @escaping ShowCVV
    ) {
        self.activate = activate
        self.changePIN = changePIN
        self.checkActivation = checkActivation
        self.confirmActivation = confirmActivation
        self.getPINConfirmationCode = getPINConfirmationCode
        self.showCVV = showCVV
    }
}
