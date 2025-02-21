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

extension CreateDraftCollateralLoanApplicationDomain.State {

    var projection: Projection? {
        
        if let failure { return .failure(failure) }

        if let saveConsentsResult { return .success(saveConsentsResult) }
        
        return nil
    }
    
    typealias Projection = Result<
        CollateralLandingApplicationSaveConsentsResult,
        CollateralLoanLandingCreateDraftCollateralLoanApplicationUI.BackendFailure<InformerPayload>
    >
}

extension RootViewModelFactory {
    
    private typealias Domain = CreateDraftCollateralLoanApplicationDomain

    func makeCreateDraftCollateralLoanApplicationBinder(
        payload: CreateDraftCollateralLoanApplication
    ) -> CreateDraftCollateralLoanApplicationDomain.Binder {

        let content = makeContent(application: payload)

        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .init(
                emitting: { $0.$state
                    .compactMap(\.projection)
                    .map { .select(.showSaveConsentsResult($0)) }
                    .eraseToAnyPublisher()
                },
                dismissing: { _ in { content.event(.dismissFailure) } }
            )
        )
    }

    // MARK: - Content
    
    private func makeContent(
        application: CreateDraftCollateralLoanApplication
    ) -> Domain.Content {
        
        let reducer = Domain.Reducer<Confirmation, InformerPayload>(application: application)
        let effectHandler = Domain.EffectHandler<Confirmation, InformerPayload>(
            createDraftApplication: createDraftApplication(payload:otpEvent:completion:),
            getVerificationCode: getVerificationCode(completion:),
            saveConsents: saveConsents
        )

        return .init(
            initialState: .init(application: application),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:),
            scheduler: schedulers.main
        )
    }
    
    private func makeTimedOTPInputViewModel(
        timerDuration: Int,
        otpLength: Int,
        otpEvent: @escaping (Domain.Event<Confirmation, InformerPayload>.OTPEvent) -> Void
    ) -> TimedOTPInputViewModel {
                
        let countdownReducer = CountdownReducer(duration: timerDuration)
        
        let decorated: OTPInputReducer.CountdownReduce = { state, event in
            
            if case (.completed, .start) = (state, event) {
                otpEvent(.getVerificationCode)
            }
            
            return countdownReducer.reduce(state, event)
        }
        
        let otpFieldReducer = OTPFieldReducer(length: otpLength)
        
        let decoratedOTPFieldReduce: OTPInputReducer.OTPFieldReduce = { state, event in
            
            switch event {
            case let .edit(text):
                let text = text.filter(\.isWholeNumber).prefix(otpLength)
                return otpFieldReducer.reduce(state, .edit(.init(text)))
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
            observe: { otpEvent(.otp($0)) },
            scheduler: .makeMain()
        )
    }
    
    private func createDraftApplication(
        payload: CollateralLandingApplicationCreateDraftPayload,
        otpEvent: @escaping (Domain.Event<Confirmation, InformerPayload>.OTPEvent) -> Void,
        completion: @escaping (Domain.CreateDraftApplicationCreatedResult<Confirmation, InformerPayload>) -> Void
    ) {
        let createDraftApplication = nanoServiceComposer.compose(
            createRequest: RequestFactory.createCreateDraftCollateralLoanApplicationRequest(with:),
            mapResponse: RemoteServices.ResponseMapper.mapCreateDraftCollateralLoanApplicationResponse(_:_:),
            mapError: Domain.ContentError.init(error:)
        )
        
        let confirmation = self.makeTimedOTPInputViewModel(
            timerDuration: self.settings.otpDuration,
            otpLength: self.settings.otpLength,
            otpEvent: otpEvent
        )
        
        createDraftApplication(payload.payload) { [createDraftApplication] result in
            
            completion(result.map {
                .init(
                    applicationResult: .success(.init(applicationID: $0.applicationID)),
                    confirmation: confirmation
                )
            })
            _ = createDraftApplication
        }
    }

    private func getVerificationCode(
        completion: @escaping (Domain.GetVerificationCodeResult<InformerData>) -> Void
    ) {
        let getVerificationCode = nanoServiceComposer.compose(
            createRequest: Vortex.RequestFactory.createGetVerificationCodeOrderCardVerifyRequest,
            mapResponse: AnywayPaymentBackend.ResponseMapper.mapGetVerificationCodeResponse,
            mapError: Domain.ContentError.init(error:)
        )
                
        getVerificationCode(()) { [getVerificationCode] in
            
            completion($0.map(\.resendOTPCount))
            _ = getVerificationCode
        }
    }

    private func getConsents(
        payload: CollateralLandingApplicationSaveConsentsPayload,
        completion: @escaping (Domain.SaveConsentsResult<InformerData>) -> Void
    ) {
        let saveConsents = nanoServiceComposer.compose(
            createRequest: RequestFactory.createSaveConsentsRequest(with:),
            mapResponse: RemoteServices.ResponseMapper.mapSaveConsentsResponse(_:_:),
            mapError: Domain.ContentError.init(error:)
        )
        
        let save = schedulers.background.scheduled(saveConsents)

        save(payload.payload) { [saveConsents] in

            completion($0.map { $0.response(verificationCode: payload.verificationCode) })
            _ = saveConsents
        }
    }

    private func saveConsents(
        payload: CollateralLandingApplicationSaveConsentsPayload,
        completion: @escaping (Domain.SaveConsentsResult<InformerData>) -> Void
    ) {
        let saveConsents = nanoServiceComposer.compose(
            createRequest: RequestFactory.createSaveConsentsRequest(with:),
            mapResponse: RemoteServices.ResponseMapper.mapSaveConsentsResponse(_:_:),
            mapError: Domain.ContentError.init(error:)
        )
        
        let save = schedulers.background.scheduled(saveConsents)

        save(payload.payload) { [saveConsents] in

            completion($0.map { $0.response(verificationCode: payload.verificationCode) })
            _ = saveConsents
        }
    }

    // MARK: - Flow
    
    private func getNavigation(
        select: Domain.Select,
        notify: @escaping Domain.Notify,
        completion: @escaping (Domain.Navigation) -> Void
    ){
        switch select {
        case let .showSaveConsentsResult(result):
            switch result {
            case let .success(success):
                completion(.saveConsents(success))

            case let .failure(failure):
                break
            }
        }
    }

    private func delayProvider(
        navigation: Domain.Navigation
    ) -> Delay {
  
        switch navigation {
        case .failure:
            return .milliseconds(100)
            
        case .saveConsents:
            return .milliseconds(100)
        }
    }
    
    typealias Confirmation = CreateDraftCollateralLoanApplicationDomain.Confirmation
    typealias InformerPayload = InformerData
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
    
    func response(verificationCode: String) -> CollateralLandingApplicationSaveConsentsResult {
        
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
            responseMessage: responseMessage,
            verificationCode: verificationCode
        )
    }
}

private extension CreateDraftCollateralLoanApplicationDomain.ContentError {
    
    typealias RemoteError = RemoteServiceError<Error, Error, RemoteServices.ResponseMapper.MappingError>
    
    init(
        error: RemoteError
    ) {
        switch error {
        case let .performRequest(error):
            if error.isNotConnectedToInternetOrTimeout() {
                self = .init(kind: .informer(.init(message: "Проверьте подключение к сети", icon: .wifiOff)))
            } else {
                self = .init(kind: .alert("Попробуйте позже."))
            }
            
        default:
            self = .init(kind: .alert("Попробуйте позже."))
        }
    }
}
