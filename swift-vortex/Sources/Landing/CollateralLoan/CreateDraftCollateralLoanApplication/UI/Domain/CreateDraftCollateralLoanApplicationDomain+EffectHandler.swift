//
//  CreateDraftCollateralLoanApplicationDomain+EffectHandler.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

extension CreateDraftCollateralLoanApplicationDomain {
    
    public final class EffectHandler {

        private let createDraftApplication: CreateDraftApplication
        private let saveConsents: SaveConsents
        private let showSaveConsentsResult: ShowSaveConsentsResult

        public init(
            createDraftApplication: @escaping CreateDraftApplication,
            saveConsents: @escaping SaveConsents,
            showSaveConsentsResult: @escaping ShowSaveConsentsResult
        ) {
            self.createDraftApplication = createDraftApplication
            self.saveConsents = saveConsents
            self.showSaveConsentsResult = showSaveConsentsResult
        }
        
        public func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {
            
            switch effect {
            case let .createDraftApplication(payload):
                createDraftApplication(payload) { dispatch(.applicationCreated($0)) }
                
            case let .saveConsents(payload):
                saveConsents(payload) { dispatch(.showSaveConsentsResult($0)) }

            case let .showSaveConsentsResult(saveConsentsResult):
                showSaveConsentsResult(saveConsentsResult)
            }
        }

        public typealias Dispatch = (Event) -> Void
        public typealias CreateDraftApplicationPayload = CollateralLandingApplicationCreateDraftPayload
        public typealias SaveConsentsPayload = CollateralLandingApplicationSaveConsentsPayload
        public typealias CreateDraftApplication = (CreateDraftApplicationPayload, @escaping CreateDraftApplicationCompletion) -> Void
        public typealias SaveConsents = (SaveConsentsPayload, @escaping SaveConsentsCompletion) -> Void
        public typealias ShowSaveConsentsResult = (SaveConsentsResult) -> Void
        public typealias CreateDraftApplicationCompletion = (CreateDraftApplicationResult) -> Void
        public typealias SaveConsentsCompletion = (SaveConsentsResult) -> Void
    }
}
