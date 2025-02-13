//
//  RootViewModelFactory+makeCreateDraftCollateralLoanApplicationBinder.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import AnywayPaymentBackend
import AnywayPaymentCore
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingGetConsentsBackend
import CollateralLoanLandingGetShowcaseUI
import Combine
import Foundation
import GenericRemoteService
import InputComponent
import OTPInputComponent
import PDFKit
import RemoteServices

extension RootViewModelFactory {
    
    private typealias Domain = CreateDraftCollateralLoanApplicationDomain

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
    ) -> Domain.Content {
        
        let reducer = Domain.Reducer<Domain.Confirmation>(data: data)
        let effectHandler = Domain.EffectHandler(
            createDraftApplication: createDraftApplication(payload:completion:),
            getVerificationCode: getVerificationCode(completion:),
            saveConsents: saveConsents,
            confirm: { event in
                
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
    }
    
    private func makeTimedOTPInputViewModel(
        timerDuration: Int,
        otpLength: Int,
        notify: @escaping (Domain.Event) -> Void
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
        completion: @escaping (Domain.CreateDraftApplicationResult) -> Void
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
        completion: @escaping (Domain.GetVerificationCodeResult) -> Void
    ) {
        let getVerificationCode = nanoServiceComposer.compose(
            createRequest: Vortex.RequestFactory.createGetVerificationCodeRequest,
            mapResponse: AnywayPaymentBackend.ResponseMapper.mapGetVerificationCodeResponse
        )
                
        getVerificationCode(()) { [getVerificationCode] in
            
            completion($0.map(\.resendOTPCount).mapError { .init(message: $0.localizedDescription) })
            _ = getVerificationCode
        }
    }

    private func saveConsents(
        payload: CollateralLandingApplicationSaveConsentsPayload,
        completion: @escaping (Domain.SaveConsentsResult) -> Void
    ) {
        let saveConsents = nanoServiceComposer.compose(
            createRequest: RequestFactory.createSaveConsentsRequest(with:),
            mapResponse: RemoteServices.ResponseMapper.mapSaveConsentsResponse(_:_:)
        )
        
        saveConsents (payload.payload) { [saveConsents] in
            
            completion($0.map(\.response).mapError{ .init(message: $0.localizedDescription) })
            _ = saveConsents
        }
    }

    // MARK: - Flow
    
    private func getNavigation(
        select: Domain.Select,
        notify: @escaping Domain.Notify,
        completion: @escaping (Domain.Navigation) -> Void
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
        navigation: Domain.Navigation
    ) -> Delay {
  
        switch navigation {
        case .failure(_):
            return .milliseconds(100)
            
        case .success(_):
            return .milliseconds(100)
        }
    }
}

private extension CreateDraftCollateralLoanApplicationDomain.LoadResultFailure {
    
    init(
        error: RemoteServiceErrorOf<RemoteServices.ResponseMapper.MappingError>
    ) {
        if case let .mapResponse(response) = error,
           case let .server(_, errorMessage) = response
        {

            self = Self(message: errorMessage)
        } else {

            self = Self(message: error.localizedDescription)
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

extension CollateralLandingApplicationGetConsentsPayload {
    
    var payload: RemoteServices.RequestFactory.GetConsentsPayload {
        
        .init(
            cryptoVersion: cryptoVersion,
            applicationId: applicationID,
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
            term: term,
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
