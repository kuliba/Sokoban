//
//  RootViewModelFactory+makeUserAccountNavigationStateManager.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import FastPaymentsSettings
import Foundation
import ManageSubscriptionsUI
import OTPInputComponent
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeUserAccountNavigationStateManager(
        fastPaymentsFactory: FastPaymentsFactory
    ) -> UserAccountNavigationStateManager {
        
        return makeNavigationStateManager(
            modelEffectHandler: .init(model: model),
            otpServices: .init(httpClient, logger),
            otpDeleteBankServices: .init(for: httpClient, infoNetworkLog),
            fastPaymentsFactory: fastPaymentsFactory,
            makeSubscriptionsViewModel: makeSubscriptionsViewModel
        )
    }
}

// MARK: - Adapters

private extension UserAccountModelEffectHandler {
    
    convenience init(model: Model) {
        
        self.init(
            cancelC2BSub: { (token: SubscriptionViewModel.Token) in
                
                let action = ModelAction.C2B.CancelC2BSub.Request(token: token)
                model.action.send(action)
            },
            deleteRequest: {
                
                model.action.send(ModelAction.ClientInfo.Delete.Request())
            },
            exit: {
                
                model.auth.value = .unlockRequiredManual
            }
        )
    }
}

private extension FastPaymentsSettingsOTPServices {
    
    init(
        _ httpClient: HTTPClient,
        _ logger: any LoggerAgentProtocol
    ) {
        let composer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: logger
        )
        
        self.init(
            initiateOTP: composer.composeFastInitiateOTP(),
            submitOTP: composer.composeFastSubmitOTP(),
            prepareSetBankDefault: composer.composeFastSetBankDefault()
        )
    }
}

extension FastPaymentsSettingsOTPServices {
    
    init(
        for httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) {
        typealias ServiceFailure = OTPInputComponent.ServiceFailure
        
        typealias VortexRequestFactory = Vortex.RequestFactory
        typealias FastResponseMapper = RemoteServices.ResponseMapper
        
        let initiateOTP = adaptedLoggingFetch(
            VortexRequestFactory.createPrepareDeleteDefaultBankRequest,
            FastResponseMapper.mapPrepareDeleteBankDefaultResponse(_:_:),
            mapError: OTPInputComponent.ServiceFailure.init(error:)
        )
        
        let submitOTP: OTPFieldEffectHandler.SubmitOTP = adaptedLoggingFetch(
            mapPayload: { .init($0.rawValue) },
            VortexRequestFactory.createMakeDeleteBankDefaultRequest(payload:),
            FastResponseMapper.mapMakeDeleteBankDefaultResponse(_:_:),
            mapError: ServiceFailure.init(error:)
        )
        
        let prepareSetBankDefault = adaptedLoggingFetch(
            VortexRequestFactory.createPrepareSetBankDefaultRequest,
            FastResponseMapper.mapPrepareSetBankDefaultResponse,
            mapError: FastPaymentsSettings.ServiceFailure.init(error:)
        )
        
        self.init(
            initiateOTP: initiateOTP,
            submitOTP: submitOTP,
            prepareSetBankDefault: prepareSetBankDefault
        )
        
        func adaptedLoggingFetch<Output, MappingError: Error, Failure: Error>(
            _ createRequest: @escaping () throws -> URLRequest,
            _ mapResponse: @escaping NanoServices.MapResponse<Output, MappingError>,
            mapError: @escaping NanoServices.MapError<MappingError, Failure>,
            file: StaticString = #file,
            line: UInt = #line
        ) -> NanoServices.VoidFetch<Output, Failure> {
            
            NanoServices.adaptedLoggingFetch(
                createRequest: createRequest,
                httpClient: httpClient,
                mapResponse: mapResponse,
                mapError: mapError,
                log: log,
                file: file,
                line: line
            )
        }
        
        func adaptedLoggingFetch<Payload, Input, Output, MappingError: Error, Failure: Error>(
            mapPayload: @escaping (Payload) -> Input,
            _ createRequest: @escaping (Input) throws -> URLRequest,
            _ mapResponse: @escaping NanoServices.MapResponse<Output, MappingError>,
            mapError: @escaping NanoServices.MapError<MappingError, Failure>,
            file: StaticString = #file,
            line: UInt = #line
        ) -> NanoServices.Fetch<Payload, Output, Failure> {
            
            NanoServices.adaptedLoggingFetch(
                createRequest: { try createRequest(mapPayload($0)) },
                httpClient: httpClient,
                mapResponse: mapResponse,
                mapError: mapError,
                log: log,
                file: file,
                line: line
            )
        }
    }
}

private extension OTPInputComponent.ServiceFailure {
    
    init(
        error: RemoteServiceErrorOf<RemoteServices.ResponseMapper.MappingError>
    ) {
        switch error {
        case .createRequest, .performRequest:
            self = .connectivityError
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
            case .invalid:
                self = .connectivityError
                
            case let .server(_, errorMessage):
                self = .serverError(errorMessage)
            }
        }
    }
}

// MARK: - Live Service

private extension LoggingRemoteNanoServiceComposer {
    
    typealias ServiceFailure = OTPInputComponent.ServiceFailure
    
    typealias VortexRequestFactory = Vortex.RequestFactory
    typealias FastResponseMapper = RemoteServices.ResponseMapper
    
    func composeFastInitiateOTP() -> CountdownEffectHandler.InitiateOTP {
        
        let initiateOTP = self.compose(
            createRequest: VortexRequestFactory.createPrepareSetBankDefaultRequest,
            mapResponse: FastResponseMapper.mapPrepareSetBankDefaultResponse,
            mapError: OTPInputComponent.ServiceFailure.init(error:)
        )
        
        return { completion in initiateOTP((), completion) }
    }
    
    func composeFastSubmitOTP() -> OTPFieldEffectHandler.SubmitOTP {
        
        let submitOTP = self.compose(
            createRequest: VortexRequestFactory.createMakeSetBankDefaultRequest,
            mapResponse: FastResponseMapper.mapMakeSetBankDefaultResponse,
            mapError: ServiceFailure.init(error:)
        )
        
        return { otp, completion in submitOTP(.init(otp.rawValue), completion) }
    }
    
    func composeFastSetBankDefault() -> UserAccountNavigationOTPEffectHandler.PrepareSetBankDefault {
        
        let prepareSetBankDefault = self.compose(
            createRequest: VortexRequestFactory.createPrepareSetBankDefaultRequest,
            mapResponse: FastResponseMapper.mapPrepareSetBankDefaultResponse,
            mapError: FastPaymentsSettings.ServiceFailure.init(error:)
        )
        
        return { completion in prepareSetBankDefault((), completion) }
    }
}
