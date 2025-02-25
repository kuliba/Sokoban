//
//  CreateDraftCollateralLoanApplicationDomain+EffectHandler.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

extension CreateDraftCollateralLoanApplicationDomain {
    
    public final class EffectHandler<Confirmation, InformerPayload> {

        private let createDraft: CreateDraft
        private let getVerificationCode: GetVerificationCode
        private let saveConsents: SaveConsents

        public init(
            createDraft: @escaping CreateDraft,
            getVerificationCode: @escaping GetVerificationCode,
            saveConsents: @escaping SaveConsents
        ) {
            self.createDraft = createDraft
            self.getVerificationCode = getVerificationCode
            self.saveConsents = saveConsents
        }
        
        public func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {
            
            switch effect {
            case let .createDraftApplication(payload):
                createDraft(
                    payload,
                    { dispatch(.otpEvent($0)) },
                    { dispatch(.applicationCreated($0)) }
                )
                
            case let .saveConsents(payload):
                saveConsents(payload) {
                    dispatch(.showSaveConsentsResult($0))
                }
                
            case .getVerificationCode:
                getVerificationCode { dispatch(.gettedVerificationCode($0)) }
            }
        }
    }
}

public extension CreateDraftCollateralLoanApplicationDomain.EffectHandler {
    
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias Event = Domain.Event<Confirmation, InformerPayload>
    typealias OTPEvent = Event.OTPEvent
    typealias Dispatch = (Event) -> Void
    typealias OTPDispatch = (OTPEvent) -> Void

    typealias Payload = CollateralLandingApplicationCreateDraftPayload
    typealias CreateDraftCompletion = (CreateDraftResult) -> Void
    typealias CreateDraftResult = Domain.CreateDraftApplicationCreatedResult<Confirmation, InformerPayload>
    typealias CreateDraft = (Payload, @escaping OTPDispatch, @escaping CreateDraftCompletion) -> Void

    typealias GetVerificationCodeCompletion = (GetVerificationCodeResult) -> Void
    typealias GetVerificationCodeResult = Result<Int, BackendFailure<InformerPayload>>
    typealias GetVerificationCode = (@escaping GetVerificationCodeCompletion) -> Void

    typealias SaveConsentsCompletion = (Domain.SaveConsentsResult<InformerPayload>) -> Void
    typealias SaveConsentsPayload = CollateralLandingApplicationSaveConsentsPayload
    typealias SaveConsents = (SaveConsentsPayload, @escaping SaveConsentsCompletion) -> Void
}
