//
//  RootViewModelFactory+openCardProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

import Combine
import CreateCardApplication
import Foundation
import GenericRemoteService
import GetCardOrderFormService
import OrderCard
import OTPInputComponent
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func openCardProduct(
        notify: @escaping (OpenCardDomain.OrderCardResponse) -> Void
    ) -> OpenProduct.OpenCard {
        
        let content: OpenCardDomain.Content = makeContent()
        content.event(.load)
        
        let cancellable = content.$state
            .compactMap(\.form?.orderCardResponse)
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
        initialState: OpenCardDomain.State = .init(loadableForm: .loaded(nil))
    ) -> OpenCardDomain.Content {
        
        let reducer = OpenCardDomain.Reducer { confirmation in
            
            { confirmation.otp.event(.otpField(.failure(.serverError($0)))) }
        }
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
        // TODO: add `onBackground` overload with response mapping
        let service = onBackground(
            makeRequest: RequestFactory.createGetCardOrderFormRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetCardOrderFormResponse
        )
        
        service { [weak self] in
            
            if case .informer = $0.loadFailure?.type {
                
                self?.schedulers.background.delay(for: .seconds(2), dismissInformer)
            }
            
            completion($0.loadFormResult)
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
        #warning("USE CONDITION AND TARIFF URL TO CREATE CONSENT DESCRIPTION")
        let consent = OpenCardDomain.Confirmation.Consent(
            check: true,
            description: "Я соглашаюсь с Условиями и Тарифами"
        )
        
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
            mapResponse: ResponseMapper.mapCreateCardApplicationServiceResponse
        )
        
        // TODO: use `onBackground` to create service
        schedulers.background.schedule {
            
            service(payload.createCardApplicationPayload) { [service] in

                completion($0.mapError { $0.loadFailure })
                _ = service
            }
        }
    }
}

// MARK: - Helpers

private extension ResponseMapper {
    
    static func mapCreateCardApplicationServiceResponse(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> OpenCardDomain.OrderCardResult {
        
        let result = RemoteServices.ResponseMapper.mapCreateCardApplicationResponse(data, response)
        
        return result.orderCardResult
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
        
        return form?.failure ?? form?.failure
    }
}

private extension OrderCard.Form {
    
    var failure: OrderCard.LoadFailure? {
        
        guard case let .loaded(.failure(failure)) = confirmation else { return nil }
        
        return failure
    }
}

private extension Error {
    
    var loadFailure: OrderCard.LoadFailure {
        
        switch self {
        case let failure as OrderCard.LoadFailure:
            return failure
            
        case let failure as RemoteServiceError<Error, Error, OrderCard.LoadFailure>:
            switch failure {
            case let .mapResponse(failure):
                return failure
                
            default:
                return .tryLaterInformer
            }
            
        case let mappingError as RemoteServices.ResponseMapper.MappingError:
            switch mappingError {
            case let .server(_, errorMessage):
                return .init(message: errorMessage, type: .alert)
                
            default:
                return .tryLaterInformer
            }
            
        default:
            return .tryLaterInformer
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

private extension Result
where Success == RemoteServices.ResponseMapper.GetCardOrderFormDataResponse {
    
    var loadFormResult: OpenCardDomain.LoadFormResult {
        
        switch self {
        case let .failure(failure):
            return .failure(failure.loadFailure)
            
        case let .success(response):
            if let digital = response.digital {
                
                return .success(digital.form())
            } else {
            
                return .failure(.tryLaterAlert)
            }
        }
    }
}

private extension CardProduct {
    
    func form() -> OrderCard.Form<OpenCardDomain.Confirmation> {
        
        return .init(
            product: .init(
                image: item.design,
                header: (item.description, item.title),
                orderOption: ("\(item.fee.free)", ("\(String(item.fee.maintenance.value)) \(item.currency.symbol)"))
            ),
            type: .init(
                title: item.typeText
            ),
            conditions: conditions,
            tariffs: tariffs,
            requestID: UUID().uuidString.lowercased(),
            cardApplicationCardType: item.type,
            cardProductExtID: item.id,
            cardProductName: item.title,
            messages: .default(tariffs)
        )
    }
}

private extension OrderCard.Messages {
    
    static func `default`(
        _ tariffLink: URL
    ) -> Self {

        return .init(
            description: description(
                description: "Присылаем пуш-уведомления по операциям,\nесли не доходят - отправляем смс.\nС тарифами за услугу согласен.",
                tariffURL: tariffLink
            ),
            icon: "ic24MessageSquare",
            subtitle: "Пуши и смс",
            title: "Способ уведомлений",
            isOn: false
        )
    }
}

private extension OrderCard.Messages {

    static func description(
        description: String,
        tariffURL: URL
    ) -> AttributedString {
      
        var attributedString = AttributedString(description)
        attributedString.foregroundColor = .textPlaceholder
        attributedString.font = .textBodySR12160()
      
        if let tariff = attributedString.range(of: "тарифами") {
            attributedString[tariff].link = tariffURL
            attributedString[tariff].underlineStyle = .single
            attributedString[tariff].foregroundColor = .textPlaceholder
        }
        
      return attributedString
    }
}

private extension RemoteServices.ResponseMapper.GetCardOrderFormDataResponse {
    
    var digital: CardProduct? {
        
        cardProducts.first { $0.item.type == "DIGITAL" }
    }
    
    var cardProducts: [CardProduct] {
        
        list.flatMap { product in
            
            product.list.compactMap { item in
                
                guard let conditions = URL(string: product.conditionsLink),
                      let tariffs = URL(string: product.tariffLink)
                else { return nil }
                
                return .init(
                    conditions: conditions,
                    tariffs: tariffs,
                    item: item
                )
            }
        }
    }
}

private struct CardProduct {
    
    let conditions: URL
    let tariffs: URL
    let item: RemoteServices.ResponseMapper.GetCardOrderFormData.Item
}

private extension RemoteServices.ResponseMapper.MappingResult<CreateCardApplicationResponse> {
    
    var orderCardResult: OpenCardDomain.OrderCardResult {
        
        switch self {
        case let .failure(failure):
            switch failure {
            case .server(statusCode: 102, errorMessage: ._invalidCode):
                return .failure(.invalidCodeAlert)
                
            default:
                return .success(false)
            }
            
        case let .success(response):
            switch response.status {
            case "SUBMITTED_FOR_REVIEW", "DRAFT":
                return .success(true)
                
            default:
                return .success(false)
            }
        }
    }
}

private extension OpenCardDomain.LoadFailure {
    
    static let invalidCodeAlert: Self = .init(message: ._invalidCode, type: .alert)
    static let tryLaterAlert: Self = .init(message: ._tryLater, type: .alert)
    static let tryLaterInformer: Self = .init(message: ._tryLater, type: .informer)
}

private extension String {
    
    static let _invalidCode = "Введен некорректный код. Попробуйте еще раз."
    static let _tryLater = "Что-то пошло не так.\nПопробуйте позже."
}
