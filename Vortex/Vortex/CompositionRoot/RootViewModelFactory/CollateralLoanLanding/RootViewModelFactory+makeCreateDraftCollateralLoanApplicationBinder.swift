//
//  RootViewModelFactory+makeCreateDraftCollateralLoanApplicationBinder.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import AnywayPaymentBackend
import AnywayPaymentCore
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import Combine
import Foundation
import InputComponent
import RemoteServices
import GenericRemoteService

extension RootViewModelFactory {
    
    func makeCreateDraftCollateralLoanApplicationBinder(
        payload: CreateDraftCollateralLoanApplicationUIData
    ) -> CreateDraftCollateralLoanApplicationDomain.Binder {

        let content = makeContent(data: payload)

        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .init(
                emitting: { content in content.$state
                    .compactMap(\.saveConsentsResult)
                    .map { .select(.showSaveConsentsResult($0)) }
                    .eraseToAnyPublisher()
                },
                dismissing: { _ in {} }
            )
        )
    }

    // MARK: - Content
    
    private func makeContent(
        data: CreateDraftCollateralLoanApplicationUIData
    ) -> CreateDraftCollateralLoanApplicationDomain.Content {
        
        let reducer = CreateDraftCollateralLoanApplicationDomain.Reducer(data: data)
        let effectHandler = CreateDraftCollateralLoanApplicationDomain.EffectHandler(
            createDraftApplication: createDraftApplication(payload:completion:),
            getVerificationCode: getVerificationCode(completion:),
            saveConsents: { [weak self] payload, completion in
            
                guard let self else { return }
                // TODO: Restore
                self.saveConsents(payload: payload) {
                    completion($0)
                }
                // TODO: Remove stub
//                completion(.success(.preview))
            }
        )
        
        return .init(
            initialState: .init(data: data),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:),
            scheduler: schedulers.main
        )
    }
    
    private func createDraftApplication(
        payload: CollateralLandingApplicationCreateDraftPayload,
        completion: @escaping (CreateDraftCollateralLoanApplicationDomain.CreateDraftApplicationResult) -> Void
    ) {
        let createDraftApplication = nanoServiceComposer.compose(
            createRequest: RequestFactory.createCreateDraftCollateralLoanApplicationRequest(with:),
            mapResponse: RemoteServices.ResponseMapper.mapCreateDraftCollateralLoanApplicationResponse(_:_:)
        )
        
        createDraftApplication(payload.payload) { [createDraftApplication] in
  
            completion($0.map { .init(applicationID: $0.applicationID) }
                .mapError { .init(message: $0.localizedDescription) })
            _ = createDraftApplication
        }
    }

    private func getVerificationCode(
        completion: @escaping (CreateDraftCollateralLoanApplicationDomain.GetVerificationCodeResult) -> Void
    ) {
        let getVerificationCode = nanoServiceComposer.compose(
            createRequest: Vortex.RequestFactory.createGetVerificationCodeRequest,
            mapResponse: AnywayPaymentBackend.ResponseMapper.mapGetVerificationCodeResponse
        )
                
        getVerificationCode(()) { [getVerificationCode] in
            
            // TODO: Реализовать показ ошибок согласно дизайна
            completion($0.map(\.resendOTPCount).mapError { .init(message: $0.localizedDescription) })
            _ = getVerificationCode
        }
    }
    
    private func saveConsents(
        payload: CollateralLandingApplicationSaveConsentsPayload,
        completion: @escaping (CreateDraftCollateralLoanApplicationDomain.SaveConsentsResult) -> Void
    ) {
        let saveConsents = nanoServiceComposer.compose(
            createRequest: RequestFactory.createSaveConsentsRequest(with:),
            mapResponse: RemoteServices.ResponseMapper.mapSaveConsentsResponse(_:_:),
            mapError: { CreateDraftCollateralLoanApplicationDomain.LoadResultFailure.init(error: $0) }
        )
        
        saveConsents(payload.payload) { [saveConsents] in
            
            completion($0.map(\.response).mapError { $0 })
            _ = saveConsents
        }
    }

    // MARK: - Flow
    
    private func getNavigation(
        select: CreateDraftCollateralLoanApplicationDomain.Select,
        notify: @escaping CreateDraftCollateralLoanApplicationDomain.Notify,
        completion: @escaping (CreateDraftCollateralLoanApplicationDomain.Navigation) -> Void
    ) {
        switch select {
        case let .showSaveConsentsResult(saveConsentsResult):
            switch saveConsentsResult {
            case let .failure(failure):
                completion(.failure(failure.message))
                
            case let .success(success):
                completion(.success(success))
            }
        }
    }

    private func delayProvider(
        navigation: CreateDraftCollateralLoanApplicationDomain.Navigation
    ) -> Delay {
  
        switch navigation {
        case .failure(_):
            return .milliseconds(100)
            
        case .success(_):
            return .milliseconds(100)
        }
    }
}

extension CreateDraftCollateralLoanApplicationDomain.LoadResultFailure {
    
    init(
        error: RemoteServiceErrorOf<RemoteServices.ResponseMapper.MappingError>
    ) {
        switch error {
            
        case let .createRequest(createRequestError):
            self = Self(error: .createRequest(createRequestError))
            
        case let .performRequest(performRequestError):
            self = Self(error: .performRequest(performRequestError))
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
            case .invalid:
                self = Self(message: error.localizedDescription)
                
            case .server(_, errorMessage: let errorMessage):
                self = Self(message: errorMessage)
            }
        }
    }
}

// MARK: Adapters

extension CollateralLandingApplicationCreateDraftPayload {
    
    var payload: RemoteServices.RequestFactory.CreateDraftCollateralLoanApplicationPayload {
        
        .init(
            name: name,
            amount: amount,
            termMonth: termMonth,
            collateralType: collateralType,
            interestRate: interestRate,
            collateralInfo: collateralInfo,
            cityName: cityName,
            payrollClient: payrollClient
        )
    }
}

extension CollateralLandingApplicationSaveConsentsPayload {
    
    var payload: RemoteServices.RequestFactory.SaveConsentsPayload {
        
        .init(
            applicationID: applicationID,
            verificationCode: verificationCode
        )
    }
}

extension RemoteServices.ResponseMapper.CollateralLoanLandingSaveConsentsResponse {
    
    var response: CollateralLandingApplicationSaveConsentsResult {
        
        .init(
            applicationID: applicationID,
            name: name,
            amount: amount,
            termMonth: termMonth,
            collateralType: collateralType,
            interestRate: interestRate,
            collateralInfo: collateralInfo,
            documents: documents,
            cityName: cityName,
            status: status,
            responseMessage: responseMessage
        )
    }
}

extension RemoteServices.ResponseMapper.CreateDraftCollateralLoanApplicationData {
    
    func submitResult(_ applicationID: UInt) -> CollateralLandingApplicationCreateDraftResult {
        
        .init(applicationID: applicationID)
    }
}
