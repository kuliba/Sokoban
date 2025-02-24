//
//  CreateDraftCollateralLoanApplicationDomain+EffectHandler.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

extension CreateDraftCollateralLoanApplicationDomain {
    
    public final class EffectHandler<Confirmation, InformerPayload> {

        private let createDraftApplication: CreateDraftApplication
        private let getVerificationCode: GetVerificationCode
        private let saveConsents: SaveConsents

        public init(
            createDraftApplication: @escaping CreateDraftApplication,
            getVerificationCode: @escaping GetVerificationCode,
            saveConsents: @escaping SaveConsents
        ) {
            self.createDraftApplication = createDraftApplication
            self.getVerificationCode = getVerificationCode
            self.saveConsents = saveConsents
        }
        
        public func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {
            
            switch effect {
            case let .createDraftApplication(payload):
                createDraftApplication(
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
    typealias Event = Domain.Event
    typealias Dispatch = (Event<Confirmation, InformerPayload>) -> Void
    typealias CreateDraftApplicationPayload = CollateralLandingApplicationCreateDraftPayload
    typealias SaveConsentsPayload = CollateralLandingApplicationSaveConsentsPayload
    typealias GetVerificationCode = (@escaping GetVerificationCodeCompletion) -> Void
    typealias GetVerificationCodeCompletion = (GetVerificationCodeResult) -> Void
    typealias GetVerificationCodeResult = Result<Int, BackendFailure<InformerPayload>>
    typealias SaveConsentsCompletion = (Domain.SaveConsentsResult<InformerPayload>) -> Void
    typealias SaveConsents = (SaveConsentsPayload, @escaping SaveConsentsCompletion) -> Void
    typealias CreateDraftApplicationCompletion
        = (Domain.CreateDraftApplicationCreatedResult<Confirmation, InformerPayload>) -> Void
    typealias CreateDraftApplication = (
        CreateDraftApplicationPayload,
        @escaping (Event<Confirmation, InformerPayload>.OTPEvent) -> Void,
        @escaping CreateDraftApplicationCompletion
    ) -> Void
}
