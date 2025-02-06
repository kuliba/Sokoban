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
import GenericRemoteService
import InputComponent
import OTPInputComponent
import RemoteServices

extension RootViewModelFactory {
    
    func makeCreateDraftCollateralLoanApplicationBinder(
        payload: CreateDraftCollateralLoanApplicationUIData
    ) -> CreateDraftCollateralLoanApplicationDomain.Binder {

        let content = makeDraftContent(data: payload)

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
    
    private func makeDraftContent(
        data: CreateDraftCollateralLoanApplicationUIData
    ) -> CreateDraftCollateralLoanApplicationDomain.Content {
        
        let reducer = Domain.Reducer<Confirmation>(data: data)
        let effectHandler = Domain.EffectHandler(
            createDraftApplication: createDraftApplication(payload:completion:),
            getVerificationCode: getVerificationCode(completion:),
            saveConsents: {
                payload, completion in
                
                // TODO: Restore
                // saveConsents(payload:completion:)
                // TODO: Remove stub
                completion(.success(.preview))
            },
            confirm: { [weak self] event in
                
                guard let self else { return }
                
                let model = self.makeTimedOTPInputViewModel(
                    timerDuration: self.settings.otpDuration,
                    otpLength: self.settings.otpLength,
                    notify: event
                )
                
                event(.confirmed(.init(otpViewModel: model)))
            }
        )

        return .init(
            initialState: .init(data: data),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:),
            scheduler: schedulers.main
        )
        
        typealias Domain = CreateDraftCollateralLoanApplicationDomain
        typealias Confirmation = Domain.Confirmation
    }
    
    func makeTimedOTPInputViewModel(
        timerDuration: Int,
        otpLength: Int,
        notify: @escaping (CreateDraftCollateralLoanApplicationDomain.Event<CreateDraftCollateralLoanApplicationDomain.Confirmation>) -> Void
    ) -> TimedOTPInputViewModel {
                
        let countdownReducer = CountdownReducer(duration: timerDuration)
        
        let decorated: OTPInputReducer.CountdownReduce = { otpState, otpEvent in
            
            if case (.completed, .start) = (otpState, otpEvent) {
                notify(.getVerificationCode)
            }
            
            return countdownReducer.reduce(otpState, otpEvent)
        }
        
        let otpFieldReducer = OTPFieldReducer(length: otpLength)
        
        let decoratedOTPFieldReduce: OTPInputReducer.OTPFieldReduce = { state, event in
            
            switch event {
            case let .edit(text):
                let text = text.filter(\.isWholeNumber).prefix(otpLength)
                return otpFieldReducer.reduce(state, .edit(.init(text)))
            case .otpValidated:
                notify(.otpValidated)
                return otpFieldReducer.reduce(state, event)
            default:
                return otpFieldReducer.reduce(state, event)
            }
        }
        
        let otpInputReducer = OTPComponentInputReducer(
            countdownReduce: decorated,
            otpFieldReduce : decoratedOTPFieldReduce
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: { _ in })
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: { _,_ in })
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))
        
        return TimedOTPInputViewModel(
            initialState: .starting(
                phoneNumber: "",
                duration: timerDuration,
                text: ""
            ),
            reduce: otpInputReducer.reduce(_:_:),
            handleEffect: otpInputEffectHandler.handleEffect(_:_:),
            timer: RealTimer(),
            observe: { notify(.otp($0)) },
            scheduler: .makeMain()
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
        
        .init(
            applicationID: applicationID
        )
    }
}
