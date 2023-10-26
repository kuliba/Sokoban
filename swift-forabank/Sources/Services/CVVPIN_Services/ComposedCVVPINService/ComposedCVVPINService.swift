//
//  ComposedCVVPINService.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

public final class ComposedCVVPINService {
    
    public typealias Activate = (@escaping CVVPINFunctionalityActivationService.ActivationCompletion) -> Void
    public typealias ChangePIN = (ChangePINService.CardID, ChangePINService.PIN, ChangePINService.OTP, @escaping ChangePINService.ChangePINCompletion) -> Void
    public typealias CheckActivation = (@escaping CVVPINFunctionalityCheckingService.Activate, @escaping CVVPINFunctionalityCheckingService.Completion) -> Void
    public typealias ConfirmActivation = (CVVPINFunctionalityActivationService.OTP, @escaping CVVPINFunctionalityActivationService.ConfirmationCompletion) -> Void
    public typealias GetPINConfirmationCode = (@escaping ChangePINService.PINConfirmCompletion) -> Void
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
