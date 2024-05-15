//
//  UtilityPaymentNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

final class UtilityPaymentNanoServicesComposer {
    
    private let httpClient: HTTPClient
    private let model: Model
    private let flag: Flag
    
    init(
        httpClient: HTTPClient,
        model: Model,
        flag: Flag
    ) {
        self.httpClient = httpClient
        self.model = model
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
    
    typealias Flag = StubbedFeatureFlag.Option
    
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
}

private extension UtilityPaymentNanoServicesComposer {
    
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    func getOperatorsListByParam(
        pageSize: Int,
        _ completion: @escaping ([Operator]) -> Void
    ) {
#warning("add flag and switch between live and stub")
        model.loadOperators(.init(pageSize: pageSize), completion)
    }
    
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    func getAllLatestPayments(
        _ completion: @escaping ([LastPayment]) -> Void
    ) {
#warning("add flag and switch between live and stub")
        
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
