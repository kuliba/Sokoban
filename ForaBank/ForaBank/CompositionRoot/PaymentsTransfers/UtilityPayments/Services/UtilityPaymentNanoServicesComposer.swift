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
import LatestPayments
import OperatorsListComponents
import RemoteServices

final class UtilityPaymentNanoServicesComposer {
    
    private let flag: Flag
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    private let loadOperators: LoadOperators
    
    init(
        flag: UtilitiesPaymentsFlag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        loadOperators: @escaping LoadOperators
    ) {
        self.flag = .init(flag)
        self.model = model
        self.httpClient = httpClient
        self.log = log
        self.loadOperators = loadOperators
    }
    
    enum Flag {
        
        case live, stub
        
        init(_ flag: UtilitiesPaymentsFlag) {
            
            switch flag.rawValue {
            case .inactive, .active(.live): self = .live
            case .active(.stub):            self = .stub
            }
        }
    }
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    
    typealias LoadOperatorsCompletion = ([Operator]) -> Void
    typealias LoadOperators = (@escaping LoadOperatorsCompletion) -> Void
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
}

extension UtilityPaymentNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        return .init(
            getAllLatestPayments: getAllLatestPayments,
            getOperatorsListByParam: getOperatorsListByParam,
            getServicesFor: getServicesFor,
            startAnywayPayment: startAnywayPayment,
            makeAnywayPaymentOutline: makeAnywayPaymentOutline
        )
    }
    
    typealias NanoServices = UtilityPaymentNanoServices
}

// MARK: - getOperatorsListByParam

private extension UtilityPaymentNanoServicesComposer {
    
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    func getOperatorsListByParam(
        _ completion: @escaping ([Operator]) -> Void
    ) {
        loadOperators(completion)
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
        switch flag {
        case .live: getAllLatestPaymentsLive(completion)
        case .stub: getAllLatestPaymentsStub(completion)
        }
    }
    
    private func getAllLatestPaymentsLive(
        _ completion: @escaping ([LastPayment]) -> Void
    ) {
        struct MappingError: Error {}

        let fetch = ForaBank.NanoServices.adaptedLoggingFetch(
            createRequest: RequestFactory.createGetAllLatestPaymentsRequest(_:),
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
    
    private func getAllLatestPaymentsStub(
        _ completion: @escaping ([LastPayment]) -> Void
    ) {
        DispatchQueue.main.delay(for: .seconds(1)) { completion(.stub) }
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
        switch flag {
        case .live: startAnywayPaymentLive(payload, completion)
        case .stub: startAnywayPaymentStub(payload, completion)
        }
    }
    
    private func startAnywayPaymentLive(
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
    
    private func startAnywayPaymentStub(
        _ payload: StartAnywayPaymentPayload,
        _ completion: @escaping StartAnywayPaymentCompletion
    ) {
        DispatchQueue.main.delay(for: .seconds(1)) {
            
            let result = payload.startAnywayPaymentResultStub
            self.networkLog(level: .default, message: "Remote Service Start AnywayPayment Stub Result: \(result)", file: #file, line: #line)
            completion(result)
        }
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
        switch flag {
        case .live: getServicesForLive(`operator`, completion)
        case .stub: getServicesForStub(`operator`, completion)
        }
    }
    
    func getServicesForLive(
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
            mapPayload: { (`operator`: Operator) in return `operator`.id }
        )
        
        mapped(`operator`) { [mapped] in completion($0); _ = mapped }
    }
    
    func getServicesForStub(
        _ `operator`: Operator,
        _ completion: @escaping NanoServices.GetServicesForCompletion
    ) {
        DispatchQueue.main.delay(for: .seconds(1)) {
            
            let result = `operator`.getServicesForResultStub
            self.networkLog(level: .default, message: "Remote Service GetServicesFor operator \(`operator`) Stub Result: \(result)", file: #file, line: #line)
            completion(result)
        }
    }
    
    private func makeAnywayPaymentOutline(
        lastPayment: LastPayment?,
        and payload: AnywayPaymentOutline.Payload
    ) -> AnywayPaymentOutline {
        
        let outlineProduct = model.outlineProduct()
        
        if let lastPayment {
            
            return .init(
                latestServicePayment: lastPayment,
                product: outlineProduct
            )
        }
        
        return .init(
            amount: nil,
            product: outlineProduct,
            fields: .init(),
            payload: payload
        )
    }
}

// MARK: - Helpers

extension Model {
    
    func outlineProduct() -> AnywayPaymentOutline.Product {
        
        guard let product = paymentEligibleProducts().first,
              let outlineProductType = product.productType.outlineProductType
        else {
            // TODO: unimplemented graceful failure for missing products
            fatalError("unimplemented graceful failure")
        }
        
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

extension AnywayPaymentOutline {
    
    init(
        latestServicePayment latest: RemoteServices.ResponseMapper.LatestServicePayment,
        product: AnywayPaymentOutline.Product
    ) {
        let pairs = latest.additionalItems.map {
            
            ($0.fieldName, $0.fieldValue)
        }
        let fields = Dictionary(uniqueKeysWithValues: pairs)
        
        self.init(
            amount: latest.amount,
            product: product,
            fields: fields,
            payload: .init(
                puref: latest.puref,
                title: latest.name,
                subtitle: nil,
                icon: latest.md5Hash
            )
        )
    }
}

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
        
        .init(name: name, puref: puref)
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

// MARK: - Stubs

private extension Array where Element == UtilityPaymentLastPayment {
    
    static let stub: Self = [
        .failure,
        .preview,
    ]
}

private extension UtilityPaymentLastPayment {
    
    static let failure: Self = .init(date: .init(), amount: 123.45, name: "failure", md5Hash: nil, puref: UUID().uuidString, additionalItems: [])
    static let preview: Self = .init(date: .init(), amount: 567.89, name: UUID().uuidString, md5Hash: nil, puref: UUID().uuidString, additionalItems: [])
}

private extension UtilityPaymentOperator {
    
    var getServicesForResultStub: GetServicesForResult {
        
        switch id {
        case "empty":  return .success([])
        case "single-d2": return .success([.sample])
        case "multi-d1":  return .success([.sample, .failing, .failingWithMessage])
        default:       return .failure(.init())
        }
    }
    
    typealias GetServicesForResult = UtilityPaymentNanoServices.GetServicesForResult
}

private extension UtilityService {
    
    static let sample: Self = .init(name: "Service", puref: "service")
    static let failing: Self = .init(name: "Failing Service", puref: "failing")
    static let failingWithMessage: Self = .init(name: "Failing with Message Service", puref: "failingWithMessage")
}

private extension UtilityPaymentNanoServices.StartAnywayPaymentPayload {
    
    var startAnywayPaymentResultStub: StartAnywayPaymentResult {
        
        switch self {
        case let .lastPayment(lastPayment):
            fatalError("unimplemented")
            
        case let .service(service, `operator`):
            switch service.id {
            case "service":
                return .success(.startPayment(.step1))
                
            case "failingWithMessage":
                return .failure(.serviceFailure(.serverError("Error #12345. Try later.")))
                
            default:
                return .failure(.serviceFailure(.connectivityError))
            }
        }
    }
    
    typealias StartAnywayPaymentResult = UtilityPaymentNanoServices.StartAnywayPaymentResult
}

extension RemoteServices.ResponseMapper.CreateAnywayTransferResponse {
    
    static let step1: Self = .make(
        parametersForNextStep: [
            .make(id: "1", title: "Лицевой счет (\"1111\" = ошибка, \"2222\" = финальная ошибка, другое = ok)"),
            .make(
                dataType: .pairs(
                    .init(key: "a", value: "A"), [
                        .init(key: "a", value: "A"),
                        .init(key: "b", value: "B"),
                        .init(key: "c", value: "C"),
                        .init(key: "d", value: "D"),
                    ]
                ),
                id: "select", 
                title: "select",
                type: .select
            )
        ]
    )
    
    static let step2: Self = .make(
        needSum: true
    )
    
    static let step3: Self = .make(
        parametersForNextStep: [
            .make(
                dataType: .number,
                id: "SumSTrs",
                title: "Сумма (\"11\" = ok, \"22\" = fraud, другое = ошибка)"
            )
        ]
    )
    
    static let step4: Self = .make(
        finalStep: true,
        needMake: true,
        needOTP: true
    )
    
    static let step4Fraud: Self = .make(
        needMake: false,
        needOTP: true,
        scenario: .suspect
    )
    
    private static func make(
        additional: [Additional] = [],
        amount: Decimal? = nil,
        creditAmount: Decimal? = nil,
        currencyAmount: String? = nil,
        currencyPayee: String? = nil,
        currencyPayer: String? = nil,
        currencyRate: Decimal? = nil,
        debitAmount: Decimal? = nil,
        documentStatus: DocumentStatus? = nil,
        fee: Decimal? = nil,
        finalStep: Bool = false,
        infoMessage: String? = nil,
        needMake: Bool = false,
        needOTP: Bool = false,
        needSum: Bool = false,
        parametersForNextStep: [Parameter] = [],
        paymentOperationDetailID: Int? = nil,
        payeeName: String? = nil,
        printFormType: String? = nil,
        scenario: AntiFraudScenario? = nil,
        options: [Option] = []
    ) -> Self {
        
        return .init(
            additional: additional,
            amount: amount,
            creditAmount: creditAmount,
            currencyAmount: currencyAmount,
            currencyPayee: currencyPayee,
            currencyPayer: currencyPayer,
            currencyRate: currencyRate,
            debitAmount: debitAmount,
            documentStatus: documentStatus,
            fee: fee,
            finalStep: finalStep,
            infoMessage: infoMessage,
            needMake: needMake,
            needOTP: needOTP,
            needSum: needSum,
            parametersForNextStep: parametersForNextStep,
            paymentOperationDetailID: paymentOperationDetailID,
            payeeName: payeeName,
            printFormType: printFormType,
            scenario: scenario,
            options: options
        )
    }
}

private extension RemoteServices.ResponseMapper.CreateAnywayTransferResponse.Parameter {
    
    static func make(
        content: String? = nil,
        dataDictionary: String? = nil,
        dataDictionaryРarent: String? = nil,
        dataType: DataType = .string,
        group: String? = nil,
        id: String,
        inputFieldType: InputFieldType? = nil,
        inputMask: String? = nil,
        isPrint: Bool = false,
        isRequired: Bool = true,
        maxLength: Int? = nil,
        mask: String? = nil,
        minLength: Int? = nil,
        order: Int? = nil,
        phoneBook: Bool = false,
        rawLength: Int = 0,
        isReadOnly: Bool = false,
        regExp: String = "^.{1,250}$",
        subGroup: String? = nil,
        subTitle: String? = nil,
        md5hash: String? = nil,
        svgImage: String? = nil,
        title: String,
        type: FieldType = .input,
        viewType: ViewType = .input,
        visible: Bool = true
    ) -> Self {
        
        return .init(
            content: content,
            dataDictionary: dataDictionary,
            dataDictionaryРarent: dataDictionaryРarent,
            dataType: dataType,
            group: group,
            id: id,
            inputFieldType: inputFieldType,
            inputMask: inputMask,
            isPrint: isPrint,
            isRequired: isRequired,
            maxLength: maxLength,
            mask: mask,
            minLength: minLength,
            order: order,
            phoneBook: phoneBook,
            rawLength: rawLength,
            isReadOnly: isReadOnly,
            regExp: regExp,
            subGroup: subGroup,
            subTitle: subTitle,
            md5hash: md5hash,
            svgImage: svgImage,
            title: title,
            type: type,
            viewType: viewType,
            visible: visible
        )
    }
}
