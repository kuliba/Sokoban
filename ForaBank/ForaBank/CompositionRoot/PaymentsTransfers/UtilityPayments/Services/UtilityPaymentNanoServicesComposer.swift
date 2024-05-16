//
//  UtilityPaymentNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import Fetcher
import Foundation
import RemoteServices

final class UtilityPaymentNanoServicesComposer {
    
    private let flag: Flag
    private let httpClient: HTTPClient
    private let log: Log
    private let loadOperators: LoadOperators
    
    init(
        flag: Flag,
        httpClient: HTTPClient,
        log: @escaping Log,
        loadOperators: @escaping LoadOperators
    ) {
        self.flag = flag
        self.httpClient = httpClient
        self.log = log
        self.loadOperators = loadOperators
    }
}

extension UtilityPaymentNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        return .init(
            getOperatorsListByParam: getOperatorsListByParam,
            getAllLatestPayments: getAllLatestPayments,
            startAnywayPayment: startAnywayPayment,
            getServicesFor: getServicesFor()
        )
    }
}

extension UtilityPaymentNanoServicesComposer {
    
    typealias Log = (String, StaticString, UInt) -> Void
    
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
    typealias LoadOperators = (@escaping LoadOperatorsCompletion) -> Void
    
    enum Flag {
        
        case live
        case stub(Stub)
        
        typealias Stub = (Payload) -> StartPaymentResult
        typealias Payload = NanoServices.StartAnywayPaymentPayload
        typealias StartPaymentResult = NanoServices.StartAnywayPaymentResult
    }
    
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
}

private extension UtilityPaymentNanoServicesComposer {
    
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    func getOperatorsListByParam(
        _ completion: @escaping ([Operator]) -> Void
    ) {
        loadOperators(completion)
    }
    
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    func getAllLatestPayments(
        _ completion: @escaping ([LastPayment]) -> Void
    ) {
        switch flag {
        case .live:
            getAllLatestPaymentsLive(completion)
            
        case .stub:
            DispatchQueue.main.delay(for: .seconds(1)) { completion(.stub) }
        }
    }
    
    private  func getAllLatestPaymentsLive(
        _ completion: @escaping ([LastPayment]) -> Void
    ) {
        // TODO: add logging // NanoServices.adaptedLoggingFetch
        // TODO: remake as ForaBank.NanoServices.startAnywayPayment
        let service = Services.getAllLatestPayments(httpClient: httpClient)
        service.process(.service) { [service] result in
            
            completion((try? result.get().map(LastPayment.init(with:))) ?? [])
            _ = service
        }
    }
    
    /// `e`
    /// Начало выполнения перевода - 1шаг, передаем `isNewPayment=true`
    /// POST /rest/transfer/createAnywayTransfer?isNewPayment=true
    func startAnywayPayment(
        _ payload: StartAnywayPaymentPayload,
        _ completion: @escaping StartAnywayPaymentCompletion
    ) {
        switch flag {
        case .live:
            startAnywayPaymentLive(payload, completion)
            
        case let .stub(stub):
            startAnywayPaymentStub(stub, payload, completion)
        }
    }
    
    private func startAnywayPaymentLive(
        _ payload: StartAnywayPaymentPayload,
        _ completion: @escaping StartAnywayPaymentCompletion
    ) {
        let createAnywayTransferNew = ForaBank.NanoServices.makeCreateAnywayTransferNew(httpClient, log)
        let adapted = FetchAdapter(
            fetch: createAnywayTransferNew,
            mapResult: StartAnywayPaymentResult.init(result:)
        )
        let mapped = MapPayloadDecorator(
            decoratee: adapted.fetch,
            mapPayload: RemoteServices.RequestFactory.CreateAnywayTransferPayload.init
        )
        
        mapped(payload) { [mapped] result in
            
            completion(result)
            _ = mapped
        }
    }
    
    private func startAnywayPaymentStub(
        _ stub: @escaping Flag.Stub,
        _ payload: StartAnywayPaymentPayload,
        _ completion: @escaping StartAnywayPaymentCompletion
    ) {
        DispatchQueue.main.delay(for: .seconds(1)) {
            
            completion(stub(payload))
        }
    }
    
    /// `d`
    /// Получение услуг юр. лица по "customerId" и типу housingAndCommunalService
    /// dict/getOperatorsListByParam?customerId=8798&operatorOnly=false&type=housingAndCommunalService
    func getServicesFor(
    ) -> NanoServices.GetServicesFor {
        
#warning("fix me")
        return { _,_ in  }
    }
}

// MARK: - Adapters

private extension UtilityPaymentLastPayment {
    
    init(with lastPayment: ResponseMapper.LatestPayment) {
        
        self.init(
            id: lastPayment.id,
            title: lastPayment.title,
            subtitle: "\(lastPayment.amount)",
            icon: lastPayment.md5Hash ?? ""
        )
    }
}

private extension RemoteServices.RequestFactory.CreateAnywayTransferPayload {
    
    init(_ payload: StartAnywayPaymentPayload) {
        
        /// - Note: `check` is optional
        /// Признак проверки операции:
        /// - если `check="true"`, то OTP не отправляется,
        /// - если `check="false"` - OTP отправляется
        self.init(additional: [], check: true, puref: payload.puref)
    }
}

private extension StartAnywayPaymentPayload {
    
#warning("fix me")
    var puref: String {
        
        "iFora||MOO2" // one sum
//        "iFora||7602" // mutli sum
        
//        switch self {
//        case let .lastPayment(lastPayment):
//            return lastPayment.puref
//
//        case let .operator(`operator`):
//            return `operator`.puref
//
//        case let .service(utilityService, _):
//            return utilityService.puref
//        }
    }
}

private extension StartAnywayPaymentResult {
    
    init(result: NanoServices.CreateAnywayTransferResult) {
        
        switch result {
        case let .failure(serviceFailure):
            switch serviceFailure {
            case .connectivityError:
                self = .failure(.serviceFailure(.connectivityError))
                
            case let .serverError(message):
                self = .failure(.serviceFailure(.serverError(message)))
            }
            
        case let .success(response):
#warning("use response")
            self = .success(.startPayment(.init()))
        }
    }
}

typealias StartAnywayPayment = _UtilityPaymentNanoServices.StartAnywayPayment
typealias StartAnywayPaymentPayload = _UtilityPaymentNanoServices.StartAnywayPaymentPayload
typealias StartAnywayPaymentResult = _UtilityPaymentNanoServices.StartAnywayPaymentResult
typealias StartAnywayPaymentCompletion = _UtilityPaymentNanoServices.StartAnywayPaymentCompletion

typealias _UtilityPaymentNanoServices = UtilityPaymentNanoServices<UtilityPaymentLastPayment, UtilityPaymentOperator>

// MARK: - Stubs

private extension Array where Element == UtilityPaymentLastPayment {
    
    static let stub: Self = [
        .failure,
        .preview,
    ]
}

private extension UtilityPaymentLastPayment {
    
    static let failure: Self = .init(id: "failure", title: UUID().uuidString, subtitle: UUID().uuidString, icon: UUID().uuidString)
    static let preview: Self = .init(id: UUID().uuidString, title: UUID().uuidString, subtitle: UUID().uuidString, icon: UUID().uuidString)
}
