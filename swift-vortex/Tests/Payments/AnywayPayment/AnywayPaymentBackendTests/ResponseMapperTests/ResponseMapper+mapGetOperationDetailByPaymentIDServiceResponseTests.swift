//
//  ResponseMapper+mapGetOperationDetailByPaymentIDResponseTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import AnywayPaymentBackend
import RemoteServices
import XCTest

final class ResponseMapper_mapGetOperationDetailByPaymentIDResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {
        
        let invalidData: Data = .invalidData
        
        XCTAssertNoDiff(
            map(invalidData),
            .failure(.invalid(statusCode: 200, data: invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        let emptyJSON: Data = .emptyJSON
        
        XCTAssertNoDiff(
            map(emptyJSON),
            .failure(.invalid(statusCode: 200, data: emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        let emptyDataResponse: Data = .emptyDataResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        let nullServerResponse: Data = .nullServerResponse
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerErrorOnServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
            )
        }
    }
    
    func test_map_shouldDeliverResponse_validData() throws {
        
        try assert(.validData, .valid())
    }
    
    func test_map_shouldDeliverResponse_validDataRich() throws {
        
        try assert(.validDataRich, .valid(
            externalTransferType: .entity,
            operationStatus: .inProgress,
            paymentMethod: .cashless
        ))
    }
    
    func test_map_shouldDeliverResponse_validDataRichV2() throws {
        
        try assert(.validDataRichV2, .valid(
            documentNumber: "330322",
            externalTransferType: .entity,
            operationCategory: "ЖКХ",
            operationStatus: .inProgress,
            paymentFlow: "STANDARD_FLOW",
            paymentMethod: .cashless
        ))
    }
    
    func test_map_shouldDeliverResponse_upno() throws {
        
        try assert(.upno, .valid(
            account: nil,
            accountTitle: nil,
            amount: 200,
            claimID: "121710",
            comment: "Штраф ГИБДД",
            dateForDetail: "18 февраля 2025, 12:26",
            dateN: "2024-08-26",
            discount: "10 %",
            discountExpiry: "2024-12-25",
            documentNumber: nil,
            externalTransferType: nil,
            legalAct: "Часть 1 статьи 12.16 КоАП тест тест тест тест тест тест тест тест тест тест тест тест тест тест",
            memberID: "100000000300",
            merchantIcon: "<svg>",
            merchantSubName: "Федеральное Казначейство",
            operationCategory: nil,
            operationStatus: .rejected,
            payeeBankName: "Федеральное казначейство",
            payeeCheckAccount: "03100643000000019500",
            payeeFullName: "Федеральное Казначейство",
            payeeINN: nil,
            payeeKPP: nil,
            payerAccountID: 10004683510,
            payerAccountNumber: "40817810988000001320",
            payerAddress: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 150014, Ярославская обл, Ярославль г, Толбухина пр-кт, д. 4, кв. 62",
            payerAmount: 200,
            payerCardID: nil,
            payerCardNumber: nil,
            payerFirstName: "Валерия",
            payerFullName: "Белякова Валерия Валерьевна",
            payerINN: "760406263431",
            payerMiddleName: "Валерьевна",
            payerPhone: "+79201176178",
            paymentFlow: nil,
            paymentMethod: nil,
            paymentOperationDetailID: 121710,
            paymentTemplateID: nil,
            paymentTerm: "2025-04-25",
            printFormType: "c2g",
            puref: "0||PaymentsC2G",
            realPayerFIO: "Тестов Тест Тестович",
            realPayerINN: "000000000000",
            realPayerKPP: "000000000",
            requestDate: "18.02.2025 12:26:21",
            responseDate: "18.02.2025 12:26:26",
            transAmm: 200,
            transfer: .unknown("C2G_PAYMENT"),
            transferDate: "18.02.2025",
            transferNumber: "A123456789",
            upno: "10445253410000001802202500000011"
        ))
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetOperationDetailByPaymentIDResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetOperationDetailByPaymentIDResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ data: Data,
        _ response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let receivedResponse = try map(data).get()
        XCTAssertNoDiff(receivedResponse, response, file: file, line: line)
    }
}

private extension ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    static func valid(
        account: String? = "766440148001",
        accountTitle: String? = "Лицевой счет",
        amount: Decimal = 1_000,
        billDate: String? = nil,
        billNumber: String? = nil,
        cityName: String? = nil,
        claimID: String = "7877f00d-0f37-46f7-a9d5-4eaf1ac84e32",
        comment: String? = nil,
        countryName: String? = nil,
        currencyAmount: String? = "RUB",
        currencyRate: Decimal? = nil,
        cursiveAmount: String? = nil,
        cursivePayeeAmount: String? = nil,
        cursivePayerAmount: String? = nil,
        dateForDetail: String = "17 апреля 2023, 17:13",
        dateN: String? = nil,
        depositDateOpen: String? = nil,
        depositNumber: String? = nil,
        discount: String? = nil,
        discountExpiry: String? = nil,
        division: String? = nil,
        documentNumber: String? = nil,
        driverLicense: String? = nil,
        externalTransferType: ExternalTransferType? = nil,
        formattedAmount: String? = nil,
        isForaBank: Bool? = nil,
        isTrafficPoliceService: Bool = false,
        legalAct: String? = nil,
        mcc: String? = nil,
        memberID: String? = nil,
        merchantIcon: String? = nil,
        merchantSubName: String? = nil,
        oktmo: String? = nil,
        operation: String? = nil,
        operationCategory: String? = nil,
        operationStatus: OperationStatus? = nil,
        payeeAccountID: Int? = nil,
        payeeAccountNumber: String? = nil,
        payeeAmount: Decimal? = nil,
        payeeBankBIC: String? = nil,
        payeeBankCorrAccount: String? = nil,
        payeeBankName: String? = nil,
        payeeCardID: Int? = nil,
        payeeCardNumber: String? = nil,
        payeeCheckAccount: String? = nil,
        payeeCurrency: String? = nil,
        payeeFirstName: String? = nil,
        payeeFullName: String? = "ПАО ТНС ЭНЕРГО ЯРОСЛАВЛЬ",
        payeeINN: String? = "7606052264",
        payeeKPP: String? = "760601001",
        payeeMiddleName: String? = nil,
        payeePhone: String? = nil,
        payeeSurName: String? = nil,
        payerAccountID: Int = 10004333104,
        payerAccountNumber: String = "40817810543005000761",
        payerAddress: String = "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
        payerAmount: Decimal = 1_000,
        payerCardID: Int? = 10000204785,
        payerCardNumber: String? = "**** **** **92 6035",
        payerCurrency: String = "RUB",
        payerDocument: String? = nil,
        payerFee: Decimal = 0,
        payerFirstName: String = "Кирилл",
        payerFullName: String = "Большаков Кирилл Сергеевич",
        payerINN: String? = "692502219386",
        payerMiddleName: String? = "Сергеевич",
        payerPhone: String? = nil,
        payerSurName: String? = nil,
        paymentFlow: String? = nil,
        paymentMethod: PaymentMethod? = nil,
        paymentOperationDetailID: Int = 57723,
        paymentTemplateID: Int? = 2773,
        paymentTerm: String? = nil,
        period: String? = nil,
        printFormType: PrintFormType = "housingAndCommunalService",
        provider: String? = nil,
        puref: String? = "iVortex||TNS",
        realPayerFIO: String? = nil,
        realPayerINN: String? = nil,
        realPayerKPP: String? = nil,
        regCert: String? = nil,
        requestDate: String = "17.04.2023 17:13:36",
        responseDate: String = "17.04.2023 17:13:38",
        returned: Bool? = false,
        serviceName: String? = nil,
        serviceSelect: String? = nil,
        shopLink: String? = nil,
        supplierBillID: String? = nil,
        transAmm: Decimal? = nil,
        transfer: Transfer? = .housingAndCommunalService,
        transferDate: String = "17.04.2023",
        transferNumber: String? = nil,
        transferReference: String? = nil,
        trnPickupPointName: String? = nil,
        upno: String? = nil
    ) -> Self {
        
        return .init(
            account: account,
            accountTitle: accountTitle,
            amount: amount,
            billDate: billDate,
            billNumber: billNumber,
            cityName: cityName,
            claimID: claimID,
            comment: comment,
            countryName: countryName,
            currencyAmount: currencyAmount,
            currencyRate: currencyRate,
            cursiveAmount: cursiveAmount,
            cursivePayeeAmount: cursivePayeeAmount,
            cursivePayerAmount: cursivePayerAmount,
            dateForDetail: dateForDetail,
            dateN: dateN,
            depositDateOpen: depositDateOpen,
            depositNumber: depositNumber,
            discount: discount,
            discountExpiry: discountExpiry,
            division: division,
            documentNumber: documentNumber,
            driverLicense: driverLicense,
            externalTransferType: externalTransferType,
            formattedAmount: formattedAmount,
            isForaBank: isForaBank,
            isTrafficPoliceService: isTrafficPoliceService,
            legalAct: legalAct,
            mcc: mcc,
            memberID: memberID,
            merchantIcon: merchantIcon,
            merchantSubName: merchantSubName,
            oktmo: oktmo,
            operation: operation,
            operationCategory: operationCategory,
            operationStatus: operationStatus,
            payeeAccountID: payeeAccountID,
            payeeAccountNumber: payeeAccountNumber,
            payeeAmount: payeeAmount,
            payeeBankBIC: payeeBankBIC,
            payeeBankCorrAccount: payeeBankCorrAccount,
            payeeBankName: payeeBankName,
            payeeCardID: payeeCardID,
            payeeCardNumber: payeeCardNumber,
            payeeCheckAccount: payeeCheckAccount,
            payeeCurrency: payeeCurrency,
            payeeFirstName: payeeFirstName,
            payeeFullName: payeeFullName,
            payeeINN: payeeINN,
            payeeKPP: payeeKPP,
            payeeMiddleName: payeeMiddleName,
            payeePhone: payeePhone,
            payeeSurName: payeeSurName,
            payerAccountID: payerAccountID,
            payerAccountNumber: payerAccountNumber,
            payerAddress: payerAddress,
            payerAmount: payerAmount,
            payerCardID: payerCardID,
            payerCardNumber: payerCardNumber,
            payerCurrency: payerCurrency,
            payerDocument: payerDocument,
            payerFee: payerFee,
            payerFirstName: payerFirstName,
            payerFullName: payerFullName,
            payerINN: payerINN,
            payerMiddleName: payerMiddleName,
            payerPhone: payerPhone,
            payerSurName: payerSurName,
            paymentFlow: paymentFlow,
            paymentMethod: paymentMethod,
            paymentOperationDetailID: paymentOperationDetailID,
            paymentTemplateID: paymentTemplateID,
            paymentTerm: paymentTerm,
            period: period,
            printFormType: printFormType,
            provider: provider,
            puref: puref,
            realPayerFIO: realPayerFIO,
            realPayerINN: realPayerINN,
            realPayerKPP: realPayerKPP,
            regCert: regCert,
            requestDate: requestDate,
            responseDate: responseDate,
            returned: returned,
            serviceName: serviceName,
            serviceSelect: serviceSelect,
            shopLink: shopLink,
            supplierBillID: supplierBillID,
            transAmm: transAmm,
            transfer: transfer,
            transferDate: transferDate,
            transferNumber: transferNumber,
            transferReference: transferReference,
            trnPickupPointName: trnPickupPointName,
            upno: upno
        )
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validData: Data = String.validData.json
    static let validDataRich: Data = String.validDataRich.json
    static let validDataRichV2: Data = String.validDataRichV2.json
    static let upno: Data = String.upno.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
    static let validData = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "account": "766440148001",
        "accountTitle": "Лицевой счет",
        "amount": 1000,
        "cityName": null,
        "claimId": "7877f00d-0f37-46f7-a9d5-4eaf1ac84e32",
        "comment": null,
        "countryName": null,
        "currencyAmount": "RUB",
        "cursiveAmount": null,
        "cursivePayeeAmount": null,
        "cursivePayerAmount": null,
        "dateForDetail": "17 апреля 2023, 17:13",
        "externalTransferType": null,
        "isForaBank": null,
        "isTrafficPoliceService": false,
        "MCC": null,
        "OKTMO": null,
        "operation": null,
        "payerAccountId": 10004333104,
        "payerAccountNumber": "40817810543005000761",
        "payerAddress": "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
        "payerAmount": 1000,
        "payerCardId": 10000204785,
        "payerCardNumber": "**** **** **92 6035",
        "payerCurrency": "RUB",
        "payerDocument": null,
        "payerFee": 0,
        "payerFirstName": "Кирилл",
        "payerFullName": "Большаков Кирилл Сергеевич",
        "payerINN": "692502219386",
        "payerMiddleName": "Сергеевич",
        "payerPhone": null,
        "payerSurName": null,
        "payeeAccountId": null,
        "payeeAccountNumber": null,
        "payeeAmount": null,
        "payeeBankBIC": null,
        "payeeBankCorrAccount": null,
        "payeeBankName": null,
        "payeeCardId": null,
        "payeeCardNumber": null,
        "payeeCurrency": null,
        "payeeFirstName": null,
        "payeeFullName": "ПАО ТНС ЭНЕРГО ЯРОСЛАВЛЬ",
        "payeeINN": "7606052264",
        "payeeKPP": "760601001",
        "payeeMiddleName": null,
        "payeePhone": null,
        "payeeSurName": null,
        "paymentMethod": null,
        "paymentOperationDetailId": 57723,
        "paymentTemplateId": 2773,
        "period": null,
        "printFormType": "housingAndCommunalService",
        "provider": null,
        "puref": "iVortex||TNS",
        "requestDate": "17.04.2023 17:13:36",
        "responseDate": "17.04.2023 17:13:38",
        "returned": false,
        "transferDate": "17.04.2023",
        "transferEnum": "HOUSING_AND_COMMUNAL_SERVICE",
        "transferNumber": null,
        "transferReference": null,
        "trnPickupPointName": null
    }
}
"""
    
    static let validDataRich = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "account": "766440148001",
        "accountTitle": "Лицевой счет",
        "amount": 1000,
        "cityName": null,
        "claimId": "7877f00d-0f37-46f7-a9d5-4eaf1ac84e32",
        "comment": null,
        "countryName": null,
        "currencyAmount": "RUB",
        "cursiveAmount": null,
        "cursivePayeeAmount": null,
        "cursivePayerAmount": null,
        "dateForDetail": "17 апреля 2023, 17:13",
        "externalTransferType": "ENTITY",
        "isForaBank": null,
        "isTrafficPoliceService": false,
        "MCC": null,
        "OKTMO": null,
        "operation": null,
        "operationStatus": "IN_PROGRESS",
        "payerAccountId": 10004333104,
        "payerAccountNumber": "40817810543005000761",
        "payerAddress": "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
        "payerAmount": 1000,
        "payerCardId": 10000204785,
        "payerCardNumber": "**** **** **92 6035",
        "payerCurrency": "RUB",
        "payerDocument": null,
        "payerFee": 0,
        "payerFirstName": "Кирилл",
        "payerFullName": "Большаков Кирилл Сергеевич",
        "payerINN": "692502219386",
        "payerMiddleName": "Сергеевич",
        "payerPhone": null,
        "payerSurName": null,
        "payeeAccountId": null,
        "payeeAccountNumber": null,
        "payeeAmount": null,
        "payeeBankBIC": null,
        "payeeBankCorrAccount": null,
        "payeeBankName": null,
        "payeeCardId": null,
        "payeeCardNumber": null,
        "payeeCurrency": null,
        "payeeFirstName": null,
        "payeeFullName": "ПАО ТНС ЭНЕРГО ЯРОСЛАВЛЬ",
        "payeeINN": "7606052264",
        "payeeKPP": "760601001",
        "payeeMiddleName": null,
        "payeePhone": null,
        "payeeSurName": null,
        "paymentMethod": "Безналичный",
        "paymentOperationDetailId": 57723,
        "paymentTemplateId": 2773,
        "period": null,
        "printFormType": "housingAndCommunalService",
        "provider": null,
        "puref": "iVortex||TNS",
        "requestDate": "17.04.2023 17:13:36",
        "responseDate": "17.04.2023 17:13:38",
        "returned": false,
        "transferDate": "17.04.2023",
        "transferEnum": "HOUSING_AND_COMMUNAL_SERVICE",
        "transferNumber": null,
        "transferReference": null,
        "trnPickupPointName": null,
    }
}
"""
    
    static let validDataRichV2 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "account": "766440148001",
        "accountTitle": "Лицевой счет",
        "amount": 1000,
        "cityName": null,
        "claimId": "7877f00d-0f37-46f7-a9d5-4eaf1ac84e32",
        "comment": null,
        "countryName": null,
        "currencyAmount": "RUB",
        "cursiveAmount": null,
        "cursivePayeeAmount": null,
        "cursivePayerAmount": null,
        "dateForDetail": "17 апреля 2023, 17:13",
        "externalTransferType": "ENTITY",
        "isForaBank": null,
        "isTrafficPoliceService": false,
        "MCC": null,
        "OKTMO": null,
        "operation": null,
        "operationStatus": "IN_PROGRESS",
        "payerAccountId": 10004333104,
        "payerAccountNumber": "40817810543005000761",
        "payerAddress": "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
        "payerAmount": 1000,
        "payerCardId": 10000204785,
        "payerCardNumber": "**** **** **92 6035",
        "payerCurrency": "RUB",
        "payerDocument": null,
        "payerFee": 0,
        "payerFirstName": "Кирилл",
        "payerFullName": "Большаков Кирилл Сергеевич",
        "payerINN": "692502219386",
        "payerMiddleName": "Сергеевич",
        "payerPhone": null,
        "payerSurName": null,
        "payeeAccountId": null,
        "payeeAccountNumber": null,
        "payeeAmount": null,
        "payeeBankBIC": null,
        "payeeBankCorrAccount": null,
        "payeeBankName": null,
        "payeeCardId": null,
        "payeeCardNumber": null,
        "payeeCurrency": null,
        "payeeFirstName": null,
        "payeeFullName": "ПАО ТНС ЭНЕРГО ЯРОСЛАВЛЬ",
        "payeeINN": "7606052264",
        "payeeKPP": "760601001",
        "payeeMiddleName": null,
        "payeePhone": null,
        "payeeSurName": null,
        "paymentMethod": "Безналичный",
        "paymentOperationDetailId": 57723,
        "paymentTemplateId": 2773,
        "period": null,
        "printFormType": "housingAndCommunalService",
        "provider": null,
        "puref": "iVortex||TNS",
        "requestDate": "17.04.2023 17:13:36",
        "responseDate": "17.04.2023 17:13:38",
        "returned": false,
        "transferDate": "17.04.2023",
        "transferEnum": "HOUSING_AND_COMMUNAL_SERVICE",
        "transferNumber": null,
        "transferReference": null,
        "trnPickupPointName": null,
        "docNumber": "330322",
        "operationCategory": "ЖКХ",
        "paymentFlow": "STANDARD_FLOW"
    }
}
"""
    
    static let upno = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "claimId": "121710",
    "requestDate": "18.02.2025 12:26:21",
    "responseDate": "18.02.2025 12:26:26",
    "transferDate": "18.02.2025",
    "payerAccountId": 10004683510,
    "payerAccountNumber": "40817810988000001320",
    "payerFullName": "Белякова Валерия Валерьевна",
    "payerAddress": "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 150014, Ярославская обл, Ярославль г, Толбухина пр-кт, д. 4, кв. 62",
    "payerAmount": 200,
    "payerFee": 0,
    "payerCurrency": "RUB",
    "payeeFullName": "Федеральное Казначейство",
    "payeeBankName": "Федеральное казначейство",
    "amount": 200,
    "currencyAmount": "RUB",
    "comment": "Штраф ГИБДД",
    "transferEnum": "C2G_PAYMENT",
    "payerFirstName": "Валерия",
    "payerMiddleName": "Валерьевна",
    "payerPhone": "+79201176178",
    "puref": "0||PaymentsC2G",
    "memberId": "100000000300",
    "isTrafficPoliceService": false,
    "merchantSubName": "Федеральное Казначейство",
    "merchantIcon": "<svg>",
    "operationStatus": "REJECTED",
    "payeeCheckAccount": "03100643000000019500",
    "paymentOperationDetailId": 121710,
    "printFormType": "c2g",
    "dateForDetail": "18 февраля 2025, 12:26",
    "transAmm": 200,
    "discount": "10 %",
    "discountExpiry": "2024-12-25",
    "dateN": "2024-08-26",
    "legalAct": "Часть 1 статьи 12.16 КоАП тест тест тест тест тест тест тест тест тест тест тест тест тест тест",
    "supplierBillId": "18810192085432512980",
    "realPayerFIO": "Тестов Тест Тестович",
    "realPayerINN": "000000000000",
    "realPayerKPP": "000000000",
    "returned": false,
    "payerINN": "760406263431",
    "paymentTerm": "2025-04-25",
    "UPNO": "10445253410000001802202500000011",
    "transferNumber": "A123456789"
  }
}
"""
}
