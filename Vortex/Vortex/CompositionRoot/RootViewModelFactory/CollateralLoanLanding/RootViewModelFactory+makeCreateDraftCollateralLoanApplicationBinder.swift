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
            saveConsents: { payload, completion in
            
                // TODO: Restore
                // saveConsents(payload:completion:)
                // TODO: Remove stub
                completion(.success(.preview))
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
  
            completion($0.map(\.submitResult).mapError { .init(message: $0.localizedDescription) })
            _ = createDraftApplication
        }
    }

    private func getVerificationCode(
        completion: @escaping (CreateDraftCollateralLoanApplicationDomain.GetVerificationCodeResult) -> Void
    ) {
        
        let getVerificationCode = nanoServiceComposer.compose(
            createRequest: Vortex.RequestFactory.createGetVerificationCodeRequest,
            mapResponse: AnywayPaymentBackend.ResponseMapper.mapGetVerificationCodeResponse,
            mapError: { (error: RemoteServiceError<any Error, any Error, RemoteServices.ResponseMapper.MappingError>) in
                
                NSError(domain: "", code: -1)
            }
        )

        let getVerificationCode = nanoServiceComposer.compose(
            createRequest: Vortex.RequestFactory.createGetVerificationCodeRequest,
            mapResponse: AnywayPaymentBackend.ResponseMapper.mapGetVerificationCodeResponse
        )
        
        getVerificationCode(()) { [getVerificationCode] in
            
            switch $0 {
                
            case let .success(success):
                completion(.success(success.resendOTPCount))
            case let .failure(failure):
                completion(.failure(.init(_error: failure)))
            }
        }
        //            completion($0.map(\.resendOTPCount).mapError { .init($0) })
    }
    
    private func saveConsents(
        payload: CollateralLandingApplicationSaveConsentsPayload,
        completion: @escaping (CreateDraftCollateralLoanApplicationDomain.SaveConsentsResult) -> Void
    ) {
        let saveConsents = nanoServiceComposer.compose(
            createRequest: RequestFactory.createSaveConsentsRequest(with:),
            mapResponse: RemoteServices.ResponseMapper.mapSaveConsentsResponse(_:_:)
        )
        
        saveConsents(payload.payload) { [saveConsents] in
            
            completion($0.map(\.response).mapError { .init(message: $0.localizedDescription) })
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
                completion(.failure(failure.localizedDescription))
                
            case let .success(success):
                completion(.success(String(describing: success)))
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

extension CreateDraftCollateralLoanApplicationDomain.ServiceFailure {
    
    init(_error error: MappingError) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .connectivity
            
        case let .mapResponse(error):
            switch error {
            case .invalid:
                self = .connectivity
                
            case let .server(_, errorMessage: errorMessage):
                self = .serverError(errorMessage)
            }
        }
    }
    
    static let connectivity: Self = .connectivityError("Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже.")
    
    typealias MappingError = MappingRemoteServiceError<RemoteServices.ResponseMapper.MappingError>
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
            applicationId: applicationId,
            verificationCode: verificationCode
        )
    }
}

extension RemoteServices.ResponseMapper.CollateralLoanLandingSaveConsentsResponse {
    
    var response: CollateralLandingApplicationSaveConsentsResult {
        
        .init(
            applicationId: applicationId,
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
    
    var submitResult: CollateralLandingApplicationCreateDraftResult {
        
        .init(applicationId: applicationId)
    }
}
