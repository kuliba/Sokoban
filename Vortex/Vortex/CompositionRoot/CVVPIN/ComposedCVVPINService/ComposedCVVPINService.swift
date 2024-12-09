//
//  ComposedCVVPINService.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.10.2023.
//

import CVVPIN_Services

public final class ComposedCVVPINService {
    
    public typealias ChangePIN = (ChangePINService.CardID, ChangePINService.PIN, ChangePINService.OTP, @escaping ChangePINService.ChangePINCompletion) -> Void
    public typealias CheckActivation = (@escaping (Result<Void, Error>) -> Void) -> Void
    public typealias ConfirmActivation = (BindPublicKeyWithEventIDService.OTP, @escaping BindPublicKeyWithEventIDService.Completion) -> Void
    public typealias GetPINConfirmationCode = (@escaping ChangePINService.GetPINConfirmationCodeCompletion) -> Void
    public typealias InitiateActivation = (@escaping CVVPINInitiateActivationService.ActivateCompletion) -> Void
    public typealias ShowCVV = (ShowCVVService.CardID, @escaping ShowCVVService.Completion) -> Void

    public let changePIN: ChangePIN
    public let checkActivation: CheckActivation
    public let confirmActivation: ConfirmActivation
    public let getPINConfirmationCode: GetPINConfirmationCode
    public let initiateActivation: InitiateActivation
    public let showCVV: ShowCVV
    
    public init(
        changePIN: @escaping ChangePIN,
        checkActivation: @escaping CheckActivation,
        confirmActivation: @escaping ConfirmActivation,
        getPINConfirmationCode: @escaping GetPINConfirmationCode,
        initiateActivation: @escaping InitiateActivation,
        showCVV: @escaping ShowCVV
    ) {
        self.initiateActivation = initiateActivation
        self.changePIN = changePIN
        self.checkActivation = checkActivation
        self.confirmActivation = confirmActivation
        self.getPINConfirmationCode = getPINConfirmationCode
        self.showCVV = showCVV
    }
}
