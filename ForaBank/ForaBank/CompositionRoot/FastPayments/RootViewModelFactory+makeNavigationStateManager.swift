//
//  RootViewModelFactory+makeNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
import FastPaymentsSettings
import Foundation
import GenericRemoteService
import ManageSubscriptionsUI
import OTPInputComponent
import RemoteServices
import Tagged
import UIPrimitives
import UserAccountNavigationComponent
import ForaTools

extension RootViewModelFactory {
    
    static func makeNavigationStateManager(
        modelEffectHandler: UserAccountModelEffectHandler,
        otpServices: FastPaymentsSettingsOTPServices,
        otpDeleteBankServices: FastPaymentsSettingsOTPServices,
        fastPaymentsFactory: FastPaymentsFactory,
        makeSubscriptionsViewModel: @escaping UserAccountNavigationStateManager.MakeSubscriptionsViewModel,
        duration: Int,
        length: Int = 6,
        log: @escaping (String, StaticString, UInt) -> Void,
        scheduler: AnySchedulerOfDispatchQueue
    ) -> UserAccountNavigationStateManager {
        
        let fpsReducer = ForaBank.UserAccountNavigationFPSReducer()
        let otpReducer = ForaBank.UserAccountNavigationOTPReducer()
        
        let codeObserver = NotificationCenter.default
            .observe(
                notificationName: "otpCode",
                userInfoKey: "otp"
            )
        
        let userAccountReducer = UserAccountReducer(
            fpsReduce: fpsReducer.reduce(_:_:),
            otpReduce: otpReducer.reduce(_:_:)
        )
        
        let otpEffectHandler = UserAccountNavigationOTPEffectHandler(
            makeTimedOTPInputViewModel: {
                
                .init(
                    viewModel: .default(
                        initialState: .starting(
                            phoneNumber: $0,
                            duration: duration
                        ),
                        duration: duration,
                        length: length,
                        initiateOTP: otpServices.initiateOTP,
                        submitOTP: otpServices.submitOTP,
                        scheduler: $1
                    ),
                    codeObserver: codeObserver,
                    scheduler: $1
                )
            },
            makeTimedOTPInputDeleteDefaultBankViewModel: {
                
                .init(
                    viewModel: .default(
                        initialState: .starting(
                            phoneNumber: $0,
                            duration: duration
                        ),
                        duration: duration,
                        length: length,
                        initiateOTP: otpDeleteBankServices.initiateOTP,
                        submitOTP: otpDeleteBankServices.submitOTP,
                        scheduler: $1
                    ),
                    codeObserver: codeObserver,
                    scheduler: $1
                )
            },
            prepareSetBankDefault: otpServices.prepareSetBankDefault,
            scheduler: scheduler
        )
        
        let userAccountEffectHandler = UserAccountEffectHandler(
            handleModelEffect: modelEffectHandler.handleEffect(_:_:),
            handleOTPEffect: otpEffectHandler.handleEffect(_:dispatch:)
        )
        
        return .init(
            fastPaymentsFactory: fastPaymentsFactory,
            makeSubscriptionsViewModel: makeSubscriptionsViewModel,
            reduce: userAccountReducer.reduce(_:_:),
            handleEffect: userAccountEffectHandler.handleEffect(_:_:)
        )
    }
}

struct FastPaymentsSettingsOTPServices {
    
    let initiateOTP: CountdownEffectHandler.InitiateOTP
    let submitOTP: OTPFieldEffectHandler.SubmitOTP
    let prepareSetBankDefault: UserAccountNavigationOTPEffectHandler.PrepareSetBankDefault
}

// MARK: - Live Service

extension LoggingRemoteNanoServiceComposer {

    typealias ServiceFailure = OTPInputComponent.ServiceFailure

    typealias ForaRequestFactory = ForaBank.RequestFactory
    typealias FastResponseMapper = RemoteServices.ResponseMapper
    
    func composeFastInitiateOTP() -> CountdownEffectHandler.InitiateOTP {
        
        let initiateOTP = self.compose(
            createRequest: ForaRequestFactory.createPrepareSetBankDefaultRequest,
            mapResponse: FastResponseMapper.mapPrepareSetBankDefaultResponse,
            mapError: OTPInputComponent.ServiceFailure.init(error:)
        )
        
        return { completion in initiateOTP((), completion) }
    }
    
    func composeFastSubmitOTP() -> OTPFieldEffectHandler.SubmitOTP {
        
        let submitOTP = self.compose(
            createRequest: ForaRequestFactory.createMakeSetBankDefaultRequest,
            mapResponse: FastResponseMapper.mapMakeSetBankDefaultResponse,
            mapError: ServiceFailure.init(error:)
        )
        
        return { otp, completion in submitOTP(.init(otp.rawValue), completion) }
    }
    
    func composeFastSetBankDefault() -> UserAccountNavigationOTPEffectHandler.PrepareSetBankDefault {
        
        let prepareSetBankDefault = self.compose(
            createRequest: ForaRequestFactory.createPrepareSetBankDefaultRequest,
            mapResponse: FastResponseMapper.mapPrepareSetBankDefaultResponse,
            mapError: FastPaymentsSettings.ServiceFailure.init(error:)
        )
        
        return { completion in prepareSetBankDefault((), completion) }
    }
}

/*private*/ extension FastPaymentsSettingsOTPServices {
    
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

        typealias ForaRequestFactory = ForaBank.RequestFactory
        typealias FastResponseMapper = RemoteServices.ResponseMapper
        
        let initiateOTP = adaptedLoggingFetch(
            ForaRequestFactory.createPrepareDeleteDefaultBankRequest,
            FastResponseMapper.mapPrepareDeleteBankDefaultResponse(_:_:),
            mapError: OTPInputComponent.ServiceFailure.init(error:)
        )
        
        let submitOTP: OTPFieldEffectHandler.SubmitOTP = adaptedLoggingFetch(
            mapPayload: { .init($0.rawValue) },
            ForaRequestFactory.createMakeDeleteBankDefaultRequest(payload:),
            FastResponseMapper.mapMakeDeleteBankDefaultResponse(_:_:),
            mapError: ServiceFailure.init(error:)
        )
        
        let prepareSetBankDefault = adaptedLoggingFetch(
            ForaRequestFactory.createPrepareSetBankDefaultRequest,
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

// MARK: - Adapters

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

// MARK: - Helpers

extension Array where Element == FastPaymentContractFullInfoType {
    
    private var phoneNumber: String? {
        
        guard
            let list = first?.fastPaymentContractAttributeList,
            let phoneNumber = list.first?.phoneNumber,
            !phoneNumber.isEmpty
        else { return nil }
        
        return phoneNumber
    }
}

private extension FastPaymentContractFullInfoType {
    
    var hasTripleYes: Bool {
        
        guard let accountAttributeList = fastPaymentContractAccountAttributeList?.first,
              let contractAttributeList = fastPaymentContractAttributeList?.first
        else { return false }
        
        return accountAttributeList.flagPossibAddAccount == .yes
        && contractAttributeList.flagClientAgreementIn == .yes
        && contractAttributeList.flagClientAgreementOut == .yes
    }
    
    var hasTripleNo: Bool {
        
        guard let accountAttributeList = fastPaymentContractAccountAttributeList?.first,
              let contractAttributeList = fastPaymentContractAttributeList?.first
        else { return false }
        
        return accountAttributeList.flagPossibAddAccount == .no
        && contractAttributeList.flagClientAgreementIn == .no
        && contractAttributeList.flagClientAgreementOut == .no
    }
}
