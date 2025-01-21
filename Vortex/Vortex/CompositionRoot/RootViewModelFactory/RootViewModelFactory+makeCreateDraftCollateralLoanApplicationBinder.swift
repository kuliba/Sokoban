//
//  RootViewModelFactory+makeCreateDraftCollateralLoanApplicationBinder.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import RemoteServices
import Foundation
import Combine

extension RootViewModelFactory {
    
    func makeCreateDraftCollateralLoanApplicationBinder(
        uiData: CreateDraftCollateralLoanApplicationUIData
    ) -> CreateDraftCollateralLoanApplicationDomain.Binder {

        let content = makeContent(uiData: uiData)

        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .empty
        )
    }
    
    // MARK: - Content
    
    private func makeContent(
        uiData: CreateDraftCollateralLoanApplicationUIData
    ) -> CreateDraftCollateralLoanApplicationDomain.Content {
        
        let reducer = CreateDraftCollateralLoanApplicationDomain.Reducer()
        let effectHandler = CreateDraftCollateralLoanApplicationDomain.EffectHandler(
            createDraftApplication: createDraftApplication(payload:completion:),
            saveConsents: saveConsents(payload:completion:),
            showSaveConsentsResult: showSaveConsentsResult(result:)
        )
        
        return .init(
            initialState: .init(data: uiData),
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
  
            completion($0.map(\.submitResult).mapError { _ in .init() })
            _ = createDraftApplication
        }
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
            
            completion($0.map(\.response).mapError { _ in .init() })
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
        case let .submitAnApplication(id):
            completion(.submitAnApplication(id))
        }
    }

    private func delayProvider(
        navigation: CreateDraftCollateralLoanApplicationDomain.Navigation
    ) -> Delay {
  
        switch navigation {
            
        case .submitAnApplication(_):
            return .milliseconds(100)
        }
    }
    
    private func showSaveConsentsResult(result: CreateDraftCollateralLoanApplicationDomain.SaveConsentsResult) {
        
//        let successViewModel = makeCollateralLoanLandingSuccessViewModel()
//        route.modal = .fullScreenSheet(.init(type: .success(successViewModel)))   
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
