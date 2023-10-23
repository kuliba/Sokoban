//
//  ComposedCVVPINService.swift
//  
//
//  Created by Igor Malyarov on 21.10.2023.
//

public final class ComposedCVVPINService {
    
    public typealias CVVPINCheckingService = CVVPINFunctionalityCheckingService
    public typealias CVVPINActivationService = CVVPINFunctionalityActivationService
    
    private let cvvPINCheckingService: CVVPINCheckingService
    private let cvvPINActivationService: CVVPINActivationService
    private let showCVVService: ShowCVVService
    private let changePINService: ChangePINService
    
    public init(
        cvvPINCheckingService: CVVPINCheckingService,
        cvvPINActivationService: CVVPINActivationService,
        showCVVService: ShowCVVService,
        changePINService: ChangePINService
    ) {
        self.cvvPINCheckingService = cvvPINCheckingService
        self.cvvPINActivationService = cvvPINActivationService
        self.showCVVService = showCVVService
        self.changePINService = changePINService
    }
}

public extension ComposedCVVPINService {
    
    func checkActivation(
        withFallback activate: @escaping CVVPINCheckingService.Activate,
        completion: @escaping CVVPINCheckingService.Completion
    ) {
        cvvPINCheckingService.checkActivation(withFallback: activate, completion: completion)
    }
    
    func activate(
        completion: @escaping CVVPINActivationService.ActivationCompletion
    ) {
        cvvPINActivationService.activate(completion: completion)
    }
    
    func confirmActivation(
        withOTP otp: CVVPINActivationService.OTP,
        completion: @escaping CVVPINActivationService.ConfirmationCompletion
    ) {
        cvvPINActivationService.confirmActivation(withOTP: otp, completion: completion)
    }
    
    func showCVV(
        cardID: ShowCVVService.CardID,
        completion: @escaping ShowCVVService.Completion
    ) {
        showCVVService.showCVV(cardID: cardID, completion: completion)
    }
    
    func getPINConfirmationCode(
        completion: @escaping ChangePINService.PINConfirmCompletion
    ) {
        changePINService.getPINConfirmationCode(completion: completion)
    }

    func changePIN(
        for cardID: ChangePINService.CardID,
        to pin: ChangePINService.PIN,
        otp: ChangePINService.OTP,
        completion: @escaping ChangePINService.ChangePINCompletion
    ) {
        changePINService.changePIN(for: cardID, to: pin, otp: otp, completion: completion)
    }
}
