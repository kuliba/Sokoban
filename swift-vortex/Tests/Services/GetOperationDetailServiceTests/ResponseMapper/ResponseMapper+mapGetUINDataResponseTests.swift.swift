//
//  ResponseMapper+mapGetOperationDetailResponseTests.swift.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import GetOperationDetailService
import RemoteServices
import XCTest

final class ResponseMapper_mapGetOperationDetailResponseTests_swift: XCTestCase {
    
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
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() throws {
        
        let data: Data = .validData
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(data, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: data))
            )
        }
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyList() {
        
        let emptyDataResponse: Data = .emptyListResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_shouldDeliverResponse_onValidData() throws {
        
        let validData: Data = .validData
        
        XCTAssertNoDiff(map(validData), .success(makeResponse(
            amount: 200,
            claimID: "121468",
            comment: "Штраф ГИБДД",
            currencyAmount: "RUB",
            dateForDetail: "14 февраля 2025, 09:31",
            isTrafficPoliceService: false,
            memberID: "100000000300",
            merchantIcon: "<svg>",
            merchantSubName: "Федеральное Казначейство",
            operationStatus: "COMPLETE",
            payeeBankName: "Федеральное казначейство",
            payeeCheckAccount: "03100643000000019500",
            payeeFullName: "Федеральное Казначейство",
            payeeINN: "1901108410",
            payerAccountID: 10004766557,
            payerAccountNumber: "40817810000055004276",
            payerAddress: "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
            payerAmount: 200,
            payerCardID: 10000239151,
            payerCardNumber: "**** **** **01 3245",
            payerCurrency: "RUB",
            payerFee: 0,
            payerFirstName: "R",
            payerFullName: "R V S",
            payerINN: "614210868146",
            payerMiddleName: "V",
            payerPhone: "+79896220672",
            paymentOperationDetailID: 121468,
            printFormType: "c2g",
            puref: "0||PaymentsC2G",
            requestDate: "14.02.2025 09:31:41",
            responseDate: "14.02.2025 09:32:54",
            returned: false,
            transferDate: "14.02.2025",
            transferEnum: "C2G_PAYMENT",
            transferNumber: "A5045063156607010000020011450701"
        ))
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetOperationDetailResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetOperationDetailResponse(data, httpURLResponse)
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
    
    private func makeResponse(
        account: String? = nil,
        accountTitle: String? = nil,
        amount: Int? = nil,
        billDate: String? = nil,
        billNumber: String? = nil,
        cityName: String? = nil,
        claimID: String,
        comment: String? = nil,
        countryName: String? = nil,
        currencyAmount: String? = nil,
        currencyRate: Int? = nil,
        cursiveAmount: String? = nil,
        cursivePayeeAmount: String? = nil,
        cursivePayerAmount: String? = nil,
        dateForDetail: String? = nil,
        depositDateOpen: String? = nil,
        depositNumber: String? = nil,
        division: String? = nil,
        driverLicense: String? = nil,
        externalTransferType: String? = nil,
        isForaBank: Bool? = nil,
        isTrafficPoliceService: Bool? = nil,
        MCC: String? = nil,
        memberID: String? = nil,
        merchantIcon: String? = nil,
        merchantSubName: String? = nil,
        OKTMO: String? = nil,
        operation: String? = nil,
        operationStatus: String? = nil,
        payeeAccountID: Int? = nil,
        payeeAccountNumber: String? = nil,
        payeeAmount: Int? = nil,
        payeeBankBIC: String? = nil,
        payeeBankCorrAccount: String? = nil,
        payeeBankName: String? = nil,
        payeeCardID: Int? = nil,
        payeeCardNumber: String? = nil,
        payeeCheckAccount: String? = nil,
        payeeCurrency: String? = nil,
        payeeFirstName: String? = nil,
        payeeFullName: String? = nil,
        payeeINN: String? = nil,
        payeeKPP: String? = nil,
        payeeMiddleName: String? = nil,
        payeePhone: String? = nil,
        payeeSurName: String? = nil,
        payerAccountID: Int? = nil,
        payerAccountNumber: String? = nil,
        payerAddress: String? = nil,
        payerAmount: Int? = nil,
        payerCardID: Int? = nil,
        payerCardNumber: String? = nil,
        payerCurrency: String? = nil,
        payerDocument: String? = nil,
        payerFee: Int? = nil,
        payerFirstName: String? = nil,
        payerFullName: String? = nil,
        payerINN: String? = nil,
        payerMiddleName: String? = nil,
        payerPhone: String? = nil,
        payerSurName: String? = nil,
        paymentMethod: String? = nil,
        paymentOperationDetailID: Int? = nil,
        paymentTemplateID: Int? = nil,
        period: String? = nil,
        printFormType: String? = nil,
        provider: String? = nil,
        puref: String? = nil,
        regCert: String? = nil,
        requestDate: String? = nil,
        responseDate: String? = nil,
        returned: Bool? = nil,
        serviceName: String? = nil,
        serviceSelect: String? = nil,
        shopLink: String? = nil,
        transferDate: String? = nil,
        transferEnum: String? = nil,
        transferNumber: String? = nil,
        transferReference: String? = nil,
        trnPickupPointName: String? = nil
    ) -> ResponseMapper.GetOperationDetailResponse {
        
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
            depositDateOpen: depositDateOpen,
            depositNumber: depositNumber,
            division: division,
            driverLicense: driverLicense,
            externalTransferType: externalTransferType,
            isForaBank: isForaBank,
            isTrafficPoliceService: isTrafficPoliceService,
            MCC: MCC,
            memberID: memberID,
            merchantIcon: merchantIcon,
            merchantSubName: merchantSubName,
            OKTMO: OKTMO,
            operation: operation,
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
            paymentMethod: paymentMethod,
            paymentOperationDetailID: paymentOperationDetailID,
            paymentTemplateID: paymentTemplateID,
            period: period,
            printFormType: printFormType,
            provider: provider,
            puref: puref,
            regCert: regCert,
            requestDate: requestDate,
            responseDate: responseDate,
            returned: returned,
            serviceName: serviceName,
            serviceSelect: serviceSelect,
            shopLink: shopLink,
            transferDate: transferDate,
            transferEnum: transferEnum,
            transferNumber: transferNumber,
            transferReference: transferReference,
            trnPickupPointName: trnPickupPointName
        )
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let emptyJSON: Data = String.emptyJSON.json
    static let invalidData: Data = String.invalidData.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    
    static let validData: Data = String.validData.json
}

private extension String {
    
    var json: Data { .init(utf8) }
    
    static let emptyJSON = "{}"
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
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
    
    static let emptyList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": []
}
"""
    
    static let validData = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "claimId": "121468",
    "requestDate": "14.02.2025 09:31:41",
    "responseDate": "14.02.2025 09:32:54",
    "transferDate": "14.02.2025",
    "payerCardId": 10000239151,
    "payerCardNumber": "**** **** **01 3245",
    "payerAccountId": 10004766557,
    "payerAccountNumber": "40817810000055004276",
    "payerFullName": "R V S",
    "payerAddress": "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
    "payerAmount": 200,
    "payerFee": 0,
    "payerCurrency": "RUB",
    "payeeFullName": "Федеральное Казначейство",
    "payeeBankName": "Федеральное казначейство",
    "amount": 200,
    "currencyAmount": "RUB",
    "comment": "Штраф ГИБДД",
    "transferEnum": "C2G_PAYMENT",
    "payerFirstName": "R",
    "payerMiddleName": "V",
    "payerPhone": "+79896220672",
    "transferNumber": "A5045063156607010000020011450701",
    "puref": "0||PaymentsC2G",
    "memberId": "100000000300",
    "isTrafficPoliceService": false,
    "merchantSubName": "Федеральное Казначейство",
    "merchantIcon": "<svg>",
    "operationStatus": "COMPLETE",
    "payeeCheckAccount": "03100643000000019500",
    "paymentOperationDetailId": 121468,
    "printFormType": "c2g",
    "dateForDetail": "14 февраля 2025, 09:31",
    "returned": false,
    "payerINN": "614210868146",
    "payeeINN": "1901108410"
  }
}
"""
}
