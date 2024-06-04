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
        // TODO: add logging // NanoServices.adaptedLoggingFetch
        // TODO: remake as ForaBank.NanoServices.startAnywayPayment
        let service = Services.getAllLatestPayments(httpClient: httpClient)
        service.process(.service) { [service] result in
            
            completion((try? result.get().map(LastPayment.init(with:))) ?? [])
            _ = service
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
            mapResponse: OperatorsListComponents.ResponseMapper.mapGetOperatorsListByParamOperatorOnlyFalseResponse,
            mapOutput: { $0.map(\.service) },
            mapError: { _ in NanoServices.GetServicesForError() },
            log: infoNetworkLog
        )
        
        let mapped = MapPayloadDecorator(
            decoratee: fetch,
            mapPayload: { (`operator`: Operator) in
                
#if MOCK
                return "21757"
#else
                return `operator`.id
#endif
            }
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
        lastPayment: LastPayment?
    ) -> AnywayPaymentOutline {
        
#warning("fix filtering according to https://shorturl.at/hIE5B")
        guard let product = model.paymentProducts().first,
              let coreProductType = product.productType.coreProductType
        else {
            // TODO: unimplemented graceful failure for missing products
            fatalError("unimplemented graceful failure")
        }
        
        let core = AnywayPaymentOutline.PaymentCore(
            amount: 0,
            currency: product.currency,
            productID: product.id,
            productType: coreProductType
        )
        
        return .init(core: core, fields: .init())
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

private extension UtilityPaymentLastPayment {
    
    init(with last: ResponseMapper.LatestServicePayment) {
        
        self.init(
            amount: last.amount,
            name: last.title,
            md5Hash: last.md5Hash,
            puref: last.puref
        )
    }
}

private extension RemoteServices.RequestFactory.CreateAnywayTransferPayload {
    
    init(_ payload: StartAnywayPaymentPayload) {
        
#if MOCK
        // "puref": "iForaNKORR||126732"
        let puref = "iForaNKORR||126732"
#else
        let puref = payload.puref
#endif
        
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
#if MOCK
            let response = response.mock(value: "6068506999", forTitle: "Лицевой счет")
            self = .success(.startPayment(response))
#else
            self = .success(.startPayment(response))
#endif
        }
    }
}

typealias StartAnywayPayment = UtilityPaymentNanoServices.StartAnywayPayment
typealias StartAnywayPaymentPayload = UtilityPaymentNanoServices.StartAnywayPaymentPayload
typealias StartAnywayPaymentResult = UtilityPaymentNanoServices.StartAnywayPaymentResult
typealias StartAnywayPaymentCompletion = UtilityPaymentNanoServices.StartAnywayPaymentCompletion

private extension OperatorsListComponents.ResponseMapper.SberUtilityService {
    
    var service: UtilityService {
        
        .init(name: name, puref: puref)
    }
}

private extension ProductType {
    
    var coreProductType: AnywayPaymentOutline.PaymentCore.ProductType? {
        
        switch self {
        case .card:    return .card
        case .account: return .account
        default:       return nil
        }
    }
}

// MARK: - Mocking

#if MOCK
private extension NanoServices.CreateAnywayTransferResponse {
    
    func mock(
        value: String,
        forTitle title: String
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
            parametersForNextStep: parametersForNextStep.map {
                
                return $0.mock(value: value, forTitle: title)
            },
            paymentOperationDetailID: paymentOperationDetailID,
            payeeName: payeeName,
            printFormType: printFormType,
            scenario: scenario,
            options: []
        )
    }
}

private extension NanoServices.CreateAnywayTransferResponse.Parameter {
    
    func mock(
        value: String,
        forTitle title: String
    ) -> Self {
        
        return .init(
            content: self.title == title ? value : content,
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
            title: self.title,
            type: type,
            viewType: viewType,
            visible: true
        )
    }
}
#endif

// MARK: - Stubs

private extension Array where Element == UtilityPaymentLastPayment {
    
    static let stub: Self = [
        .failure,
        .preview,
    ]
}

private extension UtilityPaymentLastPayment {
    
    static let failure: Self = .init(amount: 123.45, name: "failure", md5Hash: UUID().uuidString, puref: UUID().uuidString)
    static let preview: Self = .init(amount: 567.89, name: UUID().uuidString, md5Hash: UUID().uuidString, puref: UUID().uuidString)
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
            .make(id: "1", title: "Лицевой счет (\"1111\" = ok, другое = ошибка)")
        ]
    )
    
    static let step2: Self = .make(
        needSum: true
    )
    
    static let step3: Self = .make(
        parametersForNextStep: [
            .make(id: "SumSTrs", title: "Сумма (\"11\" = ok, \"22\" = fraud, другое = ошибка)")
        ]
    )
    
    static let step4: Self = .make(
        needMake: true,
        needOTP: true
    )
    
    static let step4Fraud: Self = .make(
        needMake: true,
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
