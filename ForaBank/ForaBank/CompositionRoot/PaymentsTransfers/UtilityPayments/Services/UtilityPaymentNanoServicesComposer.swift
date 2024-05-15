//
//  UtilityPaymentNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import Foundation

final class UtilityPaymentNanoServicesComposer {
    
    private let httpClient: HTTPClient
    private let loadOperators: LoadOperators
    private let flag: Flag
    
    init(
        httpClient: HTTPClient,
        loadOperators: @escaping LoadOperators,
        flag: Flag
    ) {
        self.httpClient = httpClient
        self.loadOperators = loadOperators
        self.flag = flag
    }
}

extension UtilityPaymentNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        return .init(
            getOperatorsListByParam: getOperatorsListByParam,
            getAllLatestPayments: getAllLatestPayments
        )
    }
}

extension UtilityPaymentNanoServicesComposer {
    
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
    typealias LoadOperators = (@escaping LoadOperatorsCompletion) -> Void
    
    typealias Flag = StubbedFeatureFlag.Option
    
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
#warning("FIXME")
            
#warning("add logging // NanoServices.adaptedLoggingFetch")
            let service = RemoteService(
                createRequest: RequestFactory.getAllLatestPaymentsRequest(_:),
                performRequest: httpClient.performRequest,
                mapResponse: ResponseMapper.mapGetAllLatestPaymentsResponse
            )
            
            service.process(.service) { [service] result in
                
                completion((try? result.get().map(LastPayment.init(with:))) ?? [])
                _ = service
            }
            
        case .stub:
            DispatchQueue.main.delay(for: .seconds(1)) { completion(.stub) }
        }
    }
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

#warning("Fix")
import GenericRemoteService
//
//extension NanoServices {
//
//    static func all(
//        httpClient: HTTPClient
//    ) -> GetAllPayments {
//
//
//        adaptedLoggingFetch(
//            createRequest: RequestFactory.getAllLatestPaymentRequest,
//            httpClient: httpClient,
//            mapResponse: ResponseMapper.mapGetAllLatestPaymentsResponse,
//            mapError: <#T##(RemoteServiceError<any Error, any Error, Error>) -> Error#>,
//            log: <#T##(String, StaticString, UInt) -> Void#>
//        )
//    }
//
//    typealias GetAllPaymentsCompletion = ([UtilityPaymentLastPayment]) -> Void
//    typealias GetAllPayments = (@escaping GetAllPaymentsCompletion) -> Void
//}
