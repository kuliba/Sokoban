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
    
    func test_map_shouldDeliverResponse() throws {
        
        try assert(.validData, .valid())
    }
    
    func test_map_shouldDeliverResponseRich() throws {
        
        try assert(.validDataRich, .valid(
            externalTransferType: .entity,
            operationStatus: .inProgress,
            paymentMethod: .cashless
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
        account: String = "766440148001",
        accountTitle: String = "Лицевой счет",
        currencyAmount: String = "RUB",
        externalTransferType: ExternalTransferType? = nil,
        operationStatus: OperationStatus? = nil,
        payeeFullName: String = "ПАО ТНС ЭНЕРГО ЯРОСЛАВЛЬ",
        payeeINN: String = "7606052264",
        payeeKPP: String = "760601001",
        payerCardID: Int = 10000204785,
        payerCardNumber: String = "**** **** **92 6035",
        payerINN: String = "692502219386",
        payerMiddleName: String = "Сергеевич",
        paymentMethod: PaymentMethod? = nil,
        paymentTemplateID: Int = 2773,
        puref: String = "iFora||TNS",
        returned: Bool = false,
        transfer: Transfer = .housingAndCommunalService
    ) -> Self {
        
        .init(
            account: account,
            accountTitle: accountTitle,
            amount: 1_000,
            claimID: "7877f00d-0f37-46f7-a9d5-4eaf1ac84e32",
            currencyAmount: currencyAmount,
            dateForDetail: "17 апреля 2023, 17:13",
            externalTransferType: externalTransferType,
            isTrafficPoliceService: false,
            operationStatus: operationStatus,
            payeeFullName: payeeFullName,
            payeeINN: payeeINN,
            payeeKPP: payeeKPP, 
            payerAccountID: 10004333104,
            payerAccountNumber: "40817810543005000761",
            payerAddress: "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
            payerAmount: 1_000,
            payerCardID: payerCardID,
            payerCardNumber: payerCardNumber,
            payerCurrency: "RUB",
            payerFee: 0,
            payerFirstName: "Кирилл",
            payerFullName: "Большаков Кирилл Сергеевич",
            payerINN: payerINN,
            payerMiddleName: payerMiddleName,
            paymentMethod: paymentMethod, 
            paymentOperationDetailID: 57723,
            paymentTemplateID: paymentTemplateID,
            printFormType: .housingAndCommunalService,
            puref: puref,
            requestDate: "17.04.2023 17:13:36",
            responseDate: "17.04.2023 17:13:38",
            returned: returned,
            transfer: transfer,
            transferDate: "17.04.2023"
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
        "puref": "iFora||TNS",
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
        "puref": "iFora||TNS",
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
}
