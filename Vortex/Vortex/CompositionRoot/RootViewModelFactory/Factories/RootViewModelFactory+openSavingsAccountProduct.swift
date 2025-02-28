//
//  RootViewModelFactory+openSavingsAccountProduct.swift
//  Vortex
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import Combine
import SavingsServices
import Foundation
import GenericRemoteService
import SavingsAccount
import OTPInputComponent
import RemoteServices
import LoadableState
import PaymentComponents
import StateMachines

enum OpenSavingsAccountCompleteDomain {}

extension OpenSavingsAccountCompleteDomain {
    
    struct Complete {
        
        let context: Context
        let details: OperationDetailSADomain.Model
        let document: DocumentButtonDomain.Model
        
        struct Context: Equatable {
            
            let formattedAmount: String?
            let merchantName: String?
            let purpose: String?
            let status: Status
            
            enum Status {
                
                case completed, inflight, rejected
            }
        }
    }
    
    struct Details: Equatable {
                
        let product: Product?
        
        let payeeAccountId: Int?    // Счет поплнения - "payeeAccountId"
        let payeeAccountNumber: String?    // Открытый накопительный счет - "payeeAccountNumber"
        let payerCardId: Int?   // Карта списания - payerCardId
        let payerCardNumber: String?   // Номер карты списания - payerCardNumber
        let payerAccountId: Int?   // Счет списания - payerAccountId
        
        let formattedAmount: String? // Сумма платежа - payerAmount+ payerCurrency
        let formattedFee: String? // Сумма комиссии - payerFee+ payerCurrency
        let dataForDetails: String?   // Дата и время операции (МСК) - dataForDetails
    }

    typealias Product = ProductSelect.Product
}

typealias OperationDetailSADomain = StateMachineDomain<OpenSavingsAccountCompleteDomain.Details, Error>

extension RootViewModelFactory {
    
    @inlinable
    func openSavingsAccountProduct(
        notify: @escaping (OpenSavingsAccountDomain.OrderAccountResponse) -> Void
    ) -> OpenSavingsAccount {
        
        let products = model.productSelectProducts

        let initialState: OpenSavingsAccountDomain.State = .init(
            loadableForm: .loaded(nil),
            productSelect: .init(selected: products().first)
        )

        let content: OpenSavingsAccountDomain.Content = makeContent(initialState, products)
        
        let cancellable = content.$state
            .compactMap(\.form?.orderAccountResponse)
            .sink { notify($0) }
        
        let binder = composeBinder(
            content: content,
            getNavigation: getNavigation,
            witnesses: witnesses()
        )
        
        return .init(model: binder, cancellable: cancellable)
    }
    
    // MARK: - Content
    
    @inlinable
    func makeContent(
        _ initialState: OpenSavingsAccountDomain.State,
        _ products: @escaping ProductSelectReducer.GetProducts
    ) -> OpenSavingsAccountDomain.Content {
        
        let productSelectReducer = ProductSelectReducer(
            getProducts: products
        )
        
        let reducer = OpenSavingsAccountDomain.Reducer(
            otpWitness:  { confirmation in
                
                { confirmation.otp.event(.otpField(.failure(.serverError($0)))) }
            },
            productSelectReduce: productSelectReducer.reduce(_:_:)
        )
        
        let effectHandler = OpenSavingsAccountDomain.EffectHandler(
            load: load,
            loadConfirmation: loadConfirmation,
            orderAccount: orderSavingsAccount
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
    func getNavigation(
        select: OpenSavingsAccountDomain.Select,
        notify: @escaping OpenSavingsAccountDomain.Notify,
        completion: @escaping (OpenSavingsAccountDomain.Navigation) -> Void
    ) {
        switch select {
        case let .failure(loadFailure):
            completion(.failure(loadFailure))
        }
    }
    
    // MARK: - Bind
    
    @inlinable
    func witnesses() -> OpenSavingsAccountDomain.Witnesses {
        
        return .init(
            emitting: { $0.$state.map(\.flowEvent) },
            dismissing: { _ in {} } // TODO: add dismissing failure
        )
    }
    
    // MARK: - Services
    
    @inlinable
    func load(
        dismissInformer: @escaping () -> Void,
        completion: @escaping (OpenSavingsAccountDomain.LoadFormResult) -> Void
    ) {
        let service = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetOpenAccountFormRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetOpenAccountFormResponse
        )

        service(()) { [weak self] in
            
            if let self, case .informer = $0.loadFailure?.type {
                
                schedulers.background.delay(for: settings.informerDelay, dismissInformer)
            }
            
            completion($0.loadFormResult)
            _ = service
        }
    }
    
    @inlinable
    func loadConfirmation(
        payload: OpenSavingsAccountDomain.Effect.LoadConfirmationPayload,
        notify: @escaping OpenSavingsAccountDomain.ConfirmationNotify,
        completion: @escaping (OpenSavingsAccountDomain.LoadConfirmationResult) -> Void
    ) {
        let service = onBackground(
            makeRequest: RequestFactory.createPrepareOpenSavingsAccountRequest,
            mapResponse: RemoteServices.ResponseMapper.mapPrepareOpenSavingsAccountResponse
        )

        let otp = makeOTPModel(
            resend: { service { _ in }}, // fire and forget
            observe: { notify(.otp($0)) }
        )
        
        let consent = OpenSavingsAccountDomain.Confirmation.Consent(
            description: RootViewModelFactory.description(
                "Я соглашаюсь с Условиями и Тарифами",
                tariffURL: URL(string: payload.tariff)!,
                conditionURL: URL(string:payload.condition)!
            )
        )
        
        service { [weak self] in
            
            guard let self else { return }
            
            if case .informer = $0.loadFailure?.type {
                
                schedulers.background.delay(for: settings.informerDelay) {
                    
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
    func orderSavingsAccount(
        payload: OpenSavingsAccountDomain.OrderAccountPayload,
        completion: @escaping (OpenSavingsAccountDomain.OrderAccountResult) -> Void
    ) {
        // TODO: use `onBackground` to create service
        let service = nanoServiceComposer.compose(
            createRequest: RequestFactory.createMakeOpenSavingsAccountRequest,
            mapResponse: ResponseMapper.mapMakeOpenSavingsAccountResponse
        )
        
        // TODO: use `onBackground` to create service
        schedulers.background.schedule {
            
            service(payload.createMakeOpenSavingsAccountPayload) { [service] in

                completion($0.mapError { $0.loadFailure })
                _ = service
            }
        }
    }
}

private extension RootViewModelFactory {
    
    static func description(
        _ consent: String,
        tariffURL: URL,
        conditionURL: URL
    ) -> AttributedString {
        
        var attributedString = AttributedString(consent)
        attributedString.foregroundColor = .textPlaceholder
        attributedString.font = .textBodySR12160()
        
        if let tariff = attributedString.range(of: "Тарифами") {
            attributedString[tariff].link = tariffURL
            attributedString[tariff].underlineStyle = .single
            attributedString[tariff].foregroundColor = .textPlaceholder
        }
        
        if let tariff = attributedString.range(of: "Условиями") {
            attributedString[tariff].link = conditionURL
            attributedString[tariff].underlineStyle = .single
            attributedString[tariff].foregroundColor = .textPlaceholder
        }
        
        return attributedString
    }
}
// MARK: - Helpers

private extension ResponseMapper {
    
    static func mapMakeOpenSavingsAccountResponse(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> OpenSavingsAccountDomain.OrderAccountResult {
        
        let result = RemoteServices.ResponseMapper.mapMakeOpenSavingsAccountResponse(data, response)
        
        return result.orderAccountResult
    }
}

// MARK: - Adapters

private extension OpenSavingsAccountDomain.State {
    
    var flowEvent: FlowEvent<OpenSavingsAccountDomain.Select, Never> {
        
        switch failure {
        case .none:
            return .dismiss
            
        case let .some(failure):
            return .select(.failure(failure))
        }
    }
    
    var failure: OpenSavingsAccountDomain.LoadFailure? {
        
        return form?.failure ?? form?.failure
    }
}

private extension SavingsAccount.Form {
    
    var failure: LoadableState.LoadFailure? {
        
        guard case let .loaded(.failure(failure)) = confirmation else { return nil }
        
        return failure
    }
}

private extension Error {
    
    var loadFailure: LoadableState.LoadFailure {
        
        switch self {
        case let failure as LoadableState.LoadFailure:
            return failure
            
        case let failure as RemoteServiceError<Error, Error, LoadableState.LoadFailure>:
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
    
    var loadFailure: LoadableState.LoadFailure? {
        
        guard case let .failure(failure) = self else { return nil }
        
        return failure.loadFailure
    }
}

private extension OpenSavingsAccountDomain.OrderAccountPayload {
    
    var createMakeOpenSavingsAccountPayload: MakeOpenSavingsAccountPayload {
        
        return .init(
            accountID: sourceAccountId,
            amount: amount.map { Decimal(string: $0.description) ?? 0 },
            cardID: sourceCardId,
            cryptoVersion: cryptoVersion ?? "1.0",
            currencyCode: currencyCode,
            verificationCode: verificationCode)
    }
}

private extension Result
where Success == RemoteServices.ResponseMapper.GetOpenAccountFormResponse {
    
    var loadFormResult: OpenSavingsAccountDomain.LoadFormResult {
        
        switch self {
        case let .failure(failure):
            return .failure(failure.loadFailure)
            
        case let .success(response):
            if let item = response.item{
                
                return .success(item.form())
            } else {
            
                return .failure(.tryLaterAlert)
            }
        }
    }
}

private extension SavingsAccountProduct {
    
    func form() -> SavingsAccount.Form<OpenSavingsAccountDomain.Confirmation> {
        
        .init(
            constants: .init(
                currency: .init(code: item.currency.code, symbol: item.currency.symbol),
                designMd5hash: item.design,
                header: .init(title: item.title, subtitle: item.description),
                hint: item.hint,
                income: item.income,
                links: .init(conditions: item.conditionsLink, tariff: item.tariffLink),
                openValue: openValue,
                orderServiceOption: orderServiceOption),
            confirmation: .loaded(nil),
            topUp: .default(),
            amount: .init(title: "", value: 0, button: .init(title: "Продолжить", isEnabled: false))
        )
    }
    
    var orderServiceOption: String {
                
        return (item.fee.maintenance.value == 0 || item.fee.maintenance.period == "free")
        ? "Бесплатно"
        : "\(item.fee.maintenance.value) \(item.currency.symbol) " + period
    }
    
    var period: String {
        
        switch item.fee.maintenance.period {
        case "month": return "в месяц"
        case "year": return "в год"
        default: return ""
        }
    }
    
    var openValue: String {
        
        return item.fee.open == 0 ? "Бесплатно" : "\(item.fee.open) \(item.currency.symbol)"
    }
}

private extension SavingsAccount.TopUp {
    
    static func `default`() -> Self {

        return .init(isOn: false)
    }
}

private extension RemoteServices.ResponseMapper.GetOpenAccountFormResponse {
    
    var item: SavingsAccountProduct? {
        
        if let firstItem = list.first {
            
            return .init(
                conditions: firstItem.conditionsLink,
                tariffs: firstItem.tariffLink,
                item: firstItem
            )
        }
        
        return nil
    }
}

private struct SavingsAccountProduct {
    
    let conditions: String
    let tariffs: String
    let item: RemoteServices.ResponseMapper.GetOpenAccountFormData
}

private extension RemoteServices.ResponseMapper.MappingResult<MakeOpenSavingsAccountResponse> {
    
    var orderAccountResult: OpenSavingsAccountDomain.OrderAccountResult {
        
        switch self {
        case let .failure(failure):
            switch failure {
            case .server(statusCode: 102, errorMessage: ._invalidCode):
                return .failure(.invalidCodeAlert)
                
            default:
                return .failure(.tryLaterAlert)
            }
            
        case let .success(response):
            switch response.documentInfo.documentStatus {
            case .complete, .inProgress:
                return .success(.init(response))
                
            default:
                return .success(.init(response))
            }
        }
    }
}

private extension OrderAccountResponse {
    
    init(
        _ data: MakeOpenSavingsAccountResponse
    ) {
        
        self.init(
            accountId: data.paymentInfo.accountId,
            accountNumber: data.paymentInfo.accountNumber,
            paymentOperationDetailId: data.paymentOperationDetailID, 
            product: nil,
            openData: data.paymentInfo.dateOpen,
            status: data.documentInfo.documentStatus?.status ?? .inflight
        )
    }
}
private extension OpenSavingsAccountDomain.LoadFailure {
    
    static let invalidCodeAlert: Self = .init(message: ._invalidCode, type: .alert)
    static let tryLaterAlert: Self = .init(message: ._tryLater, type: .alert)
    static let tryLaterInformer: Self = .init(message: ._tryLater, type: .informer)
}

private extension String {
    
    static let _invalidCode = "Введен некорректный код. Попробуйте еще раз."
    static let _tryLater = "Что-то пошло не так.\nПопробуйте позже."
}

extension MakeOpenSavingsAccountResponse.DocumentStatus {
    
    var status: OrderAccountResponse.Status {
        
        switch self {
        case .complete:
            return .completed
        case .inProgress:
            return .inflight
        case .rejected:
            return .rejected
        }
    }
}
