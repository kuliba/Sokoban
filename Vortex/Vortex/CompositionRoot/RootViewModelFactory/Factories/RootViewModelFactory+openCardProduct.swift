//
//  RootViewModelFactory+openCardProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

import Combine
import CreateCardApplication
import Foundation
import GetCardOrderFormService
import OTPInputComponent
import RemoteServices
import OrderCard

extension RootViewModelFactory {
    
    @inlinable
    func openCardProduct(
        notify: @escaping (OpenCardDomain.OrderCardResponse) -> Void
    ) -> OpenProduct.OpenCard {
        
        let content: OpenCardDomain.Content = makeContent()
        content.event(.load)
        
        let cancellable = content.$state
            .compactMap(\.form?.orderCardResult?.success)
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
        completion: @escaping (OpenCardDomain.LoadFormResult) -> Void
    ) {
        let service = onBackground(
            makeRequest: RequestFactory.createGetCardOrderFormRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetCardOrderFormResponse
        )
        
        service { [weak self] in
            
            let result: OpenCardDomain.LoadFormResult
            
            switch $0 {
            case let .failure(failure):
                result = .failure(failure.loadFailure)
                
            case let .success(response):
                guard let digital = response.digital else {
                    
                    return completion(.failure(.init(
                        message: "Что-то пошло не так.\nПопробуйте позже.",
                        type: .alert
                    )))
                }
                
                result = .success(.init(
                    requestID: UUID().uuidString.lowercased(),
                    cardApplicationCardType: digital.type,
                    cardProductExtID: digital.id,
                    cardProductName: digital.title,
                    messages: .init(
                        description: "",
                        icon: "",
                        subtitle: "",
                        title: "",
                        isOn: false
                    )
                ))
            }
            
            if case .informer = $0.loadFailure?.type {
                
                self?.schedulers.background.delay(for: .seconds(2), dismissInformer)
            }
            
            completion(result)
        }
    }
    
    @inlinable
    func loadConfirmation(
        notify: @escaping OpenCardDomain.ConfirmationNotify,
        completion: @escaping (OpenCardDomain.LoadConfirmationResult) -> Void
    ) {
        let service = onBackground(
            makeRequest: RequestFactory.createGetVerificationCodeOrderCardVerifyRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetVerificationCodeResponse
        )
        
        let otp = makeOTPModel(
            resend: { service { _ in }}, // fire and forget
            observe: { notify(.otp($0)) }
        )
        let consent = OpenCardDomain.Confirmation.Consent(check: true)
        
        service { [weak self] in
            
            guard let self else { return }
            
            if case .informer = $0.loadFailure?.type {
                
                schedulers.background.delay(for: .seconds(2)) {
                    
                    notify(.dismissInformer)
                }
            }
            
            completion($0
                .map { _ in .init(otp: otp, consent: consent) }
                .mapError(\.loadFailure)
            )
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
        // TODO: use `onBackground` to create service
        let service = nanoServiceComposer.compose(
            createRequest: RequestFactory.createCardApplicationRequest,
            mapResponse: { data, response in
                
#warning("extract helper")
                let result = RemoteServices.ResponseMapper.mapCreateCardApplicationResponse(data, response)
                
                switch result {
                case .failure(.server(statusCode: 102, errorMessage: "Введен некорректный код. Попробуйте еще раз.")):
                    return OpenCardDomain.OrderCardResult.failure(.init(message: "Введен некорректный код. Попробуйте еще раз.", type: .alert))
                    
                case .failure:
                    return .success(false)
                    
                case let .success(response):
                    switch response.status {
                    case "SUBMITTED_FOR_REVIEW", "DRAFT":
                        return OpenCardDomain.OrderCardResult.success(true)
                        
                    default:
                        return .success(false)
                    }
                }
            }
        )
        
        // TODO: use `onBackground` to create service
        schedulers.background.schedule {
            
            service(payload.createCardApplicationPayload) { [service] in
#warning("need to notify OTP in case of special failure")
                completion($0.mapError { $0.loadFailure })
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
        
        return formResult?.failure ?? form?.failure
    }
}

private extension OrderCard.Form {
    
    var failure: OrderCard.LoadFailure? {
        
        confirmation?.failure ?? orderCardResult?.failure
    }
}

#warning("extract as reusable helper")
private extension Result {
    
    var failure: Failure? {
        
        guard case let .failure(failure) = self else { return nil }
        
        return failure
    }
    
    var success: Success? {
        
        guard case let .success(success) = self else { return nil }
        
        return success
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

private extension Result {
    
    var loadFailure: OrderCard.LoadFailure? {
        
        guard case let .failure(failure) = self else { return nil }
        
        return failure.loadFailure
    }
}

private extension OpenCardDomain.OrderCardPayload {
    
    var createCardApplicationPayload: CreateCardApplicationPayload {
        
        return .init(
            requestId: requestID,
            cardApplicationCardType: cardApplicationCardType,
            cardProductExtId: cardProductExtID,
            cardProductName: cardProductName,
            smsInfo: smsInfo,
            verificationCode: verificationCode
        )
    }
}

//private extension Result where Success == CreateCardApplicationResponse {
//    
//    var orderCardResult: OpenCardDomain.OrderCardResult {
//        
//        return .init(
//            requestID: requestId,
//            status: status == "SUBMITTED_FOR_REVIEW" || status == "DRAFT"
//        )
//    }
//}

private extension RemoteServices.ResponseMapper.GetCardOrderFormDataResponse {
    
    var digital: RemoteServices.ResponseMapper.GetCardOrderFormData.Item? {
        
        items.first { $0.type == "DIGITAL" }
    }
    
    var items: [RemoteServices.ResponseMapper.GetCardOrderFormData.Item] {
        
        list.flatMap(\.list)
    }
}
