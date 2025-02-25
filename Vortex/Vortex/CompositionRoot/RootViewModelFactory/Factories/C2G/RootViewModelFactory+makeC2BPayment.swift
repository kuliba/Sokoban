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
        guard !digest.uin.hasEasterEgg else {
            
            return easterEggsCreateC2GPayment(digest, .inflight, completion)
        }
        
        createC2GPayment(digest: digest) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(payload):
                let details = makeOperationDetailByPaymentID(payload)
                details.event(.load)
                
                let document = makeC2GDocumentButton()
                document.event(.load)
                
                completion(.success(.init(
                    context: .init(payload), 
                    details: details,
                    document: document
                )))
            }
        }
    }
    
    typealias ModelPayloadResult = Result<OperationDetailDomain.ModelPayload, BackendFailure>
    
    @inlinable
    func createC2GPayment(
        digest: C2GPaymentDomain.Select.Digest,
        completion: @escaping (ModelPayloadResult) -> Void
    ) {
        let service = onBackground(
            makeRequest: RequestFactory.createCreateC2GPaymentRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateC2GPaymentResponse,
            connectivityFailureMessage: .connectivity
        )
        
        service(digest.payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(response):
                guard let basicDetails = response.payload(
                    digest: digest,
                    formattedAmount: format(amount: response.amount, currencyCode: "RUB")
                ) else { return completion(.failure(.connectivityFailure)) }
                
                completion(.success(basicDetails))
            }
        }
    }
    
    @inlinable
    func makeC2GDocumentButton(
    ) -> DocumentButtonDomain.Model {
        
        return makeDocumentButton { [weak self] completion in
            
            // TODO: replace stub with real service when API is ready
            self?.schedulers.background.delay(for: .seconds(2)) {
                
                completion(.failure(NSError(domain: "Load print form error", code: -1)))
            }
        }
    }
    
    // TODO: remove stub
    @inlinable
    func easterEggsCreateC2GPayment(
        _ digest: C2GPaymentDomain.Select.Digest,
        _ status: OperationDetailDomain.Status,
        _ completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        schedulers.background.delay(for: .seconds(2)) { [weak self] in
            
            guard let self else { return }
            
            switch digest.uin {
            case "01234567890123456789":
                completion(.connectivityFailure)
                
            case "12345678901234567890":
                completion(.failure(.server("server error")))
                
            case "99999999999999999999":
                let basicDetails: OperationDetailDomain.ModelPayload = .stub(
                    digest: digest,
                    status: status
                )
                let details = makeOperationDetailByPaymentID(basicDetails)
                details.event(.load)
                
                let document = makeC2GDocumentButton()
                document.event(.load)
                
                completion(.success(.init(
                    context: .init(basicDetails), 
                    details: details,
                    document: document
                )))
                
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

private extension C2GPaymentDomain.Complete.Context {
    
    init(_ payload: OperationDetailDomain.ModelPayload) {
        
        self.init(
            formattedAmount: payload.formattedAmount,
            merchantName: payload.merchantName,
            purpose: payload.purpose,
            status: payload.status.status
        )
    }
}

private extension OperationDetailDomain.Status {
    
    var status: C2GPaymentDomain.Complete.Context.Status {
        
        switch self {
        case .completed: return .completed
        case .inflight:  return .inflight
        case .rejected:  return .rejected
        }
    }
}

private extension RemoteServices.ResponseMapper.CreateC2GPaymentResponse {
    
    var status: OperationDetailDomain.Status? {
        
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
        
        switch product.type {
        case .account:
            return .init(accountID: product.id.rawValue, cardID: nil, uin: uin)
            
        case .card:
            return .init(accountID: nil, cardID: product.id.rawValue, uin: uin)
        }
    }
}

private extension String {
    
    static let connectivity = "Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения"
}

private extension RemoteServices.ResponseMapper.CreateC2GPaymentResponse {
    
    func payload(
        digest: C2GPaymentDigest,
        formattedAmount: String?
    ) -> OperationDetailDomain.ModelPayload? {
        
        guard let status else { return nil }
        
        return .init(
            product: digest.product,
            status: status,
            formattedAmount: formattedAmount,
            formattedDate: nil, // TODO: extract from new version of response - Lera
            merchantName: merchantName,
            message: message,
            paymentOperationDetailID: paymentOperationDetailID,
            purpose: purpose,
            uin: digest.uin
        )
    }
}

// MARK: - Stub

private extension OperationDetailDomain.ModelPayload {
    
    static func stub(
        digest: C2GPaymentDomain.Select.Digest,
        status: OperationDetailDomain.Status
    ) -> Self {
        
        return .init(
            product: digest.product,
            status: status,
            formattedAmount: "100 ₽",
            formattedDate: "06.05.2021 15:38:12",
            merchantName: "merchantName",
            message: "message",
            paymentOperationDetailID: 122004,
            purpose: "purpose",
            uin: digest.uin
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
