//
//  RootViewModelFactory+makeC2BPayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import C2GBackend
import C2GCore
import Foundation
import PaymentComponents
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeC2BPayment(
        payload: C2GPaymentDomain.ContentPayload
    ) -> C2GPaymentDomain.Binder {
        
        composeBinder(
            content: makeC2BPaymentContent(payload: payload),
            getNavigation: getNavigation,
            selectWitnesses: .empty
        )
    }
    
    @inlinable
    func makeC2BPaymentContent(
        payload: C2GPaymentDomain.ContentPayload
    ) -> C2GPaymentDomain.Content {
        
        return .init(payload: payload, scheduler: schedulers.main)
    }
    
    @inlinable
    func getNavigation(
        select: C2GPaymentDomain.Select,
        notify: @escaping C2GPaymentDomain.Notify,
        completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        switch select {
        case let .pay(payload):
            createC2GPayment(payload, completion: completion)
        }
    }
    
    @inlinable
    func createC2GPayment(
        _ digest: C2GPaymentDomain.Select.Digest,
        completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        guard let product = product(for: digest)
        else { return completion(.connectivityFailure) } // Strictly speaking, not exactly connectivity failure but missing product, which should not occur if the digest could've held everything needed to form a product cell for details
        
        let payload = digest.payload
        
        guard !payload.uin.hasEasterEgg else {
            
            return easterEggsCreateC2GPayment(payload, product, .completed, completion)
        }
        
        createC2GPayment(payload: payload, product: product) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(enhancedResponse):
                let model = makeOperationDetailModel(initialState: .init(
                    details: .pending,
                    response: enhancedResponse
                ))
                model.event(.load)
                
                completion(.success(model))
            }
        }
    }
    
    typealias EnhancedResponseResult = Result<OperationDetailDomain.State.EnhancedResponse, BackendFailure>
    
    @inlinable
    func createC2GPayment(
        payload: RemoteServices.RequestFactory.CreateC2GPaymentPayload,
        product: ProductData,
        completion: @escaping (EnhancedResponseResult) -> Void
    ) {
        let service = onBackground(
            makeRequest: RequestFactory.createCreateC2GPaymentRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateC2GPaymentResponse
        )
        
        service(payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(
                    failure.backendFailure(connectivityMessage: .connectivity)
                ))

            case let .success(response):
                guard let status = response.status
                else { return completion(.failure(.connectivityFailure)) }
                
                completion(.success(.init(
                    formattedAmount: formatAmount(value: response.amount),
                    formattedDate: nil, // TODO: extract from new version of response
                    merchantName: response.merchantName,
                    message: response.message,
                    paymentOperationDetailID: response.paymentOperationDetailID,
                    product: product,
                    purpose: response.purpose,
                    status: status,
                    uin: payload.uin
                )))
            }
        }
    }
    
    @inlinable
    func product(
        for digest: C2GPaymentDomain.Select.Digest
    ) -> ProductData? {
        
        model.product(productId: digest.productID.id)
    }
    
    private func formatAmount(
        value: Decimal?
    ) -> String? {
        
        guard let value = value?.doubleValue else { return nil }
        
        return model.amountFormatted(amount: value, currencyCode: "RUB", style: .normal)
    }
    
    // TODO: remove stub
    @inlinable
    func easterEggsCreateC2GPayment(
        _ payload: RemoteServices.RequestFactory.CreateC2GPaymentPayload,
        _ product: ProductData,
        _ status: OperationDetailDomain.State.EnhancedResponse.Status,
        _ completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        schedulers.background.delay(for: .seconds(2)) { [weak self] in
            
            guard let self else { return }
            
            switch payload.uin {
            case "01234567890123456789":
                completion(.connectivityFailure)
                
            case "12345678901234567890":
                completion(.failure(.server("server error")))
                
            case "99999999999999999999":
                let initialState = OperationDetailDomain.State(
                    details: .pending,
                    response: .stub(product: product, status: status, uin: payload.uin)
                )
                
                let model = makeOperationDetailModel(initialState: initialState)
                model.event(.load)
                
                completion(.success(model))
                
            default:
                completion(.failure(.server("server error")))
            }
        }
    }
}

// MARK: - Helpers

private extension C2GPaymentDomain.Navigation {
    
    static let connectivityFailure: Self = .failure(.connectivityFailure)
}

private extension BackendFailure {
    
    static let connectivityFailure: Self = .connectivity(.connectivity)
}

// TODO: remove with stub
private extension String {
    
    var hasEasterEgg: Bool {
        
        ["01234567890123456789", "12345678901234567890", "99999999999999999999"].contains(self)
    }
}

// MARK: - Adapters

private extension RemoteServices.ResponseMapper.CreateC2GPaymentResponse {
    
    var status: OperationDetailDomain.State.EnhancedResponse.Status? {
        
        switch documentStatus {
        case "COMPLETE":    return .completed
        case "IN_PROGRESS": return .inflight
        case "REJECTED":    return .rejected
        default:            return nil
        }
    }
}

private extension C2GPaymentDigest {
    
    var payload: RemoteServices.RequestFactory.CreateC2GPaymentPayload {
        
        switch productID.type {
        case .account:
            return .init(accountID: productID.id, cardID: nil, uin: uin)
            
        case .card:
            return .init(accountID: nil, cardID: productID.id, uin: uin)
        }
    }
}

private extension C2GPaymentState
where Context == C2GPaymentDomain.Context {
    
    init(payload: C2GPaymentDomain.ContentPayload) {
        
        self.init(
            context: .init(term: .terms(url: payload.url)),
            productSelect: .init(selected: payload.selectedProduct),
            termsCheck: payload.termsCheck,
            uin: payload.uin
        )
    }
}

private extension AttributedString {
    
    static func terms(url: URL?) -> Self {
        
        var attributedString = AttributedString.turnSBPOnMessage
        attributedString.foregroundColor = .textPlaceholder
        attributedString.font = .textBodyMR14200()
        
        if let url, let terms = attributedString.range(of: String.termURLPlace) {
            
            attributedString[terms].link = url
            attributedString[terms].underlineStyle = .single
            attributedString[terms].foregroundColor = .textSecondary
        }
        
        return attributedString
    }
}

private extension AttributedString {
    
    static let turnSBPOnMessage: Self = .init("Включить переводы через СБП,\n\(String.termURLPlace)")
}

private extension String {
    
    static let connectivity = "Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения"
    
    static let termURLPlace = "принять условия обслуживания"
}

import CombineSchedulers

extension C2GPaymentViewModel
where State == C2GPaymentState<C2GPaymentDomain.Context>,
      Event == C2GPaymentEvent,
      Effect == C2GPaymentEffect {
    
    convenience init(
        payload: C2GPaymentDomain.ContentPayload,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        let initialState = C2GPaymentState(payload: payload)
        
        let productSelectReducer = ProductSelectReducer(
            getProducts: { payload.products }
        )
        let reducer = C2GPaymentDomain.ContentReducer(
            productSelectReduce: productSelectReducer.reduce
        )
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: { _,_ in },
            scheduler: scheduler
        )
    }
}

private extension OperationDetailDomain.State.EnhancedResponse {
    
    static func stub(
        product: ProductData,
        status: Status,
        uin: String
    ) -> Self {
        
        return .init(
            formattedAmount: "100 ₽",
            formattedDate: "06.05.2021 15:38:12",
            merchantName: "merchantName",
            message: "message",
            paymentOperationDetailID: 122004,
            product: product,
            purpose: "purpose",
            status: status,
            uin: uin
        )
    }
}

extension String {
    
    static let createC2GPaymentResponse = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "claimId": "122004",
    "requestDate": "19.02.2025 12:44:56",
    "responseDate": "19.02.2025 12:45:00",
    "transferDate": "19.02.2025",
    "payerCardId": 10000239151,
    "payerCardNumber": "**** **** **01 3245",
    "payerAccountId": 10004766557,
    "payerAccountNumber": "40817810000055004276",
    "payerFullName": "Третьякова Людмила Владимировна",
    "payerAddress": "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 346782, Ростовская обл, Азов г, Осипенко пер ,  д. 47,  кв. 35",
    "payerAmount": 200.00,
    "payerFee": 0.00,
    "payerCurrency": "RUB",
    "payeeFullName": "Федеральное Казначейство",
    "payeeBankName": "Федеральное казначейство",
    "amount": 200.00,
    "currencyAmount": "RUB",
    "comment": "Штраф ГИБДД",
    "transferEnum": "C2G_PAYMENT",
    "payerFirstName": "Людмила",
    "payerMiddleName": "Владимировна",
    "payerPhone": "+79896220672",
    "puref": "0||PaymentsC2G",
    "memberId": "100000000300",
    "isTrafficPoliceService": false,
    "merchantSubName": "Федеральное Казначейство",
    "merchantIcon": "<svg width=\"40\" height=\"40\" viewBox=\"0 0 40 40\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n<path d=\"M0 20C0 8.95431 8.95431 0 20 0C31.0457 0 40 8.95431 40 20C40 31.0457 31.0457 40 20 40C8.95431 40 0 31.0457 0 20Z\" fill=\"#F5C5FE\"/>\n<path d=\"M26.5626 20.125C26.8733 20.125 27.1251 19.8732 27.1251 19.5625C27.1251 19.2518 26.8733 19 26.5626 19C26.252 19 26.0001 19.2518 26.0001 19.5625C26.0001 19.8732 26.252 20.125 26.5626 20.125Z\" fill=\"white\" stroke=\"white\" stroke-width=\"1.25\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>\n<path opacity=\"0.3\" d=\"M12.5626 20.125C12.8733 20.125 13.1251 19.8732 13.1251 19.5625C13.1251 19.2518 12.8733 19 12.5626 19C12.252 19 12.0001 19.2518 12.0001 19.5625C12.0001 19.8732 12.252 20.125 12.5626 20.125Z\" fill=\"white\" stroke=\"white\" stroke-width=\"1.25\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>\n<path opacity=\"0.6\" d=\"M19.5626 20.125C19.8733 20.125 20.1251 19.8732 20.1251 19.5625C20.1251 19.2518 19.8733 19 19.5626 19C19.252 19 19.0001 19.2518 19.0001 19.5625C19.0001 19.8732 19.252 20.125 19.5626 20.125Z\" fill=\"white\" stroke=\"white\" stroke-width=\"1.25\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>\n</svg>\n",
    "operationStatus": "REJECTED",
    "payeeCheckAccount": "03100643000000019500",
    "paymentOperationDetailId": 122004,
    "printFormType": "c2g",
    "dateForDetail": "19 февраля 2025, 12:44",
    "transAmm": 200,
    "discountSizeValue": 50.0,
    "discountExpiry": "2024-12-25",
    "dateN": "2024-08-26",
    "legalAct": "Часть 1 статьи 12.16 КоАП",
    "supplierBillId": "18810192085432512980",
    "realPayerFIO": "-",
    "realPayerINN": "000000000000",
    "realPayerKPP": "000000000",
    "returned": false,
    "payerINN": "614210868146",
    "UPNO": "10445253410000001902202500000002"
  }
}
"""
}
