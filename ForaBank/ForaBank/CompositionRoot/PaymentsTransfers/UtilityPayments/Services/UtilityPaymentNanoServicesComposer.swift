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
            startAnywayPayment: startAnywayPayment()
        )
    }
}

extension UtilityPaymentNanoServicesComposer {
    
    typealias Log = (String, StaticString, UInt) -> Void
    
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
    typealias LoadOperators = (@escaping LoadOperatorsCompletion) -> Void
    
    enum Flag {
        
        case live
        case stub((Select) -> StartPaymentResult)
        
        typealias Select = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent.Select
        typealias StartPaymentResult = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>.StartPaymentResult
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
#warning("add logging // NanoServices.adaptedLoggingFetch")
#warning("remake as ForaBank.NanoServices.startAnywayPayment")
            let service = Services.getAllLatestPayments(httpClient: httpClient)
            service.process(.service) { [service] result in
                
                completion((try? result.get().map(LastPayment.init(with:))) ?? [])
                _ = service
            }
            
        case .stub:
            DispatchQueue.main.delay(for: .seconds(1)) { completion(.stub) }
        }
    }
    
    /// `e`
    /// Начало выполнения перевода - 1шаг, передаем `isNewPayment=true`
    /// POST /rest/transfer/createAnywayTransfer?isNewPayment=true
    func startAnywayPayment(
    ) -> PrepaymentFlowEffectHandler.StartPayment {
        
        switch flag {
        case .live:
            return ForaBank.NanoServices.startAnywayPayment(httpClient, log)
            
        case let .stub(stub):
            
            return { payload, completion in
                
                DispatchQueue.main.delay(for: .seconds(1)) {
                    
                    completion(stub(payload))
                }
            }
        }
    }
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
}

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
