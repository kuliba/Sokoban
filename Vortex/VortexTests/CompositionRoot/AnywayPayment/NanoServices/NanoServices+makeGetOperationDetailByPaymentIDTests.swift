//
//  NanoServices+makeGetOperationDetailByPaymentIDTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 27.03.2024.
//

@testable import ForaBank
import XCTest

final class NanoServices_makeGetOperationDetailByPaymentIDTests: XCTestCase {
    
    func test_shouldCallHTTPClientOnce() throws {
        
        _ = try checkRequest()
    }
    
    func test_shouldSetURL() throws {
        
        try assertURL("https://pl.forabank.ru/dbo/api/v3/rest/transfer/makeTransfer")
    }
    
    func test_shouldSetHTTPMethodToPOST() throws {
        
        try assertHTTPMethod("POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        try assertCachePolicy(.reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_shouldPassPayload() throws {
        
        try XCTAssertNotNil(checkRequest(with: makePayload()).httpBody)
    }
    
    func test_shouldDeliverNilOnFailure() {
        
        expect(toDeliver: nil, on: .failure(anyError()))
    }
    
    func test_shouldDeliverNilOnEmptyData() {
        
        expect(toDeliver: nil, onData: .empty)
    }
    
    func test_shouldDeliverNilOnEmptyJSON() {
        
        expect(toDeliver: nil, onData: .emptyJSON)
    }
    
    func test_shouldDeliverNilOnEmptyArrayJSON() {
        
        expect(toDeliver: nil, onData: .emptyArrayJSON)
    }
    
    func test_shouldDeliverNilOnInvalidData() {
        
        expect(toDeliver: nil, onData:  .invalid)
    }
    
    func test_shouldDeliverNilOnNullServerResponse() {
        
        expect(toDeliver: nil, onData: .nullServerResponse)
    }
    
    func test_shouldDeliverNilOnEmptyServerData() {
        
        expect(toDeliver: nil, onData: .emptyServerData)
    }
    
    func test_shouldDeliverNilOnEmptyArrayServerData() {
        
        expect(toDeliver: nil, onData: .emptyArrayServerData)
    }
    
    func test_shouldDeliverNilOnInvalidServerData() {
        
        expect(toDeliver: nil, onData: .invalidServerData)
    }
    
    func test_shouldDeliverNilOnServerError() {
        
        expect(toDeliver: nil, onData: .serverError)
    }
    
    func test_shouldDeliverNilOnValidDataNonOKStatusCode() {
        
        for nonOkStatusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOKResponse = anyHTTPURLResponse(with: nonOkStatusCode)
            expect(toDeliver: nil, on: .success((.valid, nonOKResponse)))
        }
    }
    
    func test_shouldDeliverResponseOnValidData() {
        
        expect(
            toDeliver: .valid(),
            onData: .valid
        )
    }
    
    func test_shouldDeliverResponseOnValidRichData() {
        
        expect(
            toDeliver: .valid(
                externalTransferType: .entity,
                operationStatus: .inProgress,
                paymentMethod: .cashless
            ),
            onData: .validRich
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NanoServices.GetOperationDetailByPaymentID
    private typealias Payload = NanoServices.GetOperationDetailByPaymentIDPayload
    private typealias Result = NanoServices.GetOperationDetailByPaymentIDResult
    private typealias Response = NanoServices.GetOperationDetailByPaymentIDResponse
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let sut = NanoServices.makeGetOperationDetailByPaymentID(httpClient, { _,_,_ in })
        
        trackForMemoryLeaks(httpClient, file: file, line: line)
        
        return (sut, httpClient)
    }
    
    private func assertURL(
        with payload: Payload = makePayload(),
        _ urlString: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let request = try checkRequest(file: file, line: line)
        XCTAssertNoDiff(request.url?.absoluteString, urlString, file: file, line: line)
    }
    
    private func assertHTTPMethod(
        with payload: Payload = makePayload(),
        _ httpMethod: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let request = try checkRequest(file: file, line: line)
        XCTAssertNoDiff(request.httpMethod, httpMethod, file: file, line: line)
    }
    
    private func assertCachePolicy(
        with payload: Payload = makePayload(),
        _ cachePolicy: URLRequest.CachePolicy,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let request = try checkRequest(file: file, line: line)
        XCTAssertNoDiff(request.cachePolicy, cachePolicy, file: file, line: line)
    }
    
    private func checkRequest(
        with payload: Payload = makePayload(),
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> URLRequest {
        
        let (make, httpClient) = makeSUT()
        make(payload) { _ in }
        
        let count = httpClient.requests.count
        XCTAssertNoDiff(count, 1, "Expected to have one request, but got \(count) insted.")
        
        return try XCTUnwrap(httpClient.requests.first, file: file, line: line)
    }
    
    private func expect(
        with payload: Payload = makePayload(),
        toDeliver expectedResult: Result,
        onData data: Data,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (make, httpClient) = makeSUT()
        
        expect(
            make,
            with: payload,
            toDeliver: expectedResult,
            on: { httpClient.complete(with: .success((data, okResponse))) },
            file: file, line: line
        )
    }
    
    private func expect(
        with payload: Payload = makePayload(),
        toDeliver expectedResult: Result,
        on httpClientResult: HTTPClient.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (make, httpClient) = makeSUT()
        
        expect(
            make,
            with: payload,
            toDeliver: expectedResult,
            on: { httpClient.complete(with: httpClientResult) },
            file: file, line: line
        )
    }
    
    private func expect(
        _ sut: @escaping SUT,
        with payload: Payload = makePayload(),
        toDeliver expectedResult: Result,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        var receivedResult: Result?
        
        sut(payload) {
            
            receivedResult = $0
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedResult, expectedResult, "\nExpected \(String(describing: expectedResult)), got \(String(describing: receivedResult)) instead.", file: file, line: line)
    }
}

private let okResponse = anyHTTPURLResponse(with: 200)

private func makePayload(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> NanoServices.GetOperationDetailByPaymentIDPayload {
    
    .init(rawValue)
}

private extension NanoServices.GetOperationDetailByPaymentIDResponse {
    
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
    
    static let valid = json(.valid)
    static let validRich = json(.validRich)
}

private extension String {
    
    static let valid = """
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
    
    static let validRich = """
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
"""}
