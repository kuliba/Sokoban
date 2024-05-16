//
//  UtilityPaymentNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import Foundation

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
            startAnywayPayment: startAnywayPayment(),
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
#warning("add logging // NanoServices.adaptedLoggingFetch")
#warning("remake as ForaBank.NanoServices.startAnywayPayment")
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
    ) -> NanoServices.StartAnywayPayment {
        
        switch flag {
        case .live:
            return startAnywayPaymentLive()
            
        case let .stub(stub):
            return startAnywayPaymentStub(stub)
        }
    }
    
    private func startAnywayPaymentLive(
    ) -> NanoServices.StartAnywayPayment {
#warning("move ForaBank.NanoServices.startAnywayPayment implementation here???")
        return ForaBank.NanoServices.startAnywayPayment(httpClient, log)
    }
    
    private func startAnywayPaymentStub(
        _ stub: @escaping Flag.Stub
    ) -> NanoServices.StartAnywayPayment {
        
        return { payload, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub(payload))
            }
        }
    }
    
    /// `d`
    /// Получение услуг юр. лица по "customerId" и типу housingAndCommunalService
    /// dict/getOperatorsListByParam?customerId=8798&operatorOnly=false&type=housingAndCommunalService
    func getServicesFor(
    ) -> NanoServices.GetServicesFor {
        
#warning("fix me")
        return { fatalError() }()
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
