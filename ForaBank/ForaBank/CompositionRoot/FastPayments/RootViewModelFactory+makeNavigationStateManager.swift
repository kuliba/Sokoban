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
import Tagged
import UIPrimitives
import UserAccountNavigationComponent

extension RootViewModelFactory {
    
    static func makeNavigationStateManager(
        model: Model,
        otpServices: FastPaymentsSettingsOTPServices,
        fastPaymentsFactory: FastPaymentsFactory,
        duration: Int,
        length: Int = 6,
        log: @escaping (String, StaticString, UInt) -> Void,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) -> UserAccountNavigationStateManager {
        
        let fpsReducer = UserAccountNavigationFPSReducer()
        let otpReducer = UserAccountNavigationOTPReducer()
        
        let userAccountReducer = UserAccountReducer(
            fpsReduce: fpsReducer.reduce(_:_:),
            otpReduce: otpReducer.reduce(_:_:)
        )
        
        let modelEffectHandler = UserAccountModelEffectHandler(
            model: model
        )
        
        let otpEffectHandler = UserAccountNavigationOTPEffectHandler(
            makeTimedOTPInputViewModel: {
                
                .init(
                    viewModel: .default(
                        initialState: nil,
                        duration: duration,
                        length: length,
                        initiateOTP: otpServices.initiateOTP,
                        submitOTP: otpServices.submitOTP,
                        scheduler: $0
                    ),
                    scheduler: $0
                )
            },
            prepareSetBankDefault: otpServices.prepareSetBankDefault,
            scheduler: scheduler
        )
        
        let userAccountEffectHandler = UserAccountEffectHandler(
            handleModelEffect: modelEffectHandler.handleEffect(_:_:),
            handleOTPEffect: otpEffectHandler.handleEffect(_:dispatch:)
        )
        
        let _makeSubscriptionsViewModel: UserAccountNavigationStateManager.MakeSubscriptionsViewModel = {
            
            makeSubscriptionsViewModel(
                getProducts: getSubscriptionProducts(
                    model: model,
                    onDelete: $0,
                    onDetail: $1
                ),
                c2bSubscription: model.subscriptions.value,
                scheduler: scheduler
            )
        }
        
        return .init(
            fastPaymentsFactory: fastPaymentsFactory, 
            makeSubscriptionsViewModel: _makeSubscriptionsViewModel,
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

// MARK: - Adapters

private extension UserAccountNavigation.State {
    
    init(_ route: UserAccountRoute) {
        
#warning("ignoring alert state")
        self.init(
            destination: route.fpsRoute,
            alert: nil,
            isLoading: route.spinner != nil
        )
    }
}

private extension UserAccountRoute {
    
    var fpsRoute: UserAccountNavigation.State.FPSRoute? {
        
        guard case let .fastPaymentSettings(.new(fpsRoute)) = link
        else { return nil }
        
        return fpsRoute
    }
}

#warning("both adapters for `UserAccountNavigationFPSReducer` and `UserAccountNavigationOTPReducer` below use the same adaptation pattern")

private extension UserAccountNavigationFPSReducer {
    
    func reduce(
        _ state: UserAccountRoute,
        _ fpsEvent: UserAccountEvent.FastPaymentsSettings
    ) -> (UserAccountRoute, UserAccountEffect?) {
        
        var state = state
        var effect: UserAccountEffect?
        
        switch (state.link, fpsEvent) {
            // case let (.fastPaymentSettings(.new(fpsRoute)), .updated(settings)):
        case let (.fastPaymentSettings(.new), .updated(settings)):
            
            let (fpsState, fpsEffect) = reduce(.init(state), settings)
            state = state.updated(with: fpsState)
            effect = fpsEffect.map(UserAccountEffect.navigation)
            
        default:
            break
        }
        
        return (state, effect)
    }
}

private extension UserAccountNavigationOTPReducer {
    
    func reduce(
        _ state: UserAccountRoute,
        _ event: UserAccountEvent.OTPEvent
    ) -> (UserAccountRoute, UserAccountEffect?) {
        
        var state = state
        var effect: UserAccountEffect?
        
        switch state.link {
            // case let .fastPaymentSettings(.new(fpsRoute)):
        case .fastPaymentSettings(.new):
            
            let (fpsState, fpsEffect) = reduce(.init(state), event)
            state = state.updated(with: fpsState)
            effect = fpsEffect.map(UserAccountEffect.navigation)
            
        default:
            break
        }
        
        return (state, effect)
    }
}

// MARK: - Live Service

/*private*/ extension FastPaymentsSettingsOTPServices {
    
    init(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) {
        typealias ForaRequestFactory = ForaBank.RequestFactory
        typealias FastResponseMapper = FastPaymentsSettings.ResponseMapper
        
        let initiateOTP = adaptedLoggingFetch(
            ForaRequestFactory.createPrepareSetBankDefaultRequest,
            FastResponseMapper.mapPrepareSetBankDefaultResponse,
            mapError: OTPInputComponent.ServiceFailure.init(error:)
        )
        
        let submitOTP: OTPFieldEffectHandler.SubmitOTP = adaptedLoggingFetch(
            mapPayload: { .init($0.rawValue) },
            ForaRequestFactory.createMakeSetBankDefaultRequest,
            FastResponseMapper.mapMakeSetBankDefaultResponse,
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
        error: RemoteServiceErrorOf<FastPaymentsSettings.ResponseMapper.MappingError>
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

// MARK: - Adapters

private extension UserAccountRoute {
    
    func updated(with state: UserAccountNavigation.State) -> Self {
        
        var route = self
        route.link = .init(state)
        route.alert = state.alert?.routeAlert
        route.spinner = state.isLoading ? .init() : nil
        route.informer = state.informer.map { .init(message: $0) }
        
        return route
    }
}

private extension UserAccountRoute.Link {
    
    init?(_ state: UserAccountNavigation.State) {
        
        switch state.destination {
        case let .some(fpsRoute):
            self = .fastPaymentSettings(.new(fpsRoute))
            
        default:
            return nil
        }
    }
}

private extension AlertModelOf<UserAccountNavigation.Event> {
    
    var routeAlert: AlertModelOf<UserAccountEvent> {
        
        .init(
            id: id,
            title: title,
            message: message,
            primaryButton: primaryButton.routeButton,
            secondaryButton: secondaryButton?.routeButton
        )
    }
}

private extension ButtonViewModel<UserAccountNavigation.Event> {
    
    var routeButton: ButtonViewModel<UserAccountEvent> {
        
        .init(
            type: type.routeButtonType,
            title: title,
            event: event.routeAlert
        )
    }
}

private extension UserAccountNavigation.Event {
    
    var routeAlert: UserAccountEvent {
        
        switch self {
        case .closeAlert:
            return .dismiss(.alert)
        case .closeFPSAlert:
            return .dismiss(.fpsAlert)
        case .dismissFPSDestination:
            return .dismiss(.fpsDestination)
        case .dismissDestination:
            return .dismiss(.destination)
        case .dismissRoute:
            return .dismiss(.route)
        case let .fps(fps):
            return .fps(fps)
        case let .otp(otp):
            return .otp(otp)
        }
    }
}

private extension UserAccountNavigation.Event {
    
    var _routeAlert: UserAccountEvent {
        
        switch self {
        case .closeAlert:
            return .dismiss(.alert)
            
        case .closeFPSAlert:
            return .dismiss(.fpsAlert)
            
        case .dismissFPSDestination:
            return .dismiss(.fpsDestination)
            
        case .dismissDestination:
            return .dismiss(.destination)
            
        case .dismissRoute:
            return .dismiss(.route)
            
        case let .fps(fps):
            return .fps(fps)
            
        case let .otp(otp):
            return .otp(otp)
        }
    }
}

private extension ButtonViewModel<UserAccountNavigation.Event>.ButtonType {
    
    var routeButtonType: ButtonViewModel<UserAccountEvent>.ButtonType {
        
        switch self {
        case .default:     return .default
        case .destructive: return .destructive
        case .cancel:      return .cancel
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
