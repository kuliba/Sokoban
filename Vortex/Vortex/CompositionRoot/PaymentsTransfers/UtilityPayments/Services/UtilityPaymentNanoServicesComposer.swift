//
//  UtilityPaymentNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import AnywayPaymentAdapters
import AnywayPaymentDomain
import Fetcher
import Foundation
import LatestPaymentsBackendV2
import OperatorsListComponents
import RemoteServices

final class UtilityPaymentNanoServicesComposer {
    
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    private let loadOperators: LoadOperators
    
    init(
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        loadOperators: @escaping LoadOperators
    ) {
        self.model = model
        self.httpClient = httpClient
        self.log = log
        self.loadOperators = loadOperators
    }
            
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
    typealias LoadOperators = (ServiceCategory.CategoryType, @escaping LoadOperatorsCompletion) -> Void
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentProvider
    typealias Service = UtilityService
}

extension UtilityPaymentNanoServicesComposer {
    
    func compose(
        categoryType: ServiceCategory.CategoryType
    ) -> NanoServices {
        
        return .init(
            getAllLatestPayments: getAllLatestPayments,
            getOperatorsListByParam: { [weak self] completion in
             
                self?.getOperatorsListByParam(categoryType, completion)
            },
            getServicesFor: getServicesFor,
            startAnywayPayment: startAnywayPayment
        )
    }
    
    typealias NanoServices = UtilityPaymentNanoServices
}

// MARK: - getOperatorsListByParam

private extension UtilityPaymentNanoServicesComposer {
    
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    func getOperatorsListByParam(
        _ categoryType: ServiceCategory.CategoryType,
        _ completion: @escaping ([Operator]) -> Void
    ) {
        loadOperators(categoryType, completion)
    }
}

// MARK: - getAllLatestPayments

private extension UtilityPaymentNanoServicesComposer {
    
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    func getAllLatestPayments(
        _ completion: @escaping ([LastPayment]) -> Void
    ) {
        struct MappingError: Error {}

        let fetch = ForaBank.NanoServices.adaptedLoggingFetch(
            createRequest: RequestFactory.createGetAllLatestPaymentsV2Request(_:),
            httpClient: httpClient,
            mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestServicePaymentsResponse(_:_:),
            mapOutput: { $0 },
            mapError: { _ in MappingError() },
            log: infoNetworkLog
        )
        
        fetch(.service) { [fetch] in
            
            completion((try? $0.get()) ?? [])
            _ = fetch
        }
    }
}

// MARK: - startAnywayPayment

private extension UtilityPaymentNanoServicesComposer {
    
    /// `e`
    /// Начало выполнения перевода - 1шаг, передаем `isNewPayment=true`
    /// POST /rest/transfer/createAnywayTransfer?isNewPayment=true
    func startAnywayPayment(
        _ payload: StartAnywayPaymentPayload,
        _ completion: @escaping StartAnywayPaymentCompletion
    ) {
        let createAnywayTransferNew = ForaBank.NanoServices.makeCreateAnywayTransferNewV2(httpClient, infoNetworkLog)
        let adapted = FetchAdapter(
            fetch: createAnywayTransferNew,
            mapResult: StartAnywayPaymentResult.init(result:)
        )
        let mapped = MapPayloadDecorator(
            decoratee: adapted.fetch,
            mapPayload: RemoteServices.RequestFactory.CreateAnywayTransferPayload.init
        )
        
        mapped(payload) { [mapped] in completion($0); _ = mapped }
    }
}

// MARK: - getServicesFor

private extension UtilityPaymentNanoServicesComposer {
    
    /// `d`
    /// Получение услуг юр. лица по "customerId" и типу housingAndCommunalService
    /// dict/getOperatorsListByParam?customerId=8798&operatorOnly=false&type=housingAndCommunalService
    func getServicesFor(
        _ `operator`: Operator,
        _ completion: @escaping NanoServices.GetServicesForCompletion
    ) {
        let fetch = ForaBank.NanoServices.adaptedLoggingFetch(
            createRequest: RequestFactory.createGetOperatorsListByParamOperatorOnlyFalseRequest,
            httpClient: httpClient,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperatorsListByParamOperatorOnlyFalseResponse,
            mapOutput: { $0.map(\.service) },
            mapError: { _ in NanoServices.GetServicesForError() },
            log: infoNetworkLog
        )
        
        let mapped = MapPayloadDecorator(
            decoratee: fetch,
            mapPayload: { (`operator`: Operator) in return `operator` }
        )
        
        mapped(`operator`) { [mapped] in completion($0); _ = mapped }
    }
}

// MARK: - Helpers

extension Model {
    
    @available(*, deprecated, message: "use failable overload")
    func outlineProduct() -> AnywayPaymentOutline.Product {
        
        guard let outlineProduct = outlineProduct()
        else {
            // TODO: unimplemented graceful failure for missing products
            fatalError("unimplemented graceful failure")
        }
        
        return outlineProduct
    }
    
    func outlineProduct() -> AnywayPaymentOutline.Product? {
        
        guard let product = paymentEligibleProducts().first,
              let outlineProductType = product.productType.outlineProductType
        else { return nil }
        
        let outlineProduct = AnywayPaymentOutline.Product(
            currency: product.currency,
            productID: product.id,
            productType: outlineProductType
        )
        
        return outlineProduct
    }
}

// MARK: - Log

private extension UtilityPaymentNanoServicesComposer {
    
    private func networkLog(
        level: LoggerAgentLevel,
        message: @autoclosure () -> String,
        file: StaticString,
        line: UInt
    ) {
        log(level, .network, message(), file, line)
    }
    
    private func infoNetworkLog(
        message: String,
        file: StaticString,
        line: UInt
    ) {
        log(.info, .network, message, file, line)
    }
}

// MARK: - Adapters

private extension RemoteServices.RequestFactory.CreateAnywayTransferPayload {
    
    init(_ payload: StartAnywayPaymentPayload) {
        
        let puref = payload.puref
        
        /// - Note: `check` is optional
        /// Признак проверки операции:
        /// - если `check="true"`, то OTP не отправляется,
        /// - если `check="false"` - OTP отправляется
        self.init(additional: [], check: true, puref: puref)
    }
}

private extension StartAnywayPaymentPayload {
    
    // Можно тестировать на прелайф
    // "iFora||MOO2" // single amount
    // "iFora||7602" // multi amount
    var puref: String {
        
        switch self {
        case let .lastPayment(lastPayment):
            return lastPayment.puref
            
        case let .service(utilityService, _):
            return utilityService.puref
        }
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
            self = .success(.startPayment(response))
        }
    }
}

typealias StartAnywayPayment = UtilityPaymentNanoServices.StartAnywayPayment
typealias StartAnywayPaymentPayload = UtilityPaymentNanoServices.StartAnywayPaymentPayload
typealias StartAnywayPaymentResult = UtilityPaymentNanoServices.StartAnywayPaymentResult
typealias StartAnywayPaymentCompletion = UtilityPaymentNanoServices.StartAnywayPaymentCompletion

/*private*/ extension RemoteServices.ResponseMapper.SberUtilityService {
    
    var service: UtilityService {
        
        .init(icon: icon, name: name, puref: puref)
    }
}

private extension ProductType {
    
    var outlineProductType: AnywayPaymentOutline.Product.ProductType? {
        
        switch self {
        case .card:    return .card
        case .account: return .account
        default:       return nil
        }
    }
}
