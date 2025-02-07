//
//  RootViewModelFactory+openCardProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

import Combine
import GetCardOrderFormService
import OTPInputComponent
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func openCardProduct(
        notify: @escaping (OpenCardDomain.OrderCardResult) -> Void
    ) -> OpenProduct.OpenCard {
        
        let content: OpenCardDomain.Content = makeContent()
        content.event(.load)
        
        let cancellable = content.$state
            .compactMap(\.orderCardResult)
            .sink { notify($0) }
        
        let binder = composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: witnesses()
        )
        
        return .init(model: binder, cancellable: cancellable)
    }
    
    // MARK: - Content
    
    @inlinable
    func makeContent(
        initialState: OpenCardDomain.State = .init()
    ) -> OpenCardDomain.Content {
        
        let reducer = OpenCardDomain.Reducer()
        let effectHandler = OpenCardDomain.EffectHandler(
            load: load,
            loadConfirmation: loadConfirmation,
            orderCard: orderCard
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect,
            scheduler: schedulers.main
        )
    }
    
    // MARK: - Flow
    
    @inlinable
    func delayProvider(
        navigation: OpenCardDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .failure:
            return .zero
        }
    }
    
    @inlinable
    func getNavigation(
        select: OpenCardDomain.Select,
        notify: @escaping OpenCardDomain.Notify,
        completion: @escaping (OpenCardDomain.Navigation) -> Void
    ) {
        switch select {
        case let .failure(loadFailure):
            completion(.failure(loadFailure))
        }
    }
    
    // MARK: - Bind
    
    @inlinable
    func witnesses() -> OpenCardDomain.Witnesses {
        
        return .init(
            emitting: { $0.$state.map(\.flowEvent) },
            dismissing: { _ in {} } // TODO: add dismissing failure
        )
    }
    
    // MARK: - Services
    
    @inlinable
    func load(
        dismissInformer: @escaping () -> Void,
        completion: @escaping (OpenCardDomain.LoadResult) -> Void
    ) {
        let _service = nanoServiceComposer.compose(
            makeRequest: RequestFactory.createGetCardOrderFormRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetCardOrderFormResponse
        )
        
        let service: (@escaping (OpenCardDomain.LoadResult) -> Void) -> Void = { [weak self] completion in
            
            self?.schedulers.background.delay(for: .seconds(1)) {
                
                completion(.success(.init(product: 1, type: "", messages: .init(description: "", icon: "", subtitle: "", title: "", isOn: false))))
            }
        }
        
        schedulers.background.schedule { [weak self] in
            
            service { [service] in
                
                if case let .failure(failure) = $0,
                   case .informer = failure.type {
                    
                    self?.schedulers.background.delay(for: .seconds(2), dismissInformer)
                }
                
                completion($0)
                _ = service
            }
        }
    }
    
    @inlinable
    func loadConfirmation(
        notify: @escaping OpenCardDomain.ConfirmationNotify,
        completion: @escaping (OpenCardDomain.LoadConfirmationResult) -> Void
    ) {
        let service = nanoServiceComposer.compose(
            makeRequest: RequestFactory.createGetVerificationCodeOrderCardVerifyRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetVerificationCodeResponse
        )
        
        let otp = makeOTPModel(
            resend: { service(()) { _ in }}, // fire and forget
            observe: { notify(.otp($0)) }
        )
        let consent = OpenCardDomain.Confirmation.Consent(check: true)
        
        schedulers.background.schedule {
            
            service(()) { [weak self, service] in
                
                completion($0
                    .map { _ in .init(otp: otp, consent: consent) }
                    .mapError(\.loadFailure)
                )
                
                if case .informer = $0.loadFailure?.type {
                    
                    self?.schedulers.background.delay(for: .seconds(2)) {
                        
                        notify(.dismissInformer)
                    }
                }
                
                _ = service
            }
        }
    }
    
    @inlinable
    func makeOTPModel(
        timerDuration: Int = 60,
        otpLength: Int = 6,
        resend: @escaping () -> Void,
        observe: @escaping (String) -> Void
    ) -> TimedOTPInputViewModel {
        
        return .init(
            otpText: "",
            timerDuration: timerDuration,
            otpLength: otpLength,
            resend: resend,
            observe: observe
        )
    }
    
    @inlinable
    func orderCard(
        payload: OpenCardDomain.OrderCardPayload,
        completion: @escaping (OpenCardDomain.OrderCardResult) -> Void
    ) {
        //        let service = nanoServiceComposer.compose(
        //            makeRequest: RequestFactory.createOrderRequest,
        //            mapResponse: RemoteServices.ResponseMapper.mapOrderCardResponse
        //        )
        
        let service: (@escaping (OpenCardDomain.OrderCardResult) -> Void) -> Void = { [weak self] completion in
            
            self?.schedulers.background.delay(for: .seconds(2)) {
                
                completion(true)
            }
        }
        
        schedulers.background.schedule {
            
            service { [service] in
                
                completion($0)
                _ = service
            }
        }
    }
}

// MARK: - Adapters

private extension OpenCardDomain.State {
    
    var flowEvent: FlowEvent<OpenCardDomain.Select, Never> {
        
        switch failure {
        case .none:
            return .dismiss
            
        case let .some(failure):
            return .select(.failure(failure))
        }
    }
    
    var failure: OpenCardDomain.LoadFailure? {
        
        switch result {
        case let .failure(failure):
            return failure
            
        case let .success(form):
            switch form.confirmation {
            case let .failure(failure):
                return failure
                
            default:
                return nil
            }
            
        default:
            return nil
        }
    }
}

private extension Error {
    
    var loadFailure: OrderCard.LoadFailure {
        
        switch self as? RemoteServices.ResponseMapper.MappingError {
        case let .server(_, errorMessage: errorMessage):
            return .init(message: errorMessage, type: .alert)
            
        default:
            return .init(message: "Что-то пошло не так.\nПопробуйте позже.", type: .informer)
        }
    }
}

private extension Result<RemoteServices.ResponseMapper.GetVerificationCodeResponse, Error> {
    
    var loadFailure: OrderCard.LoadFailure? {
        
        guard case let .failure(failure) = self  else { return nil }
        
        return failure.loadFailure
    }
}
