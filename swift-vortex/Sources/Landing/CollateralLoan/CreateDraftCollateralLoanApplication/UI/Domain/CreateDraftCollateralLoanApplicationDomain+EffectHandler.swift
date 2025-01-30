//
//  CreateDraftCollateralLoanApplicationDomain+EffectHandler.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

extension CreateDraftCollateralLoanApplicationDomain {
    
    public final class EffectHandler {

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
                createDraftApplication(payload) { dispatch(.applicationCreated($0)) }
                
            case let .saveConsents(payload):
                saveConsents(payload) { dispatch(.showSaveConsentsResult($0)) }
                
            case .getVerificationCode:
                getVerificationCode { dispatch(.gettedVerificationCode($0)) }
            }
        }

        public typealias Dispatch = (Event) -> Void
        public typealias CreateDraftApplicationPayload = CollateralLandingApplicationCreateDraftPayload
        public typealias SaveConsentsPayload = CollateralLandingApplicationSaveConsentsPayload
        public typealias CreateDraftApplication = (CreateDraftApplicationPayload, @escaping CreateDraftApplicationCompletion) -> Void
        public typealias SaveConsents = (SaveConsentsPayload, @escaping SaveConsentsCompletion) -> Void
        public typealias GetVerificationCode = (@escaping GetVerificationCodeCompletion) -> Void
        public typealias CreateDraftApplicationCompletion = (CreateDraftApplicationResult) -> Void
        public typealias SaveConsentsCompletion = (SaveConsentsResult) -> Void
        public typealias GetVerificationCodeCompletion = (GetVerificationCodeResult) -> Void
        public typealias GetVerificationCodeResult = Result<Int, ServiceFailure>
    }
}
